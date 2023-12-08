
#import "JsiVideoManager.h"
#import <React/RCTBridge+Private.h>
#import <jsi/jsi.h>
#import "rn_video-Swift.h"

using namespace facebook;


@interface JsiVideoManager() {
    RCTCxxBridge *_cxxBridge;
    RCTBridge *_bridge;
    jsi::Runtime *_runtime;
    
#define JSI_HOST_FUNCTION(NAME, ARGS_COUNT)                                   \
    jsi::Function::createFromHostFunction(              \
        *_runtime,                                      \
        jsi::PropNameID::forUtf8(*_runtime, NAME),      \
        ARGS_COUNT,                                     \
        [=](jsi::Runtime &runtime,                      \
            const jsi::Value &thisArg,                  \
            const jsi::Value *args,                     \
            size_t count) -> jsi::Value
    
#define FromJSIString(string)                           \
    [[NSString alloc] initWithCString:string.c_str() encoding:NSUTF8StringEncoding]
}

@end

@implementation JsiVideoManager

RCT_EXPORT_MODULE()



RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(install) {
    _bridge = [RCTBridge currentBridge];
    _cxxBridge = (RCTCxxBridge*)_bridge;
    if (_cxxBridge == nil) return @false;
    _runtime = (jsi::Runtime*) _cxxBridge.runtime;
    if (_runtime == nil) return @false;
    auto& runtime = *_runtime;
    
    auto playVideo = JSI_HOST_FUNCTION("playVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);;
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);;
        
        [AppVideosManager.shared playVideo:FromJSIString(rawChannel)
                                   videoId:FromJSIString(rawVideoId)];
        
        return jsi::Value::undefined();
    });
    
    auto pauseVideo = JSI_HOST_FUNCTION("pauseVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        
        [AppVideosManager.shared pauseVideo:FromJSIString(rawChannel)
                                    videoId:FromJSIString(rawVideoId)];
        
        return jsi::Value::undefined();
    });
    
    auto togglePlayInBackground = JSI_HOST_FUNCTION("togglePlayInBackground", 2) {
        std::string rawChannel = "";
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        
        auto playInBackground = args[1].asBool();
        
        [AppVideosManager.shared togglePlayInBackground:FromJSIString(rawChannel)
                                       playInBackground:playInBackground == 1];
        
        return jsi::Value::undefined();
    });
    
    auto restoreLastPlaying = JSI_HOST_FUNCTION("restoreLastPlaying", 2) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        
        auto shouldSeekToStart = args[1].asBool();
        
        [AppVideosManager.shared restoreLastPlaying:FromJSIString(rawChannel)
                                  shouldSeekToStart:shouldSeekToStart];
        
        return jsi::Value::undefined();
    });
    
    auto pauseCurrentPlayingWithLaterRestore = JSI_HOST_FUNCTION("pauseCurrentPlayingWithLaterRestore", 2) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        
        [AppVideosManager.shared pauseCurrentPlayingWithLaterRestore:FromJSIString(rawChannel)];
        
        return jsi::Value::undefined();
    });
    
    auto togglePlayVideo = JSI_HOST_FUNCTION("togglePlayVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        
        [AppVideosManager.shared togglePlayVideo:FromJSIString(rawChannel)
                                         videoId:FromJSIString(rawVideoId)];
        
        return jsi::Value::undefined();
    });
    
    auto toggleVideosMuted = JSI_HOST_FUNCTION("toggleVideosMuted", 1) {
        auto isMuted = args[0].asBool();
        
        [AppVideosManager.shared toggleVideosMuted:isMuted == 1];
        
        return jsi::Value::undefined();
    });
    
    auto pauseCurrentPlaying = JSI_HOST_FUNCTION("pauseCurrentPlaying", 0) {
        
        [AppVideosManager.shared pauseCurrentPlaying];
        
        return jsi::Value::undefined();
    });
    
    
    jsi::Object viewHelpers = jsi::Object(runtime);
    viewHelpers.setProperty(runtime, "playVideo", std::move(playVideo));
    viewHelpers.setProperty(runtime, "pauseVideo", std::move(pauseVideo));
    viewHelpers.setProperty(runtime, "togglePlayInBackground", std::move(togglePlayInBackground));
    viewHelpers.setProperty(runtime, "restoreLastPlaying", std::move(restoreLastPlaying));
    viewHelpers.setProperty(runtime, "pauseCurrentPlayingWithLaterRestore", std::move(pauseCurrentPlayingWithLaterRestore));
    viewHelpers.setProperty(runtime, "togglePlayVideo", std::move(togglePlayVideo));
    viewHelpers.setProperty(runtime, "toggleVideosMuted", std::move(toggleVideosMuted));
    viewHelpers.setProperty(runtime, "pauseCurrentPlaying", std::move(pauseCurrentPlaying));
    runtime.global().setProperty(runtime, "__lookyVideo", std::move(viewHelpers));
    
    return @true;
}

@end
