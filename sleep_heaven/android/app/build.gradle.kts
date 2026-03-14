plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // TODO: Đổi thành package ID thật trước khi publish (xem IAP_SETUP.md)
    namespace = "com.example.sleep_heaven"
    // Explicit – Google Play yêu cầu compileSdk >= targetSdk
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Đổi thành application ID thật trước khi publish (xem IAP_SETUP.md)
        applicationId = "com.example.sleep_heaven"
        // in_app_purchase + flutter_secure_storage yêu cầu minSdk 21
        minSdk = flutter.minSdkVersion
        // Google Play yêu cầu targetSdk >= 35 (kể từ 31/8/2025)
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Đọc từ android/key.properties – xem IAP_SETUP.md để tạo keystore
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val props = java.util.Properties().apply {
                    load(keystorePropertiesFile.inputStream())
                }
                keyAlias      = props["keyAlias"] as String
                keyPassword   = props["keyPassword"] as String
                storeFile     = file(props["storeFile"] as String)
                storePassword = props["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // ProGuard/R8 bắt buộc cho store – giảm kích thước + obfuscate
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
