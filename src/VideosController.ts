import { AppState, NativeModules, Platform } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useEffect } from 'react';

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
    pauseAll(channelName: string): void;
    playAll(channelName: string): void;
  };
}

export const videoController = {
  getId(channelName: string, postId?: string, pagerIndex?: number) {
    return `${channelName}:${videoController.getVideoId(postId, pagerIndex)}`;
  },

  getVideoId(postId?: string, pagerIndex?: number) {
    if (postId && pagerIndex !== undefined) return `${postId}___${pagerIndex}`;
    if (postId) {
      if (postId.includes('___')) return postId.toString();
      return `${postId}___0`;
    }
    throw new Error('postId is undefined');
  },

  pause(channelName: string, videoId: string) {
    console.log('🍓[VideoManager.pauseVideo]', { channelName, videoId });
    global.__lookyVideo.pauseVideo(
      channelName,
      videoController.getVideoId(videoId)
    );
  },

  play(channel: string, videoId: string) {
    console.log('🍓[VideosController.playVideo]', channel, videoId);
    global.__lookyVideo.playVideo(channel, videoController.getVideoId(videoId));
  },

  playWithId(nativeId: string) {
    console.log('🍓[VideosController.playVideo]', nativeId);
    const [channel, videoId] = nativeId.split(':');
    if (!channel || !videoId) return;
    global.__lookyVideo.playVideo(channel, videoController.getVideoId(videoId));
  },

  pauseWithId(nativeId: string) {
    console.log('🍓[VideosController.pauseWithId]', nativeId);
    const [channel, videoId] = nativeId.split(':');
    if (!channel || !videoId) return;
    global.__lookyVideo.pauseVideo(
      channel,
      videoController.getVideoId(videoId)
    );
  },

  pauseCurrentPlaying() {
    console.log('🍓[VideosController.pauseCurrentPlaying]');
    global.__lookyVideo.pauseCurrentPlaying();
  },

  pauseAll(channelName: string) {
    console.log('🍓[VideosController.pauseAll]');
    global.__lookyVideo.pauseAll(channelName);
  },

  playAll(channelName: string) {
    console.log('🍓[VideosController.playAll]');
    global.__lookyVideo.playAll(channelName);
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
    global.__lookyVideo.togglePlayVideo(
      channel,
      videoController.getVideoId(videoId)
    );
  },

  toggleMuted(muted: boolean) {
    global.__lookyVideo.toggleVideosMuted(muted);
  },

  isPaused(channel: string, videoId: string) {
    return global.__lookyVideo.isPaused(
      channel,
      videoController.getVideoId(videoId)
    );
  },

  isMuted(channel: string, videoId: string) {
    return global.__lookyVideo.isMuted(
      channel,
      videoController.getVideoId(videoId)
    );
  },

  seek(channel: string, videoId: string, duration: number) {
    global.__lookyVideo.seek(
      channel,
      videoController.getVideoId(videoId),
      duration
    );
  },
};

export function useSubscribeOnFocusEventForChannel(
  channelName: string,
  shouldSeekToStartOnRestore: boolean = true
) {
  const navigation = useNavigation();
  useEffect(() => {
    let skipFirst = true;
    let isFocussed = true;
    const focus = navigation.addListener('focus', () => {
      isFocussed = true;
      if (skipFirst) {
        skipFirst = false;
        return;
      }
      videoController.restoreLastPlaying(
        channelName,
        shouldSeekToStartOnRestore
      );
    });

    const blur = navigation.addListener('blur', () => {
      isFocussed = false;
      videoController.pauseCurrentPlayingWithLaterRestore(channelName);
    });

    const change = AppState.addEventListener('change', (state) => {
      // do nothing on android platform
      if (Platform.OS === 'android') return;
      if (state === 'background' && isFocussed) {
        videoController.togglePlayInBackground(channelName, true);
      }

      if (state === 'active' && isFocussed) {
        videoController.togglePlayInBackground(channelName, false);
      }
    }).remove;
    return () => {
      focus();
      blur();
      change();
    };
  }, [
    channelName,
    navigation,
    shouldSeekToStartOnRestore,
  ]);
}
