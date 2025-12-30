# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.internal.mlkit_vision_text.** { *; }
-dontwarn com.google.android.gms.internal.mlkit_vision_text.**
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**

# ML Kit Text Recognition languages (keep all language recognizers)
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep ML Kit internal classes
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**

# Mobile Vision
-keep class com.google.android.gms.internal.vision.** { *; }
-dontwarn com.google.android.gms.internal.vision.**

# Google Play Services
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.common.**

# R8 full mode compatibility
-keep,allowoptimization class com.google.mlkit.vision.text.** { *; }
