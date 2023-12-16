import React, { memo, useEffect, useRef, useState } from 'react';
import type { LookyVideoProps } from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';
import {
  Image,
  ImageStyle,
  StyleProp,
  StyleSheet,
  View,
  ViewProps,
} from 'react-native';
import { videoController } from './VideosController';

interface Props extends Omit<LookyVideoProps, 'nativeID'> {
  poster?: string | number;
  posterStyle?: StyleProp<ImageStyle>;
  onLayout?: ViewProps['onLayout'];
  channel: string;
  videoId: string;
  pointerEvents?: ViewProps['pointerEvents'];
}

export const LookyVideoView: React.FC<Props> = memo((props) => {
  const [isLoaded, setLoaded] = useState(false);

  return (
    <View style={props.style}>
      <V
        {...props}
        nativeID={videoController.getId(props.channel, props.videoId)}
        onVideoBuffer={(event) =>
          console.log('🍓[LookyVideoView.onVideoBuffer]', event.nativeEvent)
        }
        onVideoError={() => {
          console.log('🍓[LookyVideoView.error]');
        }}
        onVideoProgress={props.onVideoProgress}
        style={StyleSheet.absoluteFillObject}
        onVideoLoad={(params) => {
          props.onVideoLoad?.(params);
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

interface SimpleProps extends Omit<Props, 'videoId' | 'channel'> {
  autoplay?: boolean;
}

let unqueVideoId = 1;
let channel = 'SimpleLookyVideoView';
export const SimpleLookyVideoView: React.FC<SimpleProps> = memo((props) => {
  const videoId = useRef<string>();
  if (videoId.current === undefined) {
    videoId.current = (++unqueVideoId).toString();
  }

  useEffect(() => {
    const nativeId = videoController.getId(channel, videoId.current!);
    if (props.autoplay) {
      videoController.playWithId(nativeId);
    } else {
      videoController.pauseWithId(nativeId);
    }
  }, [props.autoplay]);
  return (
    <LookyVideoView {...props} channel={channel} videoId={videoId.current} />
  );
});
