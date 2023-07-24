import { NativeModules, Platform } from 'react-native';

const LookyVideosManager = NativeModules.VideosController;

const IS_IOS = Platform.OS === 'ios';

const _log = (methodName: string, args?: any) =>
  console.log(
    `rn-video.${methodName}(${args ? JSON.stringify(args, undefined, 2) : ''})`
  );
const warnAboutNonIosPlatform = () =>
  console.warn(
    'trying to call a method from iOS VideosController on a different platform. Consider using Looky Video Manager'
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
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.playVideo(channel, videoId);
}

export function pauseCurrentPlaying() {
  _log(pauseCurrentPlaying.name);
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.pauseCurrentPlaying();
}

export function togglePlayInBackground(
  channelName: string | undefined,
  playInBackground: boolean
) {
  _log(togglePlayInBackground.name, { channelName, playInBackground });
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.togglePlayInBackground(channelName, playInBackground);
}

export function pauseCurrentPlayingWithLaterRestore(
  channelName: string | undefined
) {
  _log(pauseCurrentPlayingWithLaterRestore.name, { channelName });
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.pauseCurrentPlayingWithLaterRestore(channelName);
}

export function restoreLastPlaying(
  channelName: string | undefined,
  shouldSeekToStart: boolean = true
) {
  _log(restoreLastPlaying.name, { channelName, shouldSeekToStart });
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.restoreLastPlaying(channelName, shouldSeekToStart);
}

export function togglePlayVideo(channel: string, videoId: string) {
  _log(togglePlayVideo.name, { channel, videoId });
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.togglePlay(channel, videoId);
}

export function toggleVideosMuted(muted: boolean) {
  _log(toggleVideosMuted.name, { muted });
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.toggleVideosMuted(muted);
}

export function toggleVideosMutedEvent(event: {
  nativeEvent: { muted: boolean };
}) {
  _log(toggleVideosMutedEvent.name, { event });
  if (!IS_IOS) return warnAboutNonIosPlatform();
  LookyVideosManager.toggleVideosMuted(event.nativeEvent.muted);
}
