package com.video;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class JsiVideoModule extends ReactContextBaseJavaModule {
  public static final String NAME = "JsiVideoManager";
  private final JsiVideoManager jsiVideoManager;

  public JsiVideoModule(ReactApplicationContext reactContext) {
    super(reactContext);
    jsiVideoManager = new JsiVideoManager(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  public void install() {
    jsiVideoManager.install();
  }
}

