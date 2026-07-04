# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# uCrop (image_cropper)
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

# Keep annotations
-keepattributes *Annotation*
