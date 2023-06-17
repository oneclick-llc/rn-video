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
  console.log('🤖 [VideoManager.playVideo]', channel, videoId);
  LookyVideosManager.playVideo(channel, videoId);
}

export function pauseCurrentPlaying() {
  console.log('🤖 [VideoManager.pauseCurrentPlaying]');
  LookyVideosManager.pauseCurrentPlaying();
}

export function pauseCurrentPlayingWithLaterRestore(
  channelName: string | undefined
) {
  console.log(
    '🤖 [VideoManager.pauseCurrentPlayingWithLaterRestore]',
    channelName
  );
  LookyVideosManager.pauseCurrentPlayingWithLaterRestore(channelName);
}

export function restoreLastPlaying(channelName: string | undefined) {
  console.log('🤖 [VideoManager.restoreLastPlaying]', channelName);
  //console.log('🤖 [VideoManager.restoreLastPlaying]', new Error().stack)
  LookyVideosManager.restoreLastPlaying(channelName);
}

export function togglePlayVideo(channel: string, videoId: string) {
  console.log('🤖 [VideoManager.togglePlayVideo]', videoId);
  LookyVideosManager.togglePlay(channel, videoId);
}

export function toggleVideosMuted(muted: boolean) {
  console.log('🤖 [VideoManager.toggleVideosMuted]', muted);
  LookyVideosManager.toggleVideosMuted(muted);
}

export function toggleVideosMutedEvent(event: {
  nativeEvent: { muted: boolean };
}) {
  console.log('🤖 [VideoManager.toggleVideosMuted]', event.nativeEvent.muted);
  LookyVideosManager.toggleVideosMuted(event.nativeEvent.muted);
}
