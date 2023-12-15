import { NativeModules } from 'react-native';

NativeModules.JsiVideoManager.install();

declare global {
  var __lookyVideo: {
    isPaused(channel: string, videoId: string): boolean;
    isMuted(channel: string, videoId: string): boolean;
    seek(channel: string, videoId: string, duration: number): void;
    playVideo(channel: string, videoId: string): void;
    pauseVideo(channel: string, videoId: string): void;
    togglePlayInBackground(
      channelName: string | undefined,
      playInBackground: boolean
    ): void;
    restoreLastPlaying(
      channelName: string | undefined,
      shouldSeekToStart: boolean
    ): void;
    pauseCurrentPlayingWithLaterRestore(channelName: string | undefined): void;
    togglePlayVideo(channel: string, videoId: string): void;
    toggleVideosMuted(muted: boolean): void;
    pauseCurrentPlaying(): void;
  };
}

export const videoController = {
  getId(channelName: string, postId?: string, pagerIndex?: number) {
    if (postId && pagerIndex) return `${channelName}:${postId}_${pagerIndex}`;
    else if (postId) return `${channelName}:${postId}`;

    throw new Error('postId is undefined');
  },

  getVideoId(postId?: string, pagerIndex?: number) {
    if (postId && pagerIndex) return `${postId}_${pagerIndex}`;
    throw new Error('postId is undefined');
  },

  getIdWithoutChannel(postId?: string, pagerIndex?: number) {
    if (postId && pagerIndex) return `${postId}_${pagerIndex}`;
    else if (postId) return `${postId}`;

    throw new Error('postId is undefined');
  },

  pause(channelName: string, videoId: string) {
    console.log('🍓[VideoManager.pauseVideo]', { channelName, videoId });
    global.__lookyVideo.pauseVideo(channelName, videoId);
  },

  play(channel: string, videoId: string) {
    console.log('🍓[VideosController.playVideo]', channel, videoId);
    global.__lookyVideo.playVideo(channel, videoId);
  },

  playWithId(nativeId: string) {
    console.log('🍓[VideosController.playVideo]', nativeId);
    const [channel, id] = nativeId.split(':');
    if (!channel || !id) return;
    global.__lookyVideo.playVideo(channel, id);
  },

  pauseWithId(nativeId: string) {
    console.log('🍓[VideosController.pauseWithId]', nativeId);
    const [channel, id] = nativeId.split(':');
    if (!channel || !id) return;
    global.__lookyVideo.pauseVideo(channel, id);
  },

  pauseCurrentPlaying() {
    console.log('🍓[VideosController.pauseCurrentPlaying]');
    global.__lookyVideo.pauseCurrentPlaying();
  },

  pauseCurrentPlayingWithLaterRestore(channelName: string | undefined) {
    console.log('🍓[VideosController.pauseCurrentPlayingWithLaterRestore]');
    global.__lookyVideo.pauseCurrentPlayingWithLaterRestore(channelName);
  },

  togglePlayInBackground(
    channelName: string | undefined,
    playInBackground: boolean
  ) {
    global.__lookyVideo.togglePlayInBackground(channelName, playInBackground);
  },

  restoreLastPlaying(
    channelName: string | undefined,
    shouldSeekToStart: boolean = true
  ) {
    global.__lookyVideo.restoreLastPlaying(channelName, shouldSeekToStart);
  },

  togglePlay(channel: string, videoId: string) {
    global.__lookyVideo.togglePlayVideo(channel, videoId);
  },

  toggleMuted(muted: boolean) {
    global.__lookyVideo.toggleVideosMuted(muted);
  },

  isPaused(channel: string, videoId: string) {
    return global.__lookyVideo.isPaused(channel, videoId);
  },

  isMuted(channel: string, videoId: string) {
    return global.__lookyVideo.isMuted(channel, videoId);
  },

  seek(channel: string, videoId: string, duration: number) {
    global.__lookyVideo.seek(channel, videoId, duration);
  },
};
