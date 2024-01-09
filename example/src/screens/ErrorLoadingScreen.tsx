import React from 'react';
import { View } from 'react-native';
import { AppVideo } from '../AppVideo';
import { poster } from '../constants';

export const ErrorLoadingScreen: React.FC = () => {
  return (
    <View>
      <View style={{ flexDirection: 'row' }}>
        <AppVideo
          channel={'channel3'}
          poster={poster}
          src={'https://cdn-test.looky.com'}
          vId={'tgree'}
        />
      </View>
    </View>
  );
};
