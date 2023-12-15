import React, { memo, useEffect, useState } from 'react';
import type { NativeProps } from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';
import { Image, ImageStyle, StyleProp, StyleSheet, View } from 'react-native';
import { videoController } from './VideosController';

interface Props extends NativeProps {
  poster?: string | number;
  posterStyle?: StyleProp<ImageStyle>;
}

export const LookyVideoView: React.FC<Props> = memo((props) => {
  const [isLoaded, setLoaded] = useState(false);

  return (
    <View style={props.style}>
      <V
        {...props}
        onVideoBuffer={(event) =>
          console.log('🍓[LookyVideoView.onVideoBuffer]', event.nativeEvent)
        }
        onVideoProgress={props.onVideoProgress}
        style={StyleSheet.absoluteFillObject}
        onVideoLoad={() => {
          props.onVideoLoad?.();
          setLoaded(true);
        }}
      />
      {!isLoaded && props.poster && (
        <Image
          style={props.posterStyle ?? StyleSheet.absoluteFillObject}
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

export const SimpleLookyVideoView: React.FC<Props & { autoplay?: boolean }> =
  memo((props) => {
    useEffect(() => {
      if (props.autoplay) {
        videoController.playWithId(props.nativeID);
      } else {
        videoController.pauseWithId(props.nativeID);
      }
    }, [props.autoplay, props.nativeID]);
    return <LookyVideoView {...props} />;
  });
