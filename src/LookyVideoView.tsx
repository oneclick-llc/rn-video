import React, { memo, useState } from 'react';
import type { NativeProps } from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';
import { Image, StyleSheet, View } from 'react-native';

interface Props extends NativeProps {
  poster?: string;
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
          source={{ uri: props.poster }}
        />
      )}
    </View>
  );
});
