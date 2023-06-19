import React from 'react';
import type { NativeProps } from './VideoViewNativeComponent';
import V from './VideoViewNativeComponent';

interface Props extends NativeProps {}

export const VideoView: React.FC<Props> = (props) => {
  return <V {...props} />;
};
