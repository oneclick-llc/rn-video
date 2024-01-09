package com.video

import android.os.Handler
import android.os.Looper
import java.util.concurrent.ConcurrentHashMap

typealias LookyVideoView = VideoView

class VideoChannel {
  var videos = ConcurrentHashMap<String, LookyVideoView>()
  var laterRestore: String? = null
  var backgroundRestore: String? = null

  val currentPlaying: MutableMap.MutableEntry<String, LookyVideoView>?
    get() {
      for (video in videos) {
        if (video.value.isSafePlaying()) return video
      }
      return null
    }

  val forRestore: LookyVideoView?
    get() {
      backgroundRestore ?: return null
      return videos[backgroundRestore]
    }

  fun pauseAllVideos() {
    for (entry in videos) {
      if (entry.value.isSafePlaying())
        entry.value.setPausedModifier(true)
    }
  }

  fun toggleMuted(muted: Boolean) {
    for (entry in videos) {
      entry.value.setMutedModifier(muted)
    }
  }

  fun video(videoId: String) = videos[videoId]
}

class AppVideosManager {
  companion object {
    val shared = AppVideosManager()
  }

  val channels = ConcurrentHashMap<String, VideoChannel>()
  val handler = Handler(Looper.getMainLooper())

  fun addVideo(video: LookyVideoView, nativeID: String) {
    val parts = nativeID.split(":")
    val channelName = parts[0]
    val id = parts[1]
    println("🍓 addVideo $channelName $id")

    val channel = getChannel(channelName)?.also {
      it.videos[id] = video
    }

    if (channel?.laterRestore == id) {
      video.setPausedModifier(false)
      channel.laterRestore = null
    } else {
      video.showPoster(true)
    }
  }

  fun removeVideo(nativeID: String) {
    val parts = nativeID.split(":")
    val channelName = parts[0]
    val id = parts[1]
    println("🍓 removeVideo $channelName $id")

    val channel = getChannel(channelName)
    channel?.videos?.remove(id)
    if (channel?.videos?.isEmpty() == true) {
      channels.remove(channelName)
    }
  }
}

// MARK: public api
fun AppVideosManager.playVideo(channelName: String, videoId: String) {
  val channel = getChannel(channelName) ?: return
  if (channel.currentPlaying?.key == videoId) { return }
  pauseCurrentPlaying()
  val video = channel.video(videoId) ?: return
  println("🍓 playVideo $channelName, $videoId")
  video.setPausedModifier(false)
}

fun AppVideosManager.pauseVideo(channelName: String, videoId: String) {
  val channel = getChannel(channelName) ?: return
  val video = channel.video(videoId) ?: return
  if (!video.isSafePlaying()) return
  println("🍓 pauseVideo $channelName, $videoId")
  video.setPausedModifier(true)
}

fun AppVideosManager.togglePlayInBackground(channelName: String?, playInBackground: Boolean) {}

fun AppVideosManager.restoreLastPlaying(channelName: String?, shouldSeekToStart: Boolean) {
  pauseAllVideos()
  println("🍓 restoreLastPlaying $channelName")
  if (channelName != null) {
    val videoChannel = getChannel(channelName)
    val restore = videoChannel?.laterRestore
    if (restore != null) {
      togglePlay(channel = channelName, videoId = restore, seekToStart = true)
    }
    return
  }

  for (entry in channels) {
    if (entry.value.laterRestore == null) continue
    togglePlay(
      channel = entry.key,
      videoId = entry.value.laterRestore!!,
      seekToStart = true
    )
    entry.value.laterRestore = null
  }
}

fun AppVideosManager.pauseCurrentPlayingWithLaterRestore(channelName: String?) {
  if (channelName != null) {
    val videoChannel = getChannel(channelName) ?: return
    val video = findFirstPlayingVideo(channelName) ?: return
    videoChannel.laterRestore = videoId(video)
    video.setPausedModifier(true)
    return
  }

  for (entry in channels) {
    val channel = entry.value
    val video = findFirstPlayingVideo(entry.key)
    channel.laterRestore = videoId(video)
    video?.setPausedModifier(true)
  }
}

fun AppVideosManager.togglePlayVideo(channelName: String, videoId: String) {
  val video = findFirstPlayingVideo(channelName)
  if (video != null) { pauseCurrentPlaying() }
  else { playVideo(channelName, videoId) }
}

fun AppVideosManager.toggleVideosMuted(muted: Boolean) {
  for (entry in channels) {
    entry.value.toggleMuted(muted)
  }
}

fun AppVideosManager.pauseCurrentPlaying() {
  pauseAllVideos()
}

fun AppVideosManager.isPaused(channel: String, videoId: String): Boolean {
  return getChannel(channel)?.video(videoId)?.mPaused == true
}

fun AppVideosManager.isMuted(channel: String, videoId: String): Boolean {
  return getChannel(channel)?.video(videoId)?.mMuted == true
}

fun AppVideosManager.seek(channel: String, videoId: String, duration: Double) {
  getChannel(channel)?.video(videoId)?.seekTo((duration / 1000.0).toInt())
}

fun AppVideosManager.playAll(channelName: String) {
  val channel = getChannel(channelName) ?: return
  for (video in channel.videos) {
    video.value.setPausedModifier(false)
  }
}

fun AppVideosManager.pauseAll(channelName: String) {
  val channel = getChannel(channelName) ?: return
  for (video in channel.videos) {
    video.value.setPausedModifier(true)
  }
}


fun AppVideosManager.togglePlay(channel: String, videoId: String, seekToStart: Boolean) {
  val videoChannel = getChannel(channel) ?: return

  val playingVideo = findFirstPlayingVideo(channel)
  val video = videoChannel.video(videoId)
  val playingVideId = videoId(playingVideo)

  // pause current playing video
  if (playingVideId != null && playingVideId != videoId) {
    playingVideo?.setPausedModifier(true)
  }

  if (video != null) {
    if (seekToStart) video.seekTo(0)
    video.setPausedModifier(false)
  }
}

fun AppVideosManager.videoId(video: LookyVideoView?): String? {
  video ?: return null
  val parts = (video.getTag(R.id.view_tag_native_id) as? String)?.split(":")
  return parts?.get(1)
}

fun AppVideosManager.getChannel(name: String?): VideoChannel? {
  name ?: return null
  val channel = channels[name] ?: VideoChannel()
  channels[name] = channel
  return channel
}

fun AppVideosManager.pauseVideo(channel: VideoChannel) {
  channel.currentPlaying?.value?.setPausedModifier(true)
}

fun AppVideosManager.pauseAllVideos() {
  for (entry in channels) {
    entry.value.pauseAllVideos()
  }
}

fun AppVideosManager.findFirstPlayingVideo(): LookyVideoView? {
  for (entry in channels) {
    entry.value.currentPlaying?.let { return it.value }
  }
  return null
}

fun AppVideosManager.findFirstPlayingVideo(channelName: String?): LookyVideoView? {
  channelName ?: return null
  val channel = getChannel(channelName) ?: return null
  return channel.currentPlaying?.value
}
