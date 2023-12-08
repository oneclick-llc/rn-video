import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

export interface NativeProps extends ViewProps {
  videoUri: string;
  muted: boolean;
  loop: boolean;
  nativeID: string;
  onVideoTap?: (e: any) => void;
  onVideoDoubleTap?: (e: any) => void;
  onVideoEnd?: (e: any) => void;
  onVideoLoad?: () => void;
  resizeMode?: 'stretch' | 'contain' | 'cover';
  onVideoProgress?: (data: {
    currentTime: number;
    totalDuration: number;
    timeLeft: number;
  }) => void;
}

export default codegenNativeComponent<NativeProps>('LookyVideoView');
