package android.src.main.java.com.plug.preload;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.MediaView;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;
import com.plug.preload.R;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class NativeAdFactoryMedium implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    /// Constructor receives the context (used for inflating layouts)
    public NativeAdFactoryMedium(Context context) {
        this.context = context;
    }

    /**
     * This method is responsible for creating and populating a native ad view
     * using a custom layout (medium_template.xml).
     */
    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        /// Inflate the native ad layout
        NativeAdView nativeAdView = (NativeAdView) LayoutInflater.from(context)
                .inflate(R.layout.medium_template, null);

        /// Set attribution view and make it visible
        TextView attributionViewSmall = nativeAdView.findViewById(R.id.native_ad_attribution_small);
        attributionViewSmall.setVisibility(View.VISIBLE);

        /// Set and display the ad icon if available
        nativeAdView.setIconView(nativeAdView.findViewById(R.id.native_ad_icon));
        if (nativeAd.getIcon() == null) {
            nativeAdView.getIconView().setVisibility(View.GONE);
        } else {
            ((ImageView) nativeAdView.getIconView())
                    .setImageDrawable(nativeAd.getIcon().getDrawable());
        }

        /// Set the media content (video/image) to the media view
        MediaView mediaView = nativeAdView.findViewById(R.id.native_ad_media);
        mediaView.setMediaContent(nativeAd.getMediaContent());
        nativeAdView.setMediaView(mediaView);

        /// Set the call-to-action button text or hide it if null
        nativeAdView.setCallToActionView(nativeAdView.findViewById(R.id.native_ad_button));
        if (nativeAd.getCallToAction() == null) {
            nativeAdView.getCallToActionView().setVisibility(View.INVISIBLE);
        } else {
            ((Button) nativeAdView.getCallToActionView())
                    .setText(nativeAd.getCallToAction());
        }

        /// Set the headline text (always required)
        nativeAdView.setHeadlineView(nativeAdView.findViewById(R.id.native_ad_headline));
        ((TextView) nativeAdView.getHeadlineView())
                .setText(nativeAd.getHeadline());

        /// Set the ad body text, or hide it if not available
        nativeAdView.setBodyView(nativeAdView.findViewById(R.id.native_ad_body));
        if (nativeAd.getBody() == null) {
            nativeAdView.getBodyView().setVisibility(View.INVISIBLE);
        } else {
            ((TextView) nativeAdView.getBodyView())
                    .setText(nativeAd.getBody());
            nativeAdView.getBodyView().setVisibility(View.VISIBLE);
        }

        /// Finalize and bind the ad to the view
        nativeAdView.setNativeAd(nativeAd);

        return nativeAdView;
    }
}
