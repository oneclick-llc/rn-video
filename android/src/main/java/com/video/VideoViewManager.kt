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
    val video = VideoView(context)
    video.setPausedModifier(true)
    return video
  }

  companion object {
    const val NAME = "LookyVideoView"
  }

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<Any?, Any?> {
    val superResult = super.getExportedCustomDirectEventTypeConstants()!!

    superResult["onVideoTap"] = MapBuilder.of("registrationName", "onVideoTap")
    superResult["onVideoDoubleTap"] = MapBuilder.of("registrationName", "onVideoDoubleTap")

    return superResult
  }

  @ReactProp(name = "videoUri")
  fun videoUri(videoView: VideoView, videoUri: String) {
    val isNetwork = videoUri.startsWith("http")
    val isAsset = Regex("^(assets-library|ipod-library|file|content|ms-appx|ms-appdata):").matches(videoUri)
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
