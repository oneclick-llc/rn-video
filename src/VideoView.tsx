import React, { memo, useState } from 'react';
import { Image, StyleSheet, View } from 'react-native';
import Video, { type NativeProps } from './VideoViewNativeComponent';
import Animated from 'react-native-reanimated';

const AnimatedVideo = Animated.createAnimatedComponent(Video);

interface Props extends NativeProps {
  isAnimated?: boolean;
  poster?: string;
}

export const VideoView: React.FC<Props> = memo(({ style, ...props }) => {
  const [isLoaded, setLoaded] = useState(false);
  const WrapComponent = props.isAnimated ? Animated.View : View;
  const VideoComponent = props.isAnimated ? AnimatedVideo : Video;

  return (
    // @ts-ignore | it has call signature =|
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
        onLoad={() => setLoaded(true)}
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
