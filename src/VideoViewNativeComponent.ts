import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

export interface OnVideoProgressParams {
  nativeEvent: {
    currentTime: number;
    totalDuration: number;
    timeLeft: number;
  };
}

export interface OnVideoLoadParams {
  nativeEvent: {
    totalDuration: number;
  };
}

export interface OnVideoBufferParams {
  nativeEvent: {
    isBuffering: boolean;
  };
}

export interface OnShowPosterParams {
  nativeEvent: {
    show: boolean;
  };
}

interface Callbacks {
  onVideoBuffer?: (data: OnVideoBufferParams) => void;
  onVideoEnd?: () => void;
  onVideoLoad?: (data: OnVideoLoadParams) => void;
  onVideoProgress?: (data: OnVideoProgressParams) => void;
  onVideoError?: () => void;
  onShowPoster?: (data: OnShowPosterParams) => void;
}

export interface LookyVideoProps extends Pick<ViewProps, 'style'>, Callbacks {
  videoUri: string;
  muted: boolean;
  loop: boolean;
  progressUpdateInterval?: number;
  loopDuration?: number;
  videoResizeMode?: 'stretch' | 'contain' | 'cover';
  nativeID: string;
  autoplay?: boolean;
}

export default codegenNativeComponent<LookyVideoProps>('LookyVideoView');
