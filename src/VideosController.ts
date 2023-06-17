import { NativeModules } from 'react-native';

const LookyVideosManager = NativeModules.VideosController;

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

export function playVideo(channel: string, videoId: string) {
  LookyVideosManager.playVideo(channel, videoId);
}

export function pauseCurrentPlaying() {
  LookyVideosManager.pauseCurrentPlaying();
}

export function pauseCurrentPlayingWithLaterRestore(
  channelName: string | undefined
) {
  LookyVideosManager.pauseCurrentPlayingWithLaterRestore(channelName);
}

export function restoreLastPlaying(channelName: string | undefined) {
  LookyVideosManager.restoreLastPlaying(channelName);
}

export function togglePlayVideo(channel: string, videoId: string) {
  LookyVideosManager.togglePlay(channel, videoId);
}

export function toggleVideosMuted(muted: boolean) {
  LookyVideosManager.toggleVideosMuted(muted);
}

export function toggleVideosMutedEvent(event: {
  nativeEvent: { muted: boolean };
}) {
  LookyVideosManager.toggleVideosMuted(event.nativeEvent.muted);
}
