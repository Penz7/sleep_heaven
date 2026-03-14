# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods used by Flutter
-keepclasseswithmembernames class * {
    native <methods>;
}
