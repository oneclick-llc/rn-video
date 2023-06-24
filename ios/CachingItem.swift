import Foundation
import AVFoundation

fileprivate extension URL {
    
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
    
}

@objc protocol CachingPlayerItemDelegate {
    
    /// Is called when the media file is fully downloaded.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data)
    
    /// Is called when the data being downloaded did not arrive in time to
    /// continue playback.
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem)
    
    /// Is called on downloading error.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error)
    
}

@objc
open class CachingPlayerItem: AVPlayerItem {
    @objc
    class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
        
        var mimeType: String? // is required when playing from Data
        var session: URLSession?
        var mediaData: Data?
        var response: URLResponse?
        var pendingRequests = Set<AVAssetResourceLoadingRequest>()
        weak var owner: CachingPlayerItem?
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            
            if session == nil {
                
                // If we're playing from a url, we need to download the file.
                // We start loading the file on first request only.
                guard let initialUrl = owner?.url else {
                    fatalError("internal inconsistency")
                }
                
                startDataRequest(with: initialUrl)
            }
            
            pendingRequests.insert(loadingRequest)
            processPendingRequests()
            return true
            
        }
        
        func startDataRequest(with url: URL) {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            session?.dataTask(with: url).resume()
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            pendingRequests.remove(loadingRequest)
        }
        
        // MARK: URLSession delegate
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            mediaData?.append(data)
            processPendingRequests()
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(Foundation.URLSession.ResponseDisposition.allow)
            mediaData = Data()
            self.response = response
            processPendingRequests()
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let errorUnwrapped = error {
                owner?.delegate?.playerItem?(owner!, downloadingFailedWith: errorUnwrapped)
                return
            }
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didFinishDownloadingData: mediaData!)
        }
        
        // MARK: -
        
        func processPendingRequests() {
            
            // get all fullfilled requests
            let requestsFulfilled = Set<AVAssetResourceLoadingRequest>(pendingRequests.compactMap {
                self.fillInContentInformationRequest($0.contentInformationRequest)
                if self.haveEnoughDataToFulfillRequest($0.dataRequest!) {
                    $0.finishLoading()
                    return $0
                }
                return nil
            })
            
            // remove fulfilled requests from pending requests
            _ = requestsFulfilled.map { self.pendingRequests.remove($0) }
            
        }
        
        func fillInContentInformationRequest(_ contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
            // if we play from Data we make no url requests, therefore we have no responses, so we need to fill in contentInformationRequest manually
            
            guard let responseUnwrapped = response else {
                // have no response from the server yet
                return
            }
            
            contentInformationRequest?.contentType = responseUnwrapped.mimeType
            contentInformationRequest?.contentLength = responseUnwrapped.expectedContentLength
            contentInformationRequest?.isByteRangeAccessSupported = true
            
        }
        
        func haveEnoughDataToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
            let requestedOffset = Int(dataRequest.requestedOffset)
            let requestedLength = dataRequest.requestedLength
            let currentOffset = Int(dataRequest.currentOffset)
            
            guard let songDataUnwrapped = mediaData,
                  songDataUnwrapped.count > currentOffset else {
                // Don't have any data at all for this request.
                return false
            }
            
            let bytesToRespond = min(songDataUnwrapped.count - currentOffset, requestedLength)
            let dataToRespond = songDataUnwrapped.subdata(in: Range(uncheckedBounds: (currentOffset, currentOffset + bytesToRespond)))
            dataRequest.respond(with: dataToRespond)

            return songDataUnwrapped.count >= requestedLength + requestedOffset
            
        }
        
        deinit {
            session?.invalidateAndCancel()
        }
        
    }
    
    fileprivate let resourceLoaderDelegate = ResourceLoaderDelegate()
    fileprivate let url: URL
    
    weak var delegate: CachingPlayerItemDelegate?
    
    open func download() {
        if resourceLoaderDelegate.session == nil {
            resourceLoaderDelegate.startDataRequest(with: url)
        }
    }
    
    private let cachingPlayerItemScheme = "cachingPlayerItemScheme"
    
    @objc
    init(url: URL) {
        self.url = url
        
        var asset: AVURLAsset
        let localUrl = URL(string: "\(Self.getCacheDirectoryPath())\(url.lastPathComponent)")!
        let path = localUrl.absoluteString.replacingOccurrences(of: "file://", with: "")
        let exists = FileManager.default.fileExists(atPath: path)
        
        if exists {
            debugPrint("⚽️ play from cache \(path)")
            asset = AVURLAsset(url: localUrl)
        } else {
            debugPrint("⚽️ play remote \(path)")
            guard let urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
                fatalError("Urls without a scheme are not supported")
            }
            
            asset = AVURLAsset(url: urlWithCustomScheme)
            asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        }
        
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        
        if !exists {
            resourceLoaderDelegate.owner = self
            delegate = self
        }
        
    }
    
    // MARK: Notification hanlers
    
    @objc func playbackStalledHandler() {
        delegate?.playerItemPlaybackStalled?(self)
    }
    
    // MARK: -
    
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        fatalError("not implemented")
    }
    
    deinit {
        resourceLoaderDelegate.session?.invalidateAndCancel()
    }
    
}

extension CachingPlayerItem: CachingPlayerItemDelegate {
    static func getCacheDirectoryPath() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        DispatchQueue.global().async {
            let url = URL(string: "\(Self.getCacheDirectoryPath())\(playerItem.url.lastPathComponent)")!
            let path = url.absoluteString.replacingOccurrences(of: "file://", with: "")
            if FileManager.default.fileExists(atPath: path) {
                try? FileManager.default.removeItem(at: url)
            }
            try! data.write(to: url)
            debugPrint("⚽️ did save \(playerItem.url) -> \(path)")
        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print("⚽️ error \(error)")
    }
}
