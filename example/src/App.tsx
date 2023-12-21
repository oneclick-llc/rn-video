import * as React from 'react';
import { useState } from 'react';
import Video from 'react-native-video';

import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { AppVideo } from './AppVideo';
import { SimpleLookyVideoView, videoController } from 'rn-video';

const one =
  'https://cdn-test.looky.com/post-instagram/3093573415336326421/344572606_907419743843224_427802127932990228_n.mp4';
const two =
  'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8';

const poster =
  'https://www.shutterstock.com/shutterstock/photos/1362869099/display_1500/stock-vector-example-stamp-vector-template-illustration-design-vector-eps-1362869099.jpg';

export default function App() {
  const [renderAutoplay, setRenderAutoplay] = useState(false);
  return (
    <View style={{ flex: 1 }}>
      <View style={styles.container}>
        <AppVideo
          channel={'channel'}
          resizeMode={'contain'}
          src={one}
          vId={'one'}
          poster={poster}
        />
        <AppVideo loop channel={'channel'} src={one} vId={'two'} />
        <AppVideo channel={'channel2'} src={one} vId={'two'} />
        <AppVideo
          channel={'channel3'}
          src={'https://cdn-test.looky.com'}
          vId={'tgree'}
        />
        {renderAutoplay && (
          <View style={{ flex: 1 }}>
            <SimpleLookyVideoView
              videoUri={one}
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
        )}
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

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          setRenderAutoplay(!renderAutoplay);
        }}
        children={<Text children={'render autoplay'} />}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
  },
});
