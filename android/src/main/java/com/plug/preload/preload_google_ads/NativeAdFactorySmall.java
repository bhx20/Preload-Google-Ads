package android.src.main.java.com.plug.preload.preload_google_ads;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;
import com.plug.preload.preload_google_ads.R;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class NativeAdFactorySmall implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    public NativeAdFactorySmall(Context context) {
        this.context = context;
    }


    public NativeAdView createNativeAd(
            NativeAd nativeAd, Map<String, Object> customOptions) {
        NativeAdView nativeAdView = (NativeAdView) LayoutInflater.from(context)
                .inflate(R.layout.small_template, null);



//    attribution

        TextView attributionViewSmall = nativeAdView
                .findViewById(R.id.native_ad_attribution_small);


        attributionViewSmall.setVisibility(View.VISIBLE);
// icon

        nativeAdView.setIconView(nativeAdView.findViewById(R.id.native_ad_icon));
        if (nativeAd.getIcon() == null) {
            nativeAdView.getIconView().setVisibility(View.GONE);

        } else {
            ((ImageView)nativeAdView.getIconView()).setImageDrawable(nativeAd.getIcon().getDrawable());

        }

//  media
//        MediaView mediaView = nativeAdView.findViewById(R.id.native_ad_media);
//        mediaView.setMediaContent(nativeAd.getMediaContent());
//        nativeAdView.setMediaView(mediaView);

// button

        nativeAdView.setCallToActionView(nativeAdView.findViewById(R.id.native_ad_button));
        if(nativeAd.getCallToAction()==null){
            nativeAdView.getCallToActionView().setVisibility(View.INVISIBLE);
        }else{
            ((Button)nativeAdView.getCallToActionView()).setText(nativeAd.getCallToAction());
        }

//   headline
        nativeAdView.setHeadlineView(nativeAdView.findViewById(R.id.native_ad_headline));
        ((TextView)nativeAdView.getHeadlineView()).setText(nativeAd.getHeadline());

//  bodyView
        nativeAdView.setBodyView(nativeAdView.findViewById(R.id.native_ad_body));
        if(nativeAd.getBody()==null){
            nativeAdView.getBodyView().setVisibility(View.INVISIBLE);
        }else {
            ((TextView)nativeAdView.getBodyView()).setText(nativeAd.getBody());
            nativeAdView.getBodyView().setVisibility(View.VISIBLE);
        }

//    advertiser name
//        nativeAdView.setAdvertiserView(nativeAdView.findViewById(R.id.native_ad_advertiser));
//        if(nativeAd.getAdvertiser()==null){
//            nativeAdView.getAdvertiserView().setVisibility(View.GONE);
//        }else {
//            ((TextView)nativeAdView.getAdvertiserView()).setText(nativeAd.getAdvertiser());
//            nativeAdView.getAdvertiserView().setVisibility(View.VISIBLE);
//        }
//   ratingbar
//        nativeAdView.setStarRatingView(nativeAdView.findViewById(R.id.native_ad_rating));
//        if(nativeAd.getStarRating()==null){
//            nativeAdView.getStarRatingView().setVisibility(View.INVISIBLE);
//        }else{
//            ((RatingBar)nativeAdView.getStarRatingView()).setRating(nativeAd.getStarRating().floatValue());
//            nativeAdView.getStarRatingView().setVisibility(View.VISIBLE);
//
//        }




        nativeAdView.setNativeAd(nativeAd);

        return nativeAdView;
    }
}
