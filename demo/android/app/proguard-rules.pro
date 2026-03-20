# Keep Unity Player classes
-keep class com.unity3d.player.** { *; }
-dontwarn com.unity3d.player.**

# Keep Flutter Embed Unity Android plugin classes (the bridge)
-keep class com.learntoflutter.flutter_embed_unity_android.** { *; }
-dontwarn com.learntoflutter.flutter_embed_unity_android.**

# Keep ARCore / Unity AR Foundation classes (often needed for AR features)
-keep class com.google.ar.core.** { *; }
-dontwarn com.google.ar.core.**