import React, { memo, useEffect, useRef, useState } from 'react';
import type {
  LookyVideoProps,
  OnShowPosterParams,
} from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';
import {
  AppState,
  Image,
  ImageStyle,
  Platform,
  StyleProp,
  StyleSheet,
  View,
  ViewProps,
} from 'react-native';
import { videoController } from './VideosController';
import { useNavigation } from '@react-navigation/native';

interface Props extends Omit<LookyVideoProps, 'nativeID'> {
  poster?: string | number;
  posterStyle?: StyleProp<ImageStyle>;
  onLayout?: ViewProps['onLayout'];
  channel: string;
  videoId: string;
  pointerEvents?: ViewProps['pointerEvents'];
}

export const LookyVideoView: React.FC<Props> = memo((props) => {
  const [showPoster, setShowPoster] = useState<OnShowPosterParams>({
    nativeEvent: { show: true },
  });

  return (
    <View style={props.style} pointerEvents={props.pointerEvents}>
      <V
        {...props}
        nativeID={videoController.getId(props.channel, props.videoId)}
        onVideoProgress={props.onVideoProgress}
        style={StyleSheet.absoluteFillObject}
        onShowPoster={(params) => {
          setShowPoster({ nativeEvent: { show: params.nativeEvent.show } });
        }}
      />
      {showPoster.nativeEvent?.show && props.poster && (
        <Image
          style={[props.posterStyle, StyleSheet.absoluteFillObject]}
          source={
            typeof props.poster === 'number'
              ? props.poster
              : { uri: props.poster }
          }
        />
      )}
    </View>
  );
});

interface SimpleProps extends Omit<Props, 'videoId' | 'channel'> {}

let uniqueVideoId = 1;
export const SimpleLookyVideoView: React.FC<
  SimpleProps & { channel?: string; videoId?: string }
> = memo((props) => {
  const navigation = useNavigation();
  const videoId = useRef<{ id: string; channel: string }>();
  if (videoId.current === undefined) {
    videoId.current = {
      channel:
        props.channel ??
        `SimpleLookyVideViewChannel${(++uniqueVideoId).toString()}`,
      id: props.videoId ?? (++uniqueVideoId).toString(),
    };
  }

  useEffect(() => {
    let skipFirstFocus = true;
    let isFocused = true;
    if (Platform.OS === 'android') return;
    const focus = navigation.addListener('focus', () => {
      skipFirstFocus = false;
      isFocused = true;
      if (skipFirstFocus) return;
      if (!props.autoplay) return;
      videoController.playAll(videoId.current!.channel);
    });
    const blur = navigation.addListener('blur', () => {
      isFocused = false;
      if (!props.autoplay) return;
      videoController.pauseAll(videoId.current!.channel);
    });

    const appFocus = AppState.addEventListener('change', (state) => {
      if (state === 'active' && props.autoplay && isFocused) {
        videoController.playAll(videoId.current!.channel);
      }
    });

    return () => {
      blur();
      focus();
      appFocus.remove();
    };
  }, [navigation]);

  return (
    <LookyVideoView
      {...props}
      channel={videoId.current!.channel}
      videoId={videoId.current!.id}
    />
  );
});
