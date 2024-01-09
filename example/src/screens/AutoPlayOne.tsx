import React from 'react';
import { SimpleLookyVideoView } from 'rn-video';
import { oneVideo, poster } from '../constants';
import { View } from 'react-native';

export const AutoPlayOne: React.FC = () => {
  return (
    <View style={{ flex: 1 }}>
      <SimpleLookyVideoView
        videoUri={oneVideo}
        loop
        muted={false}
        autoplay
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
    </View>
  );
};
