import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { AppVideo } from '../AppVideo';
import { videoController } from 'rn-video';
import { oneVideo, poster } from '../constants';

export const BaseScreen: React.FC = () => {
  return (
    <View style={{ flex: 1 }}>
      <View style={styles.container}>
        <AppVideo
          channel={'channel'}
          resizeMode={'contain'}
          src={oneVideo}
          vId={'one'}
          poster={poster}
          loop
        />
        <AppVideo loop channel={'channel'} src={oneVideo} vId={'two'} />
        <AppVideo channel={'channel2'} src={oneVideo} vId={'three'} />
      </View>

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          videoController.togglePlayInBackground('channel', true);
        }}
        children={<Text children={'Toggle play in background'} />}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          videoController.restoreLastPlaying(undefined, true);
        }}
        children={<Text children={'restore last playing'} />}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
  },
});
