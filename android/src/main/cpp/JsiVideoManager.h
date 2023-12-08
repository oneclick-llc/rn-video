
#include <fbjni/fbjni.h>
#include <jsi/jsi.h>
#include <ReactCommon/CallInvokerHolder.h>

#define JSI_HOST_FUNCTION(NAME, ARGS_COUNT)             \
    jsi::Function::createFromHostFunction(              \
        *runtime_,                                      \
        jsi::PropNameID::forUtf8(*runtime_, NAME),      \
        ARGS_COUNT,                                     \
        [=](jsi::Runtime &runtime,                      \
            const jsi::Value &thisArg,                  \
            const jsi::Value *args,                     \
            size_t count) -> jsi::Value

class JsiVideoManager : public facebook::jni::HybridClass<JsiVideoManager> {

public:
    static constexpr auto kJavaDescriptor = "Lcom/video/JsiVideoManager;";
    static facebook::jni::local_ref<jhybriddata> initHybrid(
            facebook::jni::alias_ref<jhybridobject> jThis,
            jlong jsContext,
            facebook::jni::alias_ref<facebook::react::CallInvokerHolder::javaobject> jsCallInvokerHolder);

    static void registerNatives();

    void installJSIBindings();

private:
    friend HybridBase;
    facebook::jni::global_ref<JsiVideoManager::javaobject> javaPart_;
    facebook::jsi::Runtime *runtime_;
    explicit JsiVideoManager(
            facebook::jni::alias_ref<JsiVideoManager::jhybridobject> jThis,
            facebook::jsi::Runtime *rt);
};
