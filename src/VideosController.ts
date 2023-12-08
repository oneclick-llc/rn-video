import { NativeModules } from 'react-native';


NativeModules.JsiVideoManager.install()

declare global {
  var __lookyVideo: {
    playVideo(channel: string, videoId: string): void
    pauseVideo(channel: string, videoId: string): void
    togglePlayInBackground(channelName: string | undefined, playInBackground: boolean): void
    restoreLastPlaying(channelName: string | undefined, shouldSeekToStart: boolean): void
    pauseCurrentPlayingWithLaterRestore(channelName: string | undefined): void
    togglePlayVideo(channel: string, videoId: string): void
    toggleVideosMuted(muted: boolean): void
    pauseCurrentPlaying(): void
  }
}

export function getIdForVideo(
  channelName: string,
  postId?: string,
  pagerIndex?: number
) {
  if (postId && pagerIndex) return `${channelName}:${postId}_${pagerIndex}`;
  else if (postId) return `${channelName}:${postId}_0`;

  throw new Error('postId is undefined');
}

export function getIdForVideoWithoutChannel(
  postId?: string,
  pagerIndex?: number
) {
  if (postId && pagerIndex) return `${postId}_${pagerIndex}`;
  else if (postId) return `${postId}_0`;

  throw new Error('postId is undefined');
}

export function pauseVideo(channelName: string, videoId: string) {
  console.log('🍓[VideoManager.pauseVideo]', { channelName, videoId })
  global.__lookyVideo.pauseVideo(channelName, videoId)
}

export function playVideo(channel: string, videoId: string) {
  console.log('🍓[VideosController.playVideo]', channel, videoId)
  global.__lookyVideo.playVideo(channel, videoId)
}

export function pauseCurrentPlaying() {
  console.log('🍓[VideosController.pauseCurrentPlaying]')
  global.__lookyVideo.pauseCurrentPlaying();
}

export function pauseCurrentPlayingWithLaterRestore(
  channelName: string | undefined
) {
  console.log('🍓[VideosController.pauseCurrentPlayingWithLaterRestore]' )
  global.__lookyVideo.pauseCurrentPlayingWithLaterRestore(channelName);
}

export function togglePlayInBackground(
  channelName: string | undefined,
  playInBackground: boolean
) {
  global.__lookyVideo.togglePlayInBackground(channelName, playInBackground);
}

export function restoreLastPlaying(channelName: string | undefined, shouldSeekToStart: boolean = true) {
  global.__lookyVideo.restoreLastPlaying(channelName, shouldSeekToStart);
}

export function togglePlayVideo(channel: string, videoId: string) {
  global.__lookyVideo.togglePlayVideo(channel, videoId);
}

export function toggleVideosMuted(muted: boolean) {
  global.__lookyVideo.toggleVideosMuted(muted);
}
