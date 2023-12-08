

#include "JsiVideoManager.h"

#include <utility>
#include "iostream"

using namespace facebook;
using namespace facebook::jni;

using TSelf = local_ref<HybridClass<JsiVideoManager>::jhybriddata>;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
    return facebook::jni::initialize(vm, [] {
        JsiVideoManager::registerNatives();
    });
}

// JNI binding
void JsiVideoManager::registerNatives() {
    __android_log_print(ANDROID_LOG_VERBOSE, "😇", "registerNatives");
    registerHybrid({
                           makeNativeMethod("initHybrid",
                                            JsiVideoManager::initHybrid),
                           makeNativeMethod("installJSIBindings",
                                            JsiVideoManager::installJSIBindings),
                   });
}


JsiVideoManager::JsiVideoManager(
        jni::alias_ref<JsiVideoManager::javaobject> jThis,
        jsi::Runtime *rt)
        : javaPart_(jni::make_global(jThis)),
          runtime_(rt){}

// JNI init
TSelf JsiVideoManager::initHybrid(
        alias_ref<jhybridobject> jThis,
        jlong jsContext,
        jni::alias_ref<facebook::react::CallInvokerHolder::javaobject>
        jsCallInvokerHolder) {

    __android_log_write(ANDROID_LOG_INFO, "🥲", "initHybrid...");
    return makeCxxInstance(jThis, (jsi::Runtime *) jsContext);
}

void JsiVideoManager::installJSIBindings() {
    __android_log_print(ANDROID_LOG_VERBOSE, "😇", "registerJsiBindings");

    auto playVideo = JSI_HOST_FUNCTION("playVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);;
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);;

        auto method = javaPart_->getClass()->getMethod<void(jni::local_ref<JString>, jni::local_ref<JString>)>("playVideo");
        method(javaPart_.get(), jni::make_jstring(rawChannel), jni::make_jstring(rawVideoId));

        return jsi::Value::undefined();
    });

    auto pauseVideo = JSI_HOST_FUNCTION("pauseVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);


        auto method = javaPart_->getClass()->getMethod<void(jni::local_ref<JString>, jni::local_ref<JString>)>("pauseVideo");
        method(javaPart_.get(), jni::make_jstring(rawChannel), jni::make_jstring(rawVideoId));

        return jsi::Value::undefined();
    });

    auto togglePlayInBackground = JSI_HOST_FUNCTION("togglePlayInBackground", 2) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }

        auto playInBackground = args[1].asBool();
        auto method = javaPart_->getClass()->getMethod<void(jni::local_ref<JString>, jboolean)>("togglePlayInBackground");
        method(javaPart_.get(), jni::make_jstring(rawChannel), playInBackground);
        return jsi::Value::undefined();
    });

    auto restoreLastPlaying = JSI_HOST_FUNCTION("restoreLastPlaying", 2) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }

        auto shouldSeekToStart = args[1].asBool();
        auto method = javaPart_->getClass()->getMethod<void(jni::local_ref<JString>, jboolean)>("restoreLastPlaying");
        method(javaPart_.get(), jni::make_jstring(rawChannel), shouldSeekToStart);

        return jsi::Value::undefined();
    });

    auto pauseCurrentPlayingWithLaterRestore = JSI_HOST_FUNCTION("pauseCurrentPlayingWithLaterRestore", 1) {
        std::string rawChannel;
        if (!args[0].isUndefined() && !args[0].isNull()) {
            rawChannel = args[0].asString(runtime).utf8(runtime);
        }
        auto method = javaPart_->getClass()->getMethod<void(jni::local_ref<JString>)>("pauseCurrentPlayingWithLaterRestore");
        method(javaPart_.get(), jni::make_jstring(rawChannel));

        return jsi::Value::undefined();
    });

    auto togglePlayVideo = JSI_HOST_FUNCTION("togglePlayVideo", 2) {
        auto rawChannel = args[0].asString(runtime).utf8(runtime);
        auto rawVideoId = args[1].asString(runtime).utf8(runtime);

        auto method = javaPart_->getClass()->getMethod<void(jni::local_ref<JString>, jni::local_ref<JString>)>("togglePlayVideo");
        method(javaPart_.get(), jni::make_jstring(rawChannel), jni::make_jstring(rawVideoId));

        return jsi::Value::undefined();
    });

    auto toggleVideosMuted = JSI_HOST_FUNCTION("toggleVideosMuted", 1) {
        auto isMuted = args[0].asBool();
        auto method = javaPart_->getClass()->getMethod<void(jboolean)>("toggleVideosMuted");
        method(javaPart_.get(), isMuted);

        return jsi::Value::undefined();
    });

    auto pauseCurrentPlaying = JSI_HOST_FUNCTION("pauseCurrentPlaying", 0) {
        auto method = javaPart_->getClass()->getMethod<void()>("pauseCurrentPlaying");
        method(javaPart_.get());
        return jsi::Value::undefined();
    });


    jsi::Object viewHelpers = jsi::Object(*runtime_);
    viewHelpers.setProperty(*runtime_, "playVideo", std::move(playVideo));
    viewHelpers.setProperty(*runtime_, "pauseVideo", std::move(pauseVideo));
    viewHelpers.setProperty(*runtime_, "togglePlayInBackground", std::move(togglePlayInBackground));
    viewHelpers.setProperty(*runtime_, "restoreLastPlaying", std::move(restoreLastPlaying));
    viewHelpers.setProperty(*runtime_, "pauseCurrentPlayingWithLaterRestore", std::move(pauseCurrentPlayingWithLaterRestore));
    viewHelpers.setProperty(*runtime_, "togglePlayVideo", std::move(togglePlayVideo));
    viewHelpers.setProperty(*runtime_, "toggleVideosMuted", std::move(toggleVideosMuted));
    viewHelpers.setProperty(*runtime_, "pauseCurrentPlaying", std::move(pauseCurrentPlaying));
    runtime_->global().setProperty(*runtime_, "__lookyVideo", std::move(viewHelpers));
}
