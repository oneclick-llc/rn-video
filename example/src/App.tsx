import * as React from 'react';

import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { AppVideo } from './AppVideo';
import { videoController } from 'rn-video';

const one =
  'https://cdn-test.looky.com/post-instagram/3093573415336326421/344572606_907419743843224_427802127932990228_n.mp4';

export default function App() {
  return (
    <View style={{ flex: 1 }}>
      <View style={styles.container}>
        <AppVideo channel={'channel'} src={one} vId={'one'} />
        <AppVideo loop channel={'channel'} src={one} vId={'two'} />
        <AppVideo channel={'channel2'} src={one} vId={'two'} />
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
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
  },
});
