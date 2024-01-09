import * as React from 'react';
import { ShowcaseApp } from '@gorhom/showcase-template';

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
