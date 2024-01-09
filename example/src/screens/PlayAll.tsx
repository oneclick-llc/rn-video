import React, { useRef } from 'react';
import { Text, TouchableOpacity, View } from 'react-native';
import { AppVideo } from '../AppVideo';
import { oneVideo, poster } from '../constants';
import { videoController } from 'rn-video';

export const PlayAll: React.FC = () => {
  const isAllPlaying = useRef(false);

  return (
    <View>
      <View style={{ flexDirection: 'row' }}>
        <AppVideo
          channel={'autoplay'}
          resizeMode={'contain'}
          src={oneVideo}
          vId={'1'}
          poster={poster}
        />
        <AppVideo loop channel={'autoplay'} src={oneVideo} vId={'2'} />
        <AppVideo channel={'autoplay'} src={oneVideo} vId={'3'} />
        <AppVideo channel={'autoplay2'} src={oneVideo} vId={'4'} />
      </View>

      <TouchableOpacity
        children={<Text children={'Toggle all'} />}
        onPress={() => {
          if (isAllPlaying.current) videoController.pauseAll('autoplay');
          else videoController.playAll('autoplay');
          isAllPlaying.current = !isAllPlaying.current;
        }}
      />
    </View>
  );
};
