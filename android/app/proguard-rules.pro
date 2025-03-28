# Keep Fresco classes
-keep class com.facebook.imagepipeline.nativecode.** { *; }

# Keep TFLite classes
-keep class org.tensorflow.** { *; }

# Prevent removing ML Kit classes
-keep class com.google.mlkit.** { *; }

# General keep rules to prevent R8 from stripping essential classes
-dontwarn com.facebook.**
-dontwarn org.tensorflow.**
-dontwarn com.google.mlkit.**
