package com.video;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.res.AssetFileDescriptor;
import android.graphics.Matrix;
import android.media.MediaPlayer;
import android.media.TimedMetaData;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.webkit.CookieManager;
import android.widget.MediaController;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.yqritc.scalablevideoview.ScalableType;
import com.yqritc.scalablevideoview.ScalableVideoView;
import com.yqritc.scalablevideoview.ScaleManager;
import com.yqritc.scalablevideoview.Size;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

import zipfile.APKExpansionSupport;
import zipfile.ZipResourceFile;

@SuppressLint("ViewConstructor")
public class ReactVideoView extends ScalableVideoView implements
  MediaPlayer.OnPreparedListener,
  MediaPlayer.OnErrorListener,
  MediaPlayer.OnBufferingUpdateListener,
  MediaPlayer.OnSeekCompleteListener,
  MediaPlayer.OnCompletionListener,
  MediaPlayer.OnInfoListener,
  LifecycleEventListener,
  MediaController.MediaPlayerControl {

  public enum Events {
    EVENT_LOAD("onVideoLoad"),
    EVENT_ERROR("onVideoError"),
    EVENT_PROGRESS("onVideoProgress"),
    EVENT_END("onVideoEnd"),
    EVENT_BUFFER("onVideoBuffer");

    private final String mName;

    Events(final String name) {
      mName = name;
    }

    @Override
    public String toString() {
      return mName;
    }
  }

  public static final String EVENT_PROP_PLAYABLE_DURATION = "totalDuration";
  public static final String EVENT_PROP_SEEKABLE_DURATION = "timeLeft";
  public static final String EVENT_PROP_CURRENT_TIME = "currentTime";

  private ThemedReactContext mThemedReactContext;
  public RCTEventEmitter mEventEmitter;

  private Handler mProgressUpdateHandler = new Handler();
  private Runnable mProgressUpdateRunnable = null;

  private String mSrcUriString = null;
  private String mSrcType = "mp4";
  private ReadableMap mRequestHeaders = null;
  private boolean mSrcIsNetwork = false;
  private boolean mSrcIsAsset = false;
  private ScalableType mResizeMode = ScalableType.LEFT_TOP;
  private boolean mRepeat = false;
  public boolean mPaused = true;
  public boolean mMuted = false;
  private boolean mPreventsDisplaySleepDuringVideoPlayback = true;
  private float mVolume = 1.0f;
  private float mStereoPan = 0.0f;
  private float mProgressUpdateInterval = 250.0f;
  private float mRate = 1.0f;
  private float mActiveRate = 1.0f;
  private boolean mPlayInBackground = false;
  private boolean mBackgroundPaused = false;

  private int mMainVer = 0;
  private int mPatchVer = 0;

  private boolean mMediaPlayerValid = false; // True if mMediaPlayer is in prepared, started, paused or completed state.

  private int mVideoDuration = 0;
  private boolean isCompleted = false;

  public ReactVideoView(ThemedReactContext themedReactContext) {
    super(themedReactContext);

    mThemedReactContext = themedReactContext;
    mEventEmitter = themedReactContext.getJSModule(RCTEventEmitter.class);
    themedReactContext.addLifecycleEventListener(this);

    initializeMediaPlayerIfNeeded();
    setSurfaceTextureListener(this);

    mProgressUpdateRunnable = new Runnable() {
      @Override
      public void run() {

        if (mMediaPlayerValid && !isCompleted && !mPaused && !mBackgroundPaused) {
          WritableMap event = Arguments.createMap();
          event.putDouble(EVENT_PROP_CURRENT_TIME, mMediaPlayer.getCurrentPosition() / 1000.0);
          event.putDouble(EVENT_PROP_PLAYABLE_DURATION, mVideoDuration / 1000.0);
          event.putDouble(EVENT_PROP_SEEKABLE_DURATION, (mVideoDuration / 1000.0) - (mMediaPlayer.getCurrentPosition() / 1000.0));
          mEventEmitter.receiveEvent(getId(), Events.EVENT_PROGRESS.toString(), event);

          // Check for update after an interval
          mProgressUpdateHandler.postDelayed(mProgressUpdateRunnable, Math.round(mProgressUpdateInterval));
        }
      }
    };
  }

  @Override
  @SuppressLint("DrawAllocation")
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    super.onLayout(changed, left, top, right, bottom);

    if (!changed || !mMediaPlayerValid) {
      return;
    }

    int videoWidth = getVideoWidth();
    int videoHeight = getVideoHeight();

    if (videoWidth == 0 || videoHeight == 0) {
      return;
    }

    Size viewSize = new Size(getWidth(), getHeight());
    Size videoSize = new Size(videoWidth, videoHeight);
    ScaleManager scaleManager = new ScaleManager(viewSize, videoSize);
    Matrix matrix = scaleManager.getScaleMatrix(mScalableType);
    if (matrix != null) {
      setTransform(matrix);
    }
  }

  private void initializeMediaPlayerIfNeeded() {
    if (mMediaPlayer == null) {
      mMediaPlayerValid = false;
      mMediaPlayer = new MediaPlayer();
      mMediaPlayer.setOnVideoSizeChangedListener(this);
      mMediaPlayer.setOnErrorListener(this);
      mMediaPlayer.setOnPreparedListener(this);
      mMediaPlayer.setOnBufferingUpdateListener(this);
      mMediaPlayer.setOnSeekCompleteListener(this);
      mMediaPlayer.setOnCompletionListener(this);
      mMediaPlayer.setOnInfoListener(this);
      if (Build.VERSION.SDK_INT >= 23) {
        mMediaPlayer.setOnTimedMetaDataAvailableListener(new TimedMetaDataAvailableListener());
      }
    }
  }

  public void cleanupMediaPlayerResources() {
    if (mMediaPlayer != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        mMediaPlayer.setOnTimedMetaDataAvailableListener(null);
      }
      mMediaPlayerValid = false;
      release();
    }

    if (mThemedReactContext != null) {
      mThemedReactContext.removeLifecycleEventListener(this);
      mThemedReactContext = null;
    }
  }

  public void setSrc(final String uriString, final String type, final boolean isNetwork, final boolean isAsset, final ReadableMap requestHeaders) {
    setSrc(uriString, type, isNetwork, isAsset, requestHeaders, 0, 0);
  }

  public void setSrc(final String uriString, final String type, final boolean isNetwork, final boolean isAsset, final ReadableMap requestHeaders, final int expansionMainVersion, final int expansionPatchVersion) {

    mSrcUriString = uriString;
    mSrcType = type;
    mSrcIsNetwork = isNetwork;
    mSrcIsAsset = isAsset;
    mRequestHeaders = requestHeaders;
    mMainVer = expansionMainVersion;
    mPatchVer = expansionPatchVersion;


    mMediaPlayerValid = false;
    mVideoDuration = 0;

    initializeMediaPlayerIfNeeded();
    mMediaPlayer.reset();

    try {
      if (isNetwork) {
        // Use the shared CookieManager to access the cookies
        // set by WebViews inside the same app
        CookieManager cookieManager = CookieManager.getInstance();

        Uri parsedUrl = Uri.parse(uriString);
        Uri.Builder builtUrl = parsedUrl.buildUpon();

        String cookie = cookieManager.getCookie(builtUrl.build().toString());

        Map<String, String> headers = new HashMap<String, String>();

        if (cookie != null) {
          headers.put("Cookie", cookie);
        }

        if (mRequestHeaders != null) {
          headers.putAll(toStringMap(mRequestHeaders));
        }

        /* According to https://github.com/react-native-community/react-native-video/pull/537
         *   there is an issue with this where it can cause a IOException.
         * TODO: diagnose this exception and fix it
         */
        setDataSource(mThemedReactContext, parsedUrl, headers);
      } else if (isAsset) {
        if (uriString.startsWith("content://")) {
          Uri parsedUrl = Uri.parse(uriString);
          setDataSource(mThemedReactContext, parsedUrl);
        } else {
          setDataSource(uriString);
        }
      } else {
        ZipResourceFile expansionFile = null;
        AssetFileDescriptor fd = null;
        if (mMainVer > 0) {
          try {
            expansionFile = APKExpansionSupport.getAPKExpansionZipFile(mThemedReactContext, mMainVer, mPatchVer);
            fd = expansionFile.getAssetFileDescriptor(uriString.replace(".mp4", "") + ".mp4");
          } catch (IOException e) {
            e.printStackTrace();
          } catch (NullPointerException e) {
            e.printStackTrace();
          }
        }
        if (fd == null) {
          int identifier = mThemedReactContext.getResources().getIdentifier(
            uriString,
            "drawable",
            mThemedReactContext.getPackageName()
          );
          if (identifier == 0) {
            identifier = mThemedReactContext.getResources().getIdentifier(
              uriString,
              "raw",
              mThemedReactContext.getPackageName()
            );
          }
          setRawData(identifier);
        } else {
          setDataSource(fd.getFileDescriptor(), fd.getStartOffset(), fd.getLength());
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
      return;
    }

    isCompleted = false;

    try {
      prepareAsync(this);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void setResizeModeModifier(final ScalableType resizeMode) {
    mResizeMode = resizeMode;

    if (mMediaPlayerValid) {
      setScalableType(resizeMode);
      invalidate();
    }
  }

  public void setRepeatModifier(final boolean repeat) {

    mRepeat = repeat;

    if (mMediaPlayerValid) {
      setLooping(repeat);
    }
  }

  public void setPausedModifier(final boolean paused) {
    mPaused = paused;

    if (!mMediaPlayerValid) {
      return;
    }

    if (mPaused) {
      if (mMediaPlayer.isPlaying()) {
        pause();
      }
    } else {
      if (!mMediaPlayer.isPlaying()) {
        start();
        // Setting the rate unpauses, so we have to wait for an unpause
        if (mRate != mActiveRate) {
          setRateModifier(mRate);
        }

        // Also Start the Progress Update Handler
        mProgressUpdateHandler.post(mProgressUpdateRunnable);
      }
    }
    setKeepScreenOn(!mPaused && mPreventsDisplaySleepDuringVideoPlayback);
  }

  // reduces the volume based on stereoPan
  private float calulateRelativeVolume() {
    float relativeVolume = (mVolume * (1 - Math.abs(mStereoPan)));
    // only one decimal allowed
    BigDecimal roundRelativeVolume = new BigDecimal(relativeVolume).setScale(1, BigDecimal.ROUND_HALF_UP);
    return roundRelativeVolume.floatValue();
  }

  public void setPreventsDisplaySleepDuringVideoPlaybackModifier(final boolean preventsDisplaySleepDuringVideoPlayback) {
    mPreventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback;

    if (!mMediaPlayerValid) {
      return;
    }

    mMediaPlayer.setScreenOnWhilePlaying(mPreventsDisplaySleepDuringVideoPlayback);
    setKeepScreenOn(mPreventsDisplaySleepDuringVideoPlayback);
  }

  public void setMutedModifier(final boolean muted) {
    mMuted = muted;

    if (!mMediaPlayerValid) {
      return;
    }

    if (mMuted) {
      setVolume(0, 0);
    } else if (mStereoPan < 0) {
      // louder on the left channel
      setVolume(mVolume, calulateRelativeVolume());
    } else if (mStereoPan > 0) {
      // louder on the right channel
      setVolume(calulateRelativeVolume(), mVolume);
    } else {
      // same volume on both channels
      setVolume(mVolume, mVolume);
    }
  }

  public void setVolumeModifier(final float volume) {
    mVolume = volume;
    setMutedModifier(mMuted);
  }

  public void setStereoPan(final float stereoPan) {
    mStereoPan = stereoPan;
    setMutedModifier(mMuted);
  }

  public void setProgressUpdateInterval(final float progressUpdateInterval) {
    mProgressUpdateInterval = progressUpdateInterval;
  }

  public void setRateModifier(final float rate) {
    mRate = rate;

    if (mMediaPlayerValid) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        if (!mPaused) { // Applying the rate while paused will cause the video to start
          /* Per https://stackoverflow.com/questions/39442522/setplaybackparams-causes-illegalstateexception
           * Some devices throw an IllegalStateException if you set the rate without first calling reset()
           * TODO: Call reset() then reinitialize the player
           */
          try {
            mMediaPlayer.setPlaybackParams(mMediaPlayer.getPlaybackParams().setSpeed(rate));
            mActiveRate = rate;
          } catch (Exception e) {
            Log.e(ReactVideoViewManager.REACT_CLASS, "Unable to set rate, unsupported on this device");
          }
        }
      } else {
        Log.e(ReactVideoViewManager.REACT_CLASS, "Setting playback rate is not yet supported on Android versions below 6.0");
      }
    }
  }

  public void applyModifiers() {
    setResizeModeModifier(mResizeMode);
    setRepeatModifier(mRepeat);
    setPausedModifier(mPaused);
    setMutedModifier(mMuted);
    setPreventsDisplaySleepDuringVideoPlaybackModifier(mPreventsDisplaySleepDuringVideoPlayback);
    setProgressUpdateInterval(mProgressUpdateInterval);
    setRateModifier(mRate);
  }

  @Override
  public void onPrepared(MediaPlayer mp) {

    mMediaPlayerValid = true;
    mVideoDuration = mp.getDuration();

    WritableMap event = Arguments.createMap();
    event.putDouble(EVENT_PROP_PLAYABLE_DURATION, mVideoDuration / 1000.0);
    mEventEmitter.receiveEvent(getId(), Events.EVENT_LOAD.toString(), event);

    applyModifiers();

    selectTimedMetadataTrack(mp);
  }

  @Override
  public boolean onError(MediaPlayer mp, int what, int extra) {
    WritableMap error = Arguments.createMap();
    mEventEmitter.receiveEvent(getId(), Events.EVENT_ERROR.toString(), error);
    return true;
  }

  @Override
  public boolean onInfo(MediaPlayer mp, int what, int extra) {
    WritableMap map = Arguments.createMap();
    switch (what) {
      case MediaPlayer.MEDIA_INFO_BUFFERING_START:
        map.putBoolean("isBuffering", true);
        mEventEmitter.receiveEvent(getId(), Events.EVENT_BUFFER.toString(), map);
        break;
      case MediaPlayer.MEDIA_INFO_BUFFERING_END:
        break;
      case MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
        map.putBoolean("isBuffering", false);
        mEventEmitter.receiveEvent(getId(), Events.EVENT_BUFFER.toString(), map);
        break;

      default:
    }
    return false;
  }

  @Override
  public void onBufferingUpdate(MediaPlayer mp, int percent) {
    selectTimedMetadataTrack(mp);
  }

  public void onSeekComplete(MediaPlayer mp) {

  }

  @Override
  public void seekTo(int msec) {
    if (mMediaPlayerValid) {
      super.seekTo(msec);
      if (isCompleted && mVideoDuration != 0 && msec < mVideoDuration) {
        isCompleted = false;
      }
    }
  }

  @Override
  public int getBufferPercentage() {
    return 0;
  }

  @Override
  public boolean canPause() {
    return true;
  }

  @Override
  public boolean canSeekBackward() {
    return true;
  }

  @Override
  public boolean canSeekForward() {
    return true;
  }

  @Override
  public int getAudioSessionId() {
    return 0;
  }

  @Override
  public void onCompletion(MediaPlayer mp) {
    isCompleted = true;
    mEventEmitter.receiveEvent(getId(), Events.EVENT_END.toString(), null);
    if (!mRepeat) {
      setKeepScreenOn(false);
    }
  }

  // This is not fully tested and does not work for all forms of timed metadata
  @TargetApi(23) // 6.0
  public class TimedMetaDataAvailableListener
    implements MediaPlayer.OnTimedMetaDataAvailableListener {
    public void onTimedMetaDataAvailable(MediaPlayer mp, TimedMetaData data) {

    }
  }

  @Override
  protected void onDetachedFromWindow() {
    mMediaPlayerValid = false;
    super.onDetachedFromWindow();
    setKeepScreenOn(false);
  }

  @Override
  protected void onAttachedToWindow() {
    super.onAttachedToWindow();

    if (mMainVer > 0) {
      setSrc(mSrcUriString, mSrcType, mSrcIsNetwork, mSrcIsAsset, mRequestHeaders, mMainVer, mPatchVer);
    } else {
      setSrc(mSrcUriString, mSrcType, mSrcIsNetwork, mSrcIsAsset, mRequestHeaders);
    }
    setKeepScreenOn(mPreventsDisplaySleepDuringVideoPlayback);
  }

  @Override
  public void onHostPause() {
    if (mMediaPlayerValid && !mPaused && !mPlayInBackground) {
      /* Pause the video in background
       * Don't update the paused prop, developers should be able to update it on background
       *  so that when you return to the app the video is paused
       */
      mBackgroundPaused = true;
      mMediaPlayer.pause();
    }
  }

  @Override
  public void onHostResume() {
    mBackgroundPaused = false;
    if (mMediaPlayerValid && !mPlayInBackground && !mPaused) {
      new Handler().post(new Runnable() {
        @Override
        public void run() {
          // Restore original state
          setPausedModifier(false);
        }
      });
    }
  }

  @Override
  public void onHostDestroy() {
  }

  /**
   * toStringMap converts a {@link ReadableMap} into a HashMap.
   *
   * @param readableMap The ReadableMap to be conveted.
   * @return A HashMap containing the data that was in the ReadableMap.
   * @see 'Adapted from https://github.com/artemyarulin/react-native-eval/blob/master/android/src/main/java/com/evaluator/react/ConversionUtil.java'
   */
  public static Map<String, String> toStringMap(@Nullable ReadableMap readableMap) {
    Map<String, String> result = new HashMap<>();
    if (readableMap == null)
      return result;

    com.facebook.react.bridge.ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
    while (iterator.hasNextKey()) {
      String key = iterator.nextKey();
      result.put(key, readableMap.getString(key));
    }

    return result;
  }

  public boolean isSafePlaying() {
    if (mMediaPlayer == null) return false;
    return mMediaPlayer.isPlaying();
  }

  public void setAutoplay(boolean autoplay) {
    System.out.println("🍓 setAutoplay " + autoplay);
    if (!autoplay) return;
    AppVideosManagerKt.pauseAllVideos(AppVideosManager.Companion.getShared());
    mPaused = false;
  }

  // Select track (so we can use it to listen to timed meta data updates)
  private void selectTimedMetadataTrack(MediaPlayer mp) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      return;
    }
    try { // It's possible this could throw an exception if the framework doesn't support getting track info
      MediaPlayer.TrackInfo[] trackInfo = mp.getTrackInfo();
      for (int i = 0; i < trackInfo.length; ++i) {
        if (trackInfo[i].getTrackType() == MediaPlayer.TrackInfo.MEDIA_TRACK_TYPE_TIMEDTEXT) {
          mp.selectTrack(i);
          break;
        }
      }
    } catch (Exception e) {
    }
  }
}
