package com.video

import com.facebook.react.uimanager.ThemedReactContext

class VideoView(themedReactContext: ThemedReactContext?) : ReactVideoView(themedReactContext) {

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    val id = getTag(R.id.view_tag_native_id) as? String
    if (id == null) {
      return println("🍓 WARNING: videoId didn't passed")
    }
    AppVideosManager.shared.addVideo(this, id)
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    val id = getTag(R.id.view_tag_native_id) as? String
    if (id == null) {
      return println("🍓 WARNING: videoId didn't passed")
    }
    AppVideosManager.shared.removeVideo(id)
  }
}
