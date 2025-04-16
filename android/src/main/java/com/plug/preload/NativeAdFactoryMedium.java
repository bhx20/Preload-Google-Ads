package android.src.main.java.com.plug.preload;


import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import com.google.android.gms.ads.nativead.MediaView;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;
import com.plug.preload.R;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;


import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class NativeAdFactoryMedium implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;
    private final Map<String, Object> styleMap;

    /// Constructor receives the context (used for inflating layouts)
    public NativeAdFactoryMedium(Context context, Map<String, Object> styleMap) {
        this.context = context;
        this.styleMap = styleMap;
    }


    private int parseColor(String hex) {
        try {
            return android.graphics.Color.parseColor(hex);
        } catch (IllegalArgumentException e) {
            System.out.println("⚠️ Invalid color format: " + hex);
            return android.graphics.Color.BLACK;
        }
    }

    private int[] toIntArray(List<Integer> list) {
        int[] array = new int[list.size()];
        for (int i = 0; i < list.size(); i++) {
            array[i] = list.get(i);
        }
        return array;
    }


    private float dpToPx(int dp) {
        return dp * context.getResources().getDisplayMetrics().density;
    }

    /**
     * This method is responsible for creating and populating a native ad view
     * using a custom layout (medium_template.xml).
     */
    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {


///=================================================================================================
///                                ** Set AD View **
///=================================================================================================

        /// ✅ Inflate the native ad layout
        NativeAdView nativeAdView = (NativeAdView) LayoutInflater.from(context)
                .inflate(R.layout.medium_template, null);

///=================================================================================================
///                                ** Custom AD Tag View **
///=================================================================================================


        /// ✅ Set attribution view and make it visible
        TextView attributionViewSmall = nativeAdView.findViewById(R.id.native_ad_attribution_small);
        attributionViewSmall.setVisibility(View.VISIBLE);

        /// ✅ Safe default tag foreground
        String tagTextColor = "#FFFFFF";
        try {
            Object value = styleMap.get("tag_foreground");
            if (value instanceof String && !((String) value).trim().isEmpty()) {
                tagTextColor = (String) value;
            }
        } catch (Exception ignored) {}
        attributionViewSmall.setTextColor(parseColor(tagTextColor)); // ✅ safe parse

        /// ✅ Safe default tag background
        String tagBackgroundColor = "#F19938";
        try {
            Object value = styleMap.get("tag_background");
            if (value instanceof String && !((String) value).trim().isEmpty()) {
                tagBackgroundColor = (String) value;
            }
        } catch (Exception ignored) {}

       /// ✅ Safe default tag radius in dp
        int tagRadiusDp = 3;
        try {
            Object value = styleMap.get("tag_radius");
            if (value instanceof Number) {
                tagRadiusDp = ((Number) value).intValue();
            } else if (value instanceof String) {
                tagRadiusDp = Integer.parseInt((String) value);
            }
        } catch (Exception ignored) {}
        float tagRadiusPx = dpToPx(tagRadiusDp);

        /// ✅ Create and apply background drawable
        GradientDrawable tagBackgroundDrawable = new GradientDrawable();
        tagBackgroundDrawable.setColor(parseColor(tagBackgroundColor));
        tagBackgroundDrawable.setCornerRadius(tagRadiusPx);
        attributionViewSmall.setBackground(tagBackgroundDrawable);


///=================================================================================================
///                                **  AD Icon View **
///=================================================================================================

        /// ✅ Set and display the ad icon if available
        nativeAdView.setIconView(nativeAdView.findViewById(R.id.native_ad_icon));
        if (nativeAd.getIcon() == null) {
            nativeAdView.getIconView().setVisibility(View.GONE);
        } else {
            ((ImageView) nativeAdView.getIconView())
                    .setImageDrawable(nativeAd.getIcon().getDrawable());
        }

///=================================================================================================
///                                **  AD Media View **
///=================================================================================================

        /// ✅ Set the media content (video/image) to the media view
        MediaView mediaView = nativeAdView.findViewById(R.id.native_ad_media);
        mediaView.setMediaContent(nativeAd.getMediaContent());
        nativeAdView.setMediaView(mediaView);

///=================================================================================================
///                                **  Custom AD Button  **
///=================================================================================================

        /// ✅ Set the call-to-action button text or hide it if null
        nativeAdView.setCallToActionView(nativeAdView.findViewById(R.id.native_ad_button));
        Button callToActionButton = (Button) nativeAdView.getCallToActionView();

        if (nativeAd.getCallToAction() == null) {
            callToActionButton.setVisibility(View.INVISIBLE);
        } else {
            callToActionButton.setText(nativeAd.getCallToAction());
            callToActionButton.setVisibility(View.VISIBLE);

            /// ✅ Set foreground text color with fallback
            /// ✅ Set foreground text color with fallback
            String foregroundColor = "#FFFFFF";
            if (styleMap.containsKey("button_foreground")) {
                try {
                    Object colorObj = styleMap.get("button_foreground");
                    if (colorObj instanceof String) {
                        String colorStr = ((String) colorObj).trim();
                        if (!colorStr.isEmpty()) {
                            foregroundColor = colorStr;
                        }
                    }
                } catch (Exception ignored) {}
            }
            callToActionButton.setTextColor(parseColor(foregroundColor));

            /// ✅ Corner radius
            float radiusDp = 5f;
            if (styleMap.containsKey("button_radius")) {
                try {
                    radiusDp = Float.parseFloat(styleMap.get("button_radius").toString());
                } catch (NumberFormatException ignored) {}
            }
            float radiusPx = TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP,
                    radiusDp,
                    context.getResources().getDisplayMetrics()
            );

            /// ✅ Try to handle gradient colors
            boolean backgroundSet = false;
            if (styleMap.containsKey("button_gradients")) {
                Object gradientsObj = styleMap.get("button_gradients");
                if (gradientsObj instanceof List) {
                    List<?> gradientList = (List<?>) gradientsObj;

                    List<Integer> gradientColors = new ArrayList<>();
                    for (Object item : gradientList) {
                        if (item instanceof String) {
                            try {
                                gradientColors.add(parseColor((String) item));
                            } catch (Exception ignored) {}
                        }
                    }

                    if (gradientColors.size() >= 2) {
                        /// ✅ Gradient with multiple colors
                        GradientDrawable gradientDrawable = new GradientDrawable(
                                GradientDrawable.Orientation.LEFT_RIGHT,
                                toIntArray(gradientColors)
                        );
                        gradientDrawable.setCornerRadius(radiusPx);
                        callToActionButton.setBackground(gradientDrawable);
                        backgroundSet = true;
                    } else if (gradientColors.size() == 1) {
                        /// ✅ Only one color in gradient: fallback to solid
                        GradientDrawable solidDrawable = new GradientDrawable();
                        solidDrawable.setColor(gradientColors.get(0));
                        solidDrawable.setCornerRadius(radiusPx);
                        callToActionButton.setBackground(solidDrawable);
                        backgroundSet = true;
                    }
                }
            }

            /// ✅ Fallback to button_background if gradient not applied
            if (!backgroundSet) {
                int fallbackColor = parseColor("#2196F3"); // Default blue

                if (styleMap.containsKey("button_background")) {
                    try {
                        fallbackColor = parseColor((String) styleMap.get("button_background"));
                    } catch (Exception ignored) {}
                }

                GradientDrawable fallbackDrawable = new GradientDrawable();
                fallbackDrawable.setColor(fallbackColor);
                fallbackDrawable.setCornerRadius(radiusPx);
                callToActionButton.setBackground(fallbackDrawable);
            }
        }


///=================================================================================================
///                                **  Custom Headline Text  **
///=================================================================================================

        nativeAdView.setHeadlineView(nativeAdView.findViewById(R.id.native_ad_headline));
        TextView headlineView = (TextView) nativeAdView.getHeadlineView();
        headlineView.setText(nativeAd.getHeadline());

/// ✅ Apply title color with safe fallback to black (#000000)
        String titleColor = "#000000"; // default black
        try {
            Object value = styleMap.get("title");
            if (value instanceof String && !((String) value).trim().isEmpty()) {
                titleColor = (String) value;
            }
        } catch (Exception ignored) {}
        headlineView.setTextColor(parseColor(titleColor));  // ✅ safe parse

///=================================================================================================
///                                **  Custom Body Text  **
///=================================================================================================

        nativeAdView.setBodyView(nativeAdView.findViewById(R.id.native_ad_body));
        if (nativeAd.getBody() == null) {
            nativeAdView.getBodyView().setVisibility(View.INVISIBLE);
        } else {
            TextView bodyView = (TextView) nativeAdView.getBodyView();
            bodyView.setText(nativeAd.getBody());
            bodyView.setVisibility(View.VISIBLE);

            /// ✅ Apply body color with safe fallback to gray (#9B9B9B)
            String bodyColor = "#9B9B9B"; // default gray
            try {
                Object value = styleMap.get("description");
                if (value instanceof String && !((String) value).trim().isEmpty()) {
                    bodyColor = (String) value;
                }
            } catch (Exception ignored) {}
            bodyView.setTextColor(parseColor(bodyColor)); // ✅ safe parse
        }

///=================================================================================================
///                                **  Final AD View  **
///=================================================================================================

        /// ✅ Finalize and bind the ad to the view
        nativeAdView.setNativeAd(nativeAd);

        return nativeAdView;
    }


}
