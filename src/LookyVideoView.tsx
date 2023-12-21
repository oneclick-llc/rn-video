import React, { memo, useRef, useState } from 'react';
import type {
  LookyVideoProps,
  OnShowPosterParams,
} from './VideoViewNativeComponent';
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
  const [showPoster, setShowPoster] = useState<OnShowPosterParams>({
    nativeEvent: { show: true },
  });

  console.log('🍓[LookyVideoView.]', showPoster);

  return (
    <View style={props.style}>
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

interface SimpleProps extends Omit<Props, 'videoId' | 'channel'> {}

let unqueVideoId = 1;
let channel = 'SimpleLookyVideoView';
export const SimpleLookyVideoView: React.FC<SimpleProps> = memo((props) => {
  const videoId = useRef<string>();
  if (videoId.current === undefined) {
    videoId.current = (++unqueVideoId).toString();
  }
  console.log('🍓[LookyVideoView.]', props.autoplay);
  return (
    <LookyVideoView {...props} channel={channel} videoId={videoId.current} />
  );
});
