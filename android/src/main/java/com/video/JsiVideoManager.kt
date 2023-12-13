package com.video

import com.facebook.jni.HybridData
import com.facebook.jni.annotations.DoNotStrip
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.turbomodule.core.CallInvokerHolderImpl

fun String?.orNull(): String? {
  if (this?.isEmpty() == true) return null
  return this
}

class JsiVideoManager(private val context: ReactApplicationContext) {
    @DoNotStrip
    @Suppress("unused")
    var mHybridData: HybridData? = null
    external fun initHybrid(
        jsContext: Long,
        jsCallInvokerHolder: CallInvokerHolderImpl?
    ): HybridData?

    external fun installJSIBindings()
    fun install(): Boolean {
        return try {
            System.loadLibrary("react-native-jsi-looky-video-manager")
            val jsContext = context.javaScriptContextHolder
            val jsCallInvokerHolder = context.catalystInstance.jsCallInvokerHolder
            mHybridData = initHybrid(jsContext.get(), jsCallInvokerHolder as CallInvokerHolderImpl)
            installJSIBindings()
            true
        } catch (exception: Exception) {
            false
        }
    }

    @DoNotStrip
    fun playVideo(channel: String, videoId: String) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.playVideo(channel, videoId)
      }
    }

    @DoNotStrip
    fun pauseVideo(channel: String, videoId: String) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.pauseVideo(channel, videoId)
      }
    }

    @DoNotStrip
    fun togglePlayInBackground(channel: String?, playInBackground: Boolean) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.togglePlayInBackground(channel?.orNull(), playInBackground)
      }
    }

    @DoNotStrip
    fun restoreLastPlaying(channel: String?, shouldSeekToStart: Boolean) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.restoreLastPlaying(channel?.orNull(), shouldSeekToStart)
      }
    }

    @DoNotStrip
    fun pauseCurrentPlayingWithLaterRestore(channel: String?) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.pauseCurrentPlayingWithLaterRestore(channel?.orNull())
      }
    }

    @DoNotStrip
    fun togglePlayVideo(channel: String, videoId: String) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.togglePlayVideo(channel, videoId)
      }
    }

    @DoNotStrip
    fun toggleVideosMuted(muted: Boolean) {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.toggleVideosMuted(muted)
      }
    }

    @DoNotStrip
    fun pauseCurrentPlaying() {
      AppVideosManager.shared.handler.post {
        AppVideosManager.shared.pauseCurrentPlaying()
      }
    }
}
