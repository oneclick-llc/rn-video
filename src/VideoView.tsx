import React, { memo, useState } from 'react';
import { Platform, Image, StyleSheet, View, ViewProps } from 'react-native';
import Video, { type NativeProps } from './VideoViewNativeComponent';
import Animated, { AnimateProps } from 'react-native-reanimated';

const AnimatedVideo = Animated.createAnimatedComponent(Video);

interface Props extends NativeProps {
  isAnimated?: boolean;
  poster?: string;
}

export const VideoView: React.FC<Props> = memo(({ style, ...props }) => {
  if (Platform.OS === 'android')
    throw new Error('Trying to render iOS VideoView on a different Platform');

  const [isLoaded, setLoaded] = useState(false);
  const WrapComponent = props.isAnimated
    ? (Animated.View as React.ComponentType<AnimateProps<ViewProps>>)
    : View;
  const VideoComponent = props.isAnimated ? AnimatedVideo : Video;

  return (
    <WrapComponent style={style}>
      <VideoComponent
        {...props}
        onVideoProgress={
          props.onVideoProgress
            ? //@ts-ignore
              (event) => props.onVideoProgress(event.nativeEvent)
            : undefined
        }
        style={StyleSheet.absoluteFillObject}
        onLoad={() => {
          props.onLoad?.();
          setLoaded(true);
        }}
      />
      {!isLoaded && props.poster && (
        <Image
          style={StyleSheet.absoluteFillObject}
          source={{ uri: props.poster }}
        />
      )}
    </WrapComponent>
  );
});
