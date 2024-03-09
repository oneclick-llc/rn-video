import React from 'react';
import { SimpleLookyVideoView, videoController } from 'rn-video';
import { oneVideo, poster } from '../constants';
import { Text, TouchableOpacity, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';

export const LoopDurationPlayOne: React.FC = () => {
  const navigation = useNavigation();

  return (
    <View style={{ flex: 1 }}>
      <SimpleLookyVideoView
        videoUri={oneVideo}
        channel={'loop'}
        videoId={'loop'}
        loop
        muted
        autoplay
        loopDuration={1}
        poster={poster}
        posterStyle={{
          width: '100%',
          height: 200,
          overflow: 'hidden',
          resizeMode: 'cover',
        }}
        style={{
          width: '100%',
          height: 200,
        }}
      />

      <TouchableOpacity
        children={<Text children={'Go to nex'} />}
        onPress={() => {
          // @ts-ignore
          navigation.navigate('OneMoreVideo');
        }}
      />
      <TouchableOpacity
        children={<Text children={'Toggle Play'} />}
        onPress={() => {
          videoController.togglePlay('loop', 'loop');
        }}
      />
    </View>
  );
};
