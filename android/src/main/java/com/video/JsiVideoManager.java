package com.video;


import androidx.annotation.Nullable;

import com.facebook.jni.HybridData;
import com.facebook.jni.annotations.DoNotStrip;
import com.facebook.react.bridge.JavaScriptContextHolder;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.turbomodule.core.CallInvokerHolderImpl;
import com.facebook.react.turbomodule.core.interfaces.CallInvokerHolder;

public class JsiVideoManager {
  private final ReactApplicationContext context;

  @DoNotStrip
  @SuppressWarnings("unused")
  HybridData mHybridData;

  public native HybridData initHybrid(long jsContext, CallInvokerHolderImpl jsCallInvokerHolder);
  public native void installJSIBindings();

  public JsiVideoManager(ReactApplicationContext reactContext) {
    context = reactContext;
  }

  public boolean install() {
    try {
      System.loadLibrary("react-native-jsi-looky-video-manager");
      JavaScriptContextHolder jsContext = context.getJavaScriptContextHolder();
      CallInvokerHolder jsCallInvokerHolder = context.getCatalystInstance().getJSCallInvokerHolder();
      mHybridData = initHybrid(jsContext.get(), (CallInvokerHolderImpl) jsCallInvokerHolder);
      installJSIBindings();
      return true;
    } catch (Exception exception) {
      return false;
    }
  }

  @DoNotStrip
  public void playVideo(String channel, String videoId) {
    System.out.println("playVideo");
  }

  @DoNotStrip
  public void pauseVideo(String channel, String videoId) {
    System.out.println("pauseVideo");
  }

  @DoNotStrip
  public void togglePlayInBackground(@Nullable String channel, Boolean playInBackground) {}

  @DoNotStrip
  public void restoreLastPlaying(@Nullable String channel, Boolean shouldSeekToStart) {}

  @DoNotStrip
  public void pauseCurrentPlayingWithLaterRestore(@Nullable String channel) {}

  @DoNotStrip
  public void togglePlayVideo(String channel, String videoId) {}

  @DoNotStrip
  public void toggleVideosMuted(Boolean muted) {}

  @DoNotStrip
  public void pauseCurrentPlaying() {}
}
