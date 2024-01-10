import * as React from 'react';
import { ShowcaseApp } from '@gorhom/showcase-template';
import { OneMoreVideo } from 'example/src/screens/OneMoreVideo';

const screens = [
  {
    title: 'Video',
    data: [
      {
        name: 'Base',
        slug: 'Base',
        getScreen: () => require('./screens/BaseScreen').BaseScreen,
      },
      {
        name: 'ErrorLoadingScreen',
        slug: 'ErrorLoadingScreen',
        getScreen: () =>
          require('./screens/ErrorLoadingScreen').ErrorLoadingScreen,
      },
      {
        name: 'AutoPlayOne',
        slug: 'AutoPlayOne',
        getScreen: () => require('./screens/AutoPlayOne').AutoPlayOne,
      },
      {
        name: 'AutoPlayAll',
        slug: 'AutoPlayAll',
        getScreen: () => require('./screens/PlayAll').PlayAll,
      },
      {
        name: 'PlayByNativeId',
        slug: 'PlayByNativeId',
        getScreen: () => require('./screens/PlayByNativeId').PlayByNativeId,
      },
      {
        name: 'OneMoreVideo',
        slug: 'OneMoreVideo',
        getScreen: () => require('./screens/OneMoreVideo').OneMoreVideo,
      },
    ],
  },
];

export default function App() {
  return (
    <ShowcaseApp
      name="Video"
      description={''}
      version={'0.0'}
      author={{ username: '', url: '' }}
      data={screens}
    />
  );
}
