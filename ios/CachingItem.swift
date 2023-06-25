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
            debugPrint("⚽️ ResourceLoaderDelegate.deinit")
            session?.invalidateAndCancel()
        }
        
    }
    
    fileprivate var resourceLoaderDelegate: ResourceLoaderDelegate?
    fileprivate let url: URL
    fileprivate let filename: String
    @objc
    public var existsLocal: Bool = false
    
    weak var delegate: CachingPlayerItemDelegate?
    
    open func download() {
        if resourceLoaderDelegate?.session == nil {
            resourceLoaderDelegate?.startDataRequest(with: url)
        }
    }
    
    private let cachingPlayerItemScheme = "cachingPlayerItemScheme"
    
    @objc
    public static func createItem(url: URL, filename: String) -> CachingPlayerItem {
        return CachingPlayerItem(url: url, filename: filename)
    }
    
    init(url: URL, filename: String) {
        self.url = url
        self.filename = filename
        
        let localPath = PINDiskCache.shared.fileURL(forKey: filename)?.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        var asset: AVURLAsset
        if let p = localPath {
            existsLocal = FileManager.default.fileExists(atPath: p)
        }
        
        if existsLocal, let p = localPath {
            let u = URL(fileURLWithPath: p)
            print("⚽️ play from cache \(u.absoluteString)\n")
            asset = AVURLAsset(url: u)
        } else {
            debugPrint("⚽️ play remote \(url.absoluteString)")
            guard let urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
                fatalError("Urls without a scheme are not supported")
            }
            resourceLoaderDelegate = ResourceLoaderDelegate()
            asset = AVURLAsset(url: urlWithCustomScheme)
            asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        }
        
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        
        if !existsLocal {
            resourceLoaderDelegate?.owner = self
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
        debugPrint("⚽️ CachingPlayerItem.deinit")
        resourceLoaderDelegate?.session?.invalidateAndCancel()
    }
    
    static func getCacheDirectoryPath() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
    }
    
    static func getFilePath(url: URL, filename: String) -> URL {
        let cacheDirPath = "\(Self.getCacheDirectoryPath())cache-videos".replacingOccurrences(
            of: "file://", with: ""
        )
        if (!FileManager.default.fileExists(atPath: cacheDirPath)) {
            try! FileManager.default.createDirectory(
                atPath: cacheDirPath,
                withIntermediateDirectories: true
            )
        }
        return URL(string: "\(cacheDirPath)/\(filename)")!
    }
    
}

extension CachingPlayerItem: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        PINDiskCache.shared.setObjectAsync(data as NSData, forKey: playerItem.filename) { [playerItem] _,_,_ in
            print("⚽️ did save \(playerItem.url)\n")
        }
        
//        DispatchQueue.global().async { [weak self] in
//            PINDiskCache.shared.setObject(data as NSData, forKey: playerItem.filename)
//
//            let url = Self.getFilePath(url: playerItem.url, filename: playerItem.filename)
//            if FileManager.default.fileExists(atPath: url.absoluteString) {
//                try? FileManager.default.removeItem(at: url)
//            }
//            try! data.write(to: URL(fileURLWithPath: url.absoluteString))
//            guard let self = self else { return }
//            //self.resourceLoaderDelegate?.session?.invalidateAndCancel()
//            //self.resourceLoaderDelegate = nil
//            //self.delegate = nil
//            print("⚽️ did save \(playerItem.url) -> \(url.absoluteString)\n")
//        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print("⚽️ error \(error)")
    }
}
