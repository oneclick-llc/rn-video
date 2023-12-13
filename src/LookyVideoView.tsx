import React, { memo, useEffect, useState } from 'react';
import type { NativeProps } from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';
import { Image, StyleSheet, View } from 'react-native';
import { videoController } from 'src/VideosController';

interface Props extends NativeProps {
  poster?: string | number;
}

export const LookyVideoView: React.FC<Props> = memo((props) => {
  const [isLoaded, setLoaded] = useState(false);

  return (
    <View style={props.style}>
      <V
        {...props}
        onVideoProgress={
          props.onVideoProgress
            ? //@ts-ignore
              (event) => props.onVideoProgress(event.nativeEvent)
            : undefined
        }
        style={StyleSheet.absoluteFillObject}
        onVideoLoad={() => {
          props.onVideoLoad?.();
          setLoaded(true);
        }}
      />
      {!isLoaded && props.poster && (
        <Image
          style={StyleSheet.absoluteFillObject}
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
