import * as React from 'react';

import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import {
  getIdForVideo,
  getIdForVideoWithoutChannel,
  pauseCurrentPlaying,
  playVideo,
  togglePlayVideo,
  toggleVideosMuted,
  toggleVideosMutedEvent,
  VideoView,
} from 'react-native-video';
import { useEffect, useState } from 'react';
import { mediaLibrary } from 'react-native-media-library';

const one =
  'https://cdn-test.looky.com/post-instagram/3093573415336326421/344572606_907419743843224_427802127932990228_n.mp4';
const two =
  'https://cdn-test.looky.com/post/d7bd7109-1e0b-4bcd-83b7-db82be9f519d/0fc47b6aaffa29267b1cf3f3a57664e7.mp4';
let key = 0;

export default function App() {
  // const [video, setVideo] = useState()
  const [video, setVideo] = useState<string | undefined>(undefined);
  const [isPresented, setPresented] = useState(true);
  let vId = video === one ? 'one' : 'two';
  const [height, setHeight] = useState(300);

  useEffect(() => {
    mediaLibrary
      .getAssets({
        mediaType: ['video'],
        sortBy: 'creationTime',
        sortOrder: 'desc',
        limit: 1,
      })
      .then(async (r) => {
        console.log('[App.]', r[0]);
        //setAsset(r[0]);
        setVideo(r[0].uri);
        //setVideo(one);
      });
  });

  return (
    <View style={styles.container}>
      {isPresented && !!video && (
        <VideoView
          hudOffset={{ x: 12, y: 12 }}
          isSloMo={true}
          resizeMode={'cover'}
          onVideoProgress={(data) => console.log('[App.====||]', data)}
          onMuteToggle={toggleVideosMutedEvent}
          //poster={'https://picsum.photos/200/300'}
          onVideoDoubleTap={() => {
            console.log('[App.=-=-=-=-==-=]');
          }}
          onVideoTap={() =>
            togglePlayVideo('cha', getIdForVideoWithoutChannel(vId))
          }
          onEndPlay={(e) => console.log('[App.=====]')}
          nativeID={getIdForVideo('cha', vId)}
          key={key}
          videoUri={video}
          muted={false}
          loop={false}
          style={[styles.box, { height }]}
        />
      )}

      <TouchableOpacity
        onPress={() => {
          setHeight(height === 300 ? 600 : 300);
          //setVideo((v) => (v === one ? two : one));
        }}
      >
        <Text>toggle video</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          key += 1;

          setPresented(!isPresented);
        }}
      >
        <Text>toggle presence</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          playVideo('cha', getIdForVideoWithoutChannel(vId));
        }}
      >
        <Text>Play</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          pauseCurrentPlaying();
        }}
      >
        <Text>Pause</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          toggleVideosMuted(true);
        }}
      >
        <Text>Mute</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 200,
    height: 300,
    marginVertical: 20,
  },
});
