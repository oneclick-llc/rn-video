import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

export interface NativeProps extends ViewProps {
  videoUri: string;
  muted: boolean;
  loop: boolean;
  nativeID: string;
  onMuteToggle?: (e: any) => void;
  onVideoTap?: (e: any) => void;
  onEndPlay?: (e: any) => void;
  onLoad?: () => void;
  hudOffset?: { x: number; y: number };
  resizeMode?: 'stretch' | 'contain' | 'cover';
}

export default codegenNativeComponent<NativeProps>('VideoView');
