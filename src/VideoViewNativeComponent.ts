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

interface Callbacks {
  onVideoTap?: () => void;
  onVideoDoubleTap?: () => void;
  onVideoBuffer?: (data: OnVideoBufferParams) => void;
  onVideoEnd?: () => void;
  onVideoLoad?: (data: OnVideoLoadParams) => void;
  onVideoProgress?: (data: OnVideoProgressParams) => void;
  onVideoError?: () => void;
}

export interface LookyVideoProps extends Pick<ViewProps, 'style'>, Callbacks {
  videoUri: string;
  muted: boolean;
  loop: boolean;
  progressUpdateInterval?: number;
  resizeMode?: 'stretch' | 'contain' | 'cover';
  nativeId: string;
}

export default codegenNativeComponent<LookyVideoProps>('LookyVideoView');
