package com.video

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.VideoViewManagerInterface
import com.facebook.react.viewmanagers.VideoViewManagerDelegate
import com.facebook.soloader.SoLoader

@ReactModule(name = VideoViewManager.NAME)
class VideoViewManager : SimpleViewManager<VideoView>(),
  VideoViewManagerInterface<VideoView> {
  private val mDelegate: ViewManagerDelegate<VideoView>

  init {
    mDelegate = VideoViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<VideoView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): VideoView {
    return VideoView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: VideoView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "VideoView"

    init {
      if (BuildConfig.CODEGEN_MODULE_REGISTRATION != null) {
        SoLoader.loadLibrary(BuildConfig.CODEGEN_MODULE_REGISTRATION)
      }
    }
  }
}
