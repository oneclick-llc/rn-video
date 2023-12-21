package com.video;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.yqritc.scalablevideoview.ScalableType;

import java.util.Map;
import java.util.Objects;

import javax.annotation.Nullable;

public class ReactVideoViewManager extends SimpleViewManager<ReactVideoView> {

    public static final String REACT_CLASS = "RCTVideo";

    public static final String PROP_RESIZE_MODE = "videoResizeMode";
    public static final String PROP_MUTED = "muted";
    public static final String PROP_PROGRESS_UPDATE_INTERVAL = "progressUpdateInterval";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected ReactVideoView createViewInstance(ThemedReactContext themedReactContext) {
        return new ReactVideoView(themedReactContext);
    }

    @Override
    public void onDropViewInstance(ReactVideoView view) {
        super.onDropViewInstance(view);
        view.cleanupMediaPlayerResources();
    }

    @Override
    @Nullable
    public Map getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder builder = MapBuilder.builder();
        for (ReactVideoView.Events event : ReactVideoView.Events.values()) {
            builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
        }
        return builder.build();
    }

    @ReactProp(name = PROP_RESIZE_MODE)
    public void setResizeMode(final ReactVideoView videoView, final String resizeModeOrdinalString) {
      System.out.println("🍓 videoResizeMode " + resizeModeOrdinalString);
        if (Objects.equals(resizeModeOrdinalString, "stretch")) {
          videoView.setResizeModeModifier(ScalableType.FIT_XY);
        } else if (Objects.equals(resizeModeOrdinalString, "contain")) {
          videoView.setResizeModeModifier(ScalableType.FIT_CENTER);
        } else if (Objects.equals(resizeModeOrdinalString, "cover")) {
          videoView.setResizeModeModifier(ScalableType.CENTER_CROP);
        }
    }

    @ReactProp(name = PROP_MUTED, defaultBoolean = false)
    public void setMuted(final ReactVideoView videoView, final boolean muted) {
        videoView.setMutedModifier(muted);
    }


    @ReactProp(name = PROP_PROGRESS_UPDATE_INTERVAL, defaultFloat = 250.0f)
    public void setProgressUpdateInterval(final ReactVideoView videoView, final float progressUpdateInterval) {
        videoView.setProgressUpdateInterval(progressUpdateInterval);
    }

    @ReactProp(name = "autoplay")
    public void isAutoplay(final ReactVideoView videoView, final boolean isAutoplay) {
        videoView.setAutoplay(isAutoplay);
    }
}
