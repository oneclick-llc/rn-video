import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { AppVideo } from '../AppVideo';
import { videoController } from 'rn-video';
import { oneVideo, poster } from '../constants';

export const PlayByNativeId: React.FC = () => {
  return (
    <View style={{ flex: 1 }}>
      <View style={styles.container}>
        <AppVideo
          channel={'channel'}
          resizeMode={'contain'}
          src={oneVideo}
          vId={'one'}
          poster={poster}
        />
      </View>

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          if (videoController.isPaused('channel', 'one')) {
            videoController.playWithId(`channel:one`);
          } else {
            videoController.pauseWithId(`channel:one`);
          }
        }}
        children={<Text children={'Toggle play with native id'} />}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
  },
});
