package com.video

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext

@ReactModule(name = VideoViewManager.NAME)
class VideoViewManager : SimpleViewManager<VideoView>() {


  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): VideoView {
    return VideoView(context)
  }

  companion object {
    const val NAME = "VideoView"
  }
}
