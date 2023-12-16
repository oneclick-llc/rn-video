import React, { useState } from 'react';
import { LookyVideoView, videoController } from 'rn-video';
import { Text, TouchableOpacity, View } from 'react-native';

interface Props {
  readonly src: string;
  readonly vId: string;
  readonly channel: string;
  readonly loop?: boolean;
}

export const AppVideo: React.FC<Props> = (props) => {
  const [isPresented, setPresented] = useState(true);
  return (
    <View style={{ flex: 1 }}>
      {isPresented && (
        <LookyVideoView
          progressUpdateInterval={0.25}
          resizeMode={'cover'}
          // onVideoProgress={(data) =>
          //   console.log('AppVideo.onVideoProgress', data)
          // }
          //poster={'https://picsum.photos/200/300'}
          onVideoDoubleTap={() => {
            console.log('🍓[AppVideo.onVideoDoubleTap]');
          }}
          onVideoTap={() => {
            console.log('🍓[AppVideo.onVideoTap]');
            videoController.togglePlay(props.channel, props.vId);
          }}
          onVideoLoad={(d) =>
            console.log('🍓[AppVideo.onVideoLoad]', d.nativeEvent)
          }
          onVideoEnd={() => console.log('🍓[AppVideo.onVideoEnd]')}
          channel={props.channel}
          videoId={props.vId}
          key={props.vId}
          videoUri={props.src}
          muted={false}
          loop={props.loop ?? false}
          style={{
            width: 200,
            height: 200,
          }}
        />
      )}
      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          setPresented(!isPresented);
        }}
        children={<Text children={'toggle presence'} />}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          videoController.play(props.channel, props.vId);
        }}
        children={<Text children={'Play'} />}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          videoController.pauseCurrentPlaying();
        }}
        children={<Text children={'Pause'} />}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          videoController.toggleMuted(true);
        }}
        children={<Text children={'Mute'} />}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        onPress={() => {
          videoController.pauseCurrentPlayingWithLaterRestore(props.channel);
        }}
        children={<Text children={'Pause for later restore'} />}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        children={<Text children={'IsMuted'} />}
        onPress={() => {
          console.log(
            '🍓[AppVideo.isMuted]',
            videoController.isMuted(props.channel, props.vId)
          );
        }}
      />
      <TouchableOpacity
        style={{ marginTop: 20 }}
        children={<Text children={'IsPaused'} />}
        onPress={() => {
          console.log(
            '🍓[AppVideo.isPaused]',
            videoController.isPaused(props.channel, props.vId)
          );
        }}
      />

      <TouchableOpacity
        style={{ marginTop: 20 }}
        children={<Text children={'Seek to 10 seconds'} />}
        onPress={() => {
          videoController.seek(props.channel, props.vId, 10);
        }}
      />
    </View>
  );
};
