import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

interface NativeProps extends ViewProps {
  videoUri: string;
  muted: boolean;
  loop: boolean;
  nativeID: string;
  onMuteToggle?: (e: any) => void;
  onVideoTap?: (e: any) => void;
  onEndPlay?: (e: any) => void;
  hudPosition?: { x: number; y: number };
}

export default codegenNativeComponent<NativeProps>('VideoView');
