
#import "JsiVideoManager.h"
#import <React/RCTBridge+Private.h>
#import <jsi/jsi.h>
#import "rn_video-Swift.h"

using namespace facebook;


@interface JsiVideoManager() {
    RCTCxxBridge *_cxxBridge;
    RCTBridge *_bridge;
    jsi::Runtime *_runtime;
    
#define JSI_HOST_FUNCTION(NAME, ARGS_COUNT)             \
    jsi::Function::createFromHostFunction(              \
        *_runtime,                                      \
        jsi::PropNameID::forUtf8(*_runtime, NAME),      \
        ARGS_COUNT,                                     \
        [=](jsi::Runtime &runtime,                      \
            const jsi::Value &thisArg,                  \
            const jsi::Value *args,                     \
            size_t count) -> jsi::Value
    
}

@end

@implementation JsiVideoManager

NSString* fromJSIString(std::string string) {
    if (string.length() == 0) return nil;
    return [[NSString alloc] initWithCString:string.c_str() encoding:NSUTF8StringEncoding];
};

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
        
        [AppVideosManager.shared playVideo:fromJSIString(rawChannel)
                                   videoId:fromJSIString(rawVideoId)];
        
        return jsi::Value::undefined();
    });
    
    auto pauseVideo = JSI_HOST_FUNCTION("pauseVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        
        [AppVideosManager.shared pauseVideo:fromJSIString(rawChannel)
                                    videoId:fromJSIString(rawVideoId)];
        
        return jsi::Value::undefined();
    });
    
    auto togglePlayInBackground = JSI_HOST_FUNCTION("togglePlayInBackground", 2) {
        std::string rawChannel = "";
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        
        auto playInBackground = args[1].asBool();
        [AppVideosManager.shared togglePlayInBackground:fromJSIString(rawChannel)
                                       playInBackground:playInBackground == 1];
        
        return jsi::Value::undefined();
    });
    
    auto restoreLastPlaying = JSI_HOST_FUNCTION("restoreLastPlaying", 2) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        
        auto shouldSeekToStart = args[1].asBool();
        
        [AppVideosManager.shared restoreLastPlaying:fromJSIString(rawChannel)
                                  shouldSeekToStart:shouldSeekToStart];
        
        return jsi::Value::undefined();
    });
    
    auto pauseCurrentPlayingWithLaterRestore = JSI_HOST_FUNCTION("pauseCurrentPlayingWithLaterRestore", 2) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        
        [AppVideosManager.shared pauseCurrentPlayingWithLaterRestore:fromJSIString(rawChannel)];
        
        return jsi::Value::undefined();
    });
    
    auto togglePlayVideo = JSI_HOST_FUNCTION("togglePlayVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        
        [AppVideosManager.shared togglePlayVideo:fromJSIString(rawChannel)
                                         videoId:fromJSIString(rawVideoId)];
        
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
    
    auto isPaused = JSI_HOST_FUNCTION("isPaused", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        
        auto isPaused = [AppVideosManager.shared isPaused:fromJSIString(rawChannel)
                                                         videoId:fromJSIString(rawVideoId)];
        
        return jsi::Value(isPaused);
    });
    
    auto isMuted = JSI_HOST_FUNCTION("isMuted", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        
        auto isPaused = [AppVideosManager.shared isMuted:fromJSIString(rawChannel)
                                                         videoId:fromJSIString(rawVideoId)];
        
        return jsi::Value(isPaused);
    });
    
    auto seek = JSI_HOST_FUNCTION("seek", 3) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);
        auto rawDuration = args[2].asNumber();
        
        [AppVideosManager.shared seek:fromJSIString(rawChannel)
                              videoId:fromJSIString(rawVideoId)
                             duration:rawDuration];
        
        return jsi::Value::undefined();
    });
    
    auto pauseAll = JSI_HOST_FUNCTION("pauseAll", 1) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        
        [AppVideosManager.shared pauseAll:fromJSIString(rawChannel)];
        return jsi::Value::undefined();
    });
    
    auto playAll = JSI_HOST_FUNCTION("playAll", 1) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        
        [AppVideosManager.shared playAll:fromJSIString(rawChannel)];
        return jsi::Value::undefined();
    });
    
    auto laterRestoreId = JSI_HOST_FUNCTION("laterRestoreId", 1) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        
        auto videoId = [AppVideosManager.shared laterRestoreId:fromJSIString(rawChannel)];
        return jsi::String::createFromUtf8(runtime, [videoId UTF8String]);
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
    viewHelpers.setProperty(runtime, "isPaused", std::move(isPaused));
    viewHelpers.setProperty(runtime, "isMuted", std::move(isMuted));
    viewHelpers.setProperty(runtime, "seek", std::move(seek));
    viewHelpers.setProperty(runtime, "pauseAll", std::move(pauseAll));
    viewHelpers.setProperty(runtime, "playAll", std::move(playAll));
    viewHelpers.setProperty(runtime, "laterRestoreId", std::move(laterRestoreId));
    runtime.global().setProperty(runtime, "__lookyVideo", std::move(viewHelpers));
    
    return @true;
}

@end
