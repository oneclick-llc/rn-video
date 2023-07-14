import { NativeModules } from 'react-native';

const LookyVideosManager = NativeModules.VideosController;

const _log = (methodName: string, args?: any) =>
  console.log(
    `rn-video.${methodName}(${args ? JSON.stringify(args, undefined, 2) : ''})`
  );

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
  _log(playVideo.name, { channel, videoId });
  LookyVideosManager.playVideo(channel, videoId);
}

export function pauseCurrentPlaying() {
  _log(pauseCurrentPlaying.name);
  LookyVideosManager.pauseCurrentPlaying();
}

export function togglePlayInBackground(
  channelName: string | undefined,
  playInBackground: boolean
) {
  _log(togglePlayInBackground.name, { channelName, playInBackground });
  LookyVideosManager.togglePlayInBackground(channelName, playInBackground);
}

export function pauseCurrentPlayingWithLaterRestore(
  channelName: string | undefined
) {
  _log(pauseCurrentPlayingWithLaterRestore.name, { channelName });
  LookyVideosManager.pauseCurrentPlayingWithLaterRestore(channelName);
}

export function restoreLastPlaying(channelName: string | undefined) {
  _log(restoreLastPlaying.name, { channelName });
  LookyVideosManager.restoreLastPlaying(channelName);
}

export function togglePlayVideo(channel: string, videoId: string) {
  _log(togglePlayVideo.name, { channel, videoId });
  LookyVideosManager.togglePlay(channel, videoId);
}

export function toggleVideosMuted(muted: boolean) {
  _log(toggleVideosMuted.name, { muted });
  LookyVideosManager.toggleVideosMuted(muted);
}

export function toggleVideosMutedEvent(event: {
  nativeEvent: { muted: boolean };
}) {
  _log(toggleVideosMutedEvent.name, { event });
  LookyVideosManager.toggleVideosMuted(event.nativeEvent.muted);
}
