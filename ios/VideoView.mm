#import "VideoView.h"

#import <react/renderer/components/RNVideoViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNVideoViewSpec/EventEmitters.h>
#import <react/renderer/components/RNVideoViewSpec/Props.h>
#import <react/renderer/components/RNVideoViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "VideosController.h"

using namespace facebook::react;

@interface VideoView () <RCTVideoViewViewProtocol>

@end

@implementation VideoView {
    AppVideoView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<VideoViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const VideoViewProps>();
    _props = defaultProps;

    _view = [[AppVideoView alloc] init];

    self.contentView = _view;
  }

  return self;
}

- (void)prepareForRecycle {
    [super prepareForRecycle];
    [_view cleanUp];
    [AppVideosManager.sharedManager removeVideo:self.nativeId];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<VideoViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<VideoViewProps const>(props);

    [super updateProps:props oldProps:oldProps];
    
    if (_view.uri == NULL || oldViewProps.videoUri != newViewProps.videoUri) {
        NSString * uriToConvert = [[NSString alloc] initWithUTF8String: newViewProps.videoUri.c_str()];
        [_view setVideoUri:uriToConvert];
    }
    [AppVideosManager.sharedManager addVideo:_view nativeID:self.nativeId];
}

Class<RCTComponentViewProtocol> VideoViewCls(void) {
    return VideoView.class;
}
@end
