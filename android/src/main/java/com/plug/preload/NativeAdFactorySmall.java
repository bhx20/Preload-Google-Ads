package android.src.main.java.com.plug.preload;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;
import com.plug.preload.R;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class NativeAdFactorySmall implements GoogleMobileAdsPlugin.NativeAdFactory {

    /// Context is required to inflate the layout
    private final Context context;

    /// Constructor to initialize context
    public NativeAdFactorySmall(Context context) {
        this.context = context;
    }

    /**
     * Creates a NativeAdView using a custom layout defined in small_template.xml.
     * This view will be populated with data from the passed-in nativeAd object.
     */
    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        /// Inflate your small native ad layout
        NativeAdView nativeAdView = (NativeAdView) LayoutInflater.from(context)
                .inflate(R.layout.small_template, null);

        /// Set and show the attribution view ("Ad" label or similar small text)
        TextView attributionViewSmall = nativeAdView.findViewById(R.id.native_ad_attribution_small);
        attributionViewSmall.setVisibility(View.VISIBLE);

        /// Set the icon view (small image like app icon or brand logo)
        nativeAdView.setIconView(nativeAdView.findViewById(R.id.native_ad_icon));
        if (nativeAd.getIcon() == null) {
            /// Hide the icon view if ad doesn't provide an icon
            nativeAdView.getIconView().setVisibility(View.GONE);
        } else {
            /// Set the icon image
            ((ImageView) nativeAdView.getIconView()).setImageDrawable(nativeAd.getIcon().getDrawable());
        }

        /// Set the call-to-action button
        nativeAdView.setCallToActionView(nativeAdView.findViewById(R.id.native_ad_button));
        if (nativeAd.getCallToAction() == null) {
            /// Hide button if no CTA is provided
            nativeAdView.getCallToActionView().setVisibility(View.INVISIBLE);
        } else {
            /// Set button text
            ((Button) nativeAdView.getCallToActionView()).setText(nativeAd.getCallToAction());
        }

        /// Set the headline (required field for native ads)
        nativeAdView.setHeadlineView(nativeAdView.findViewById(R.id.native_ad_headline));
        ((TextView) nativeAdView.getHeadlineView()).setText(nativeAd.getHeadline());

        /// Set the ad body text (optional)
        nativeAdView.setBodyView(nativeAdView.findViewById(R.id.native_ad_body));
        if (nativeAd.getBody() == null) {
            /// Hide body if not available
            nativeAdView.getBodyView().setVisibility(View.INVISIBLE);
        } else {
            /// Show body text
            ((TextView) nativeAdView.getBodyView()).setText(nativeAd.getBody());
            nativeAdView.getBodyView().setVisibility(View.VISIBLE);
        }

        /// Final step: bind the ad object to the view
        nativeAdView.setNativeAd(nativeAd);

        /// Return the complete view to be rendered in Flutter
        return nativeAdView;
    }
}
