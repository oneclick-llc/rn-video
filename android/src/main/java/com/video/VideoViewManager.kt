package com.video

import com.facebook.react.bridge.Arguments
import com.facebook.react.common.MapBuilder
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.yqritc.scalablevideoview.ScalableType

@ReactModule(name = VideoViewManager.NAME)
class VideoViewManager : ReactVideoViewManager() {


  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): VideoView {
    return VideoView(context)
  }

  companion object {
    const val NAME = "LookyVideoView"
  }

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<Any?, Any?> {
    val superResult = super.getExportedCustomDirectEventTypeConstants()!!

    return superResult
  }

  @ReactProp(name = "videoUri")
  fun videoUri(videoView: VideoView, videoUri: String) {
    val isNetwork = videoUri.startsWith("http")
    var isAsset = false
    if (videoUri.startsWith("assets-library:")) isAsset = true
    if (videoUri.startsWith("ipod-library:")) isAsset = true
    if (videoUri.startsWith("file:")) isAsset = true
    if (videoUri.startsWith("content:")) isAsset = true
    if (videoUri.startsWith("ms-appx:")) isAsset = true
    if (videoUri.startsWith("ms-appdata:")) isAsset = true
    videoView.setSrc(videoUri, "", isNetwork, isAsset, Arguments.createMap())
  }

  @ReactProp(name = "resizeMode")
  fun resizeMode(videoView: VideoView, resizeMode: String) {
    if (resizeMode == "cover") { videoView.setResizeModeModifier(ScalableType.FIT_CENTER) }
    if (resizeMode == "contain") { videoView.setResizeModeModifier(ScalableType.FIT_START) }
    if (resizeMode == "stretch") { videoView.setResizeModeModifier(ScalableType.FIT_XY) }
  }

  @ReactProp(name = "muted")
  fun muted(videoView: VideoView, muted: Boolean) {
    videoView.setMutedModifier(muted)
  }

  @ReactProp(name = "loop")
  fun loop(videoView: VideoView, loop: Boolean) {
    videoView.setRepeatModifier(loop)
  }
}
