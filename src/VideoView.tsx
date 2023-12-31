import React, { memo, useState } from 'react';
import type { NativeProps } from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';
import { Platform, Image, StyleSheet, View } from 'react-native';

interface Props extends NativeProps {
  poster?: string;
}

export const VideoView: React.FC<Props> = memo((props) => {
  if (Platform.OS === 'android')
    throw new Error('Trying to render iOS VideoView on an unsuitable Platform');

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
    </View>
  );
});
