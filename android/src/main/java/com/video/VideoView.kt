package com.video

import android.view.View
import com.facebook.react.uimanager.ThemedReactContext

class VideoView(themedReactContext: ThemedReactContext?) : ReactVideoView(themedReactContext) {

  init {
      setOnClickListener(DoubleClick(object : DoubleClick.DoubleClickListener {
        override fun onSingleClick(view: View) {
          mEventEmitter.receiveEvent(id, "onVideoTap", null)
        }

        override fun onDoubleClick(view: View) {
          mEventEmitter.receiveEvent(id, "onVideoDoubleTap", null)
        }

      }))
  }

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
