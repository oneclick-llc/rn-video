import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

interface Callbacks {
  onVideoTap?: (e: any) => void;
  onVideoDoubleTap?: (e: any) => void;
  onVideoBuffer?: (e: any) => void;
  onVideoEnd?: (e: any) => void;
  onVideoLoad?: () => void;
  onVideoProgress?: (data: {
    nativeEvent: {
      currentTime: number;
      totalDuration: number;
      timeLeft: number;
    };
  }) => void;
}

export interface NativeProps extends ViewProps, Callbacks {
  videoUri: string;
  muted: boolean;
  loop: boolean;
  nativeID: string;
  progressUpdateInterval?: number;
  resizeMode?: 'stretch' | 'contain' | 'cover';
}

export default codegenNativeComponent<NativeProps>('LookyVideoView');
