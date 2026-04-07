import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val isReleaseBuildRequested: Boolean = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("release", ignoreCase = true) ||
        taskName.contains("bundle", ignoreCase = true) ||
        taskName.contains("publish", ignoreCase = true)
}

val localSigningPropertiesPath: String =
    System.getenv("ANDROID_SIGNING_PROPERTIES_FILE") ?: "key.properties.local"
val localSigningPropertiesFile = rootProject.file(localSigningPropertiesPath)
val localSigningProperties = Properties().apply {
    if (localSigningPropertiesFile.exists()) {
        localSigningPropertiesFile.inputStream().use { input -> load(input) }
    }
}

fun resolveSigningValue(localKey: String, envKey: String): String? {
    val envValue = System.getenv(envKey)?.trim()
    if (!envValue.isNullOrEmpty()) {
        return envValue
    }

    val localValue = localSigningProperties.getProperty(localKey)?.trim()
    if (!localValue.isNullOrEmpty()) {
        return localValue
    }

    return null
}

android {
    namespace = "dat.c.sleepheaven"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "dat.c.sleepheaven"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFileValue: String? = resolveSigningValue("storeFile", "ANDROID_SIGNING_STORE_FILE")
            val storePasswordValue: String? = resolveSigningValue("storePassword", "ANDROID_SIGNING_STORE_PASSWORD")
            val keyAliasValue: String? = resolveSigningValue("keyAlias", "ANDROID_SIGNING_KEY_ALIAS")
            val keyPasswordValue: String? = resolveSigningValue("keyPassword", "ANDROID_SIGNING_KEY_PASSWORD")

            if (!storeFileValue.isNullOrEmpty()) {
                storeFile = file(storeFileValue)
            }
            if (!storePasswordValue.isNullOrEmpty()) {
                storePassword = storePasswordValue
            }
            if (!keyAliasValue.isNullOrEmpty()) {
                keyAlias = keyAliasValue
            }
            if (!keyPasswordValue.isNullOrEmpty()) {
                keyPassword = keyPasswordValue
            }

            if (isReleaseBuildRequested) {
                val missingEnvKeys = mutableListOf<String>()
                if (storeFileValue.isNullOrEmpty()) missingEnvKeys.add("ANDROID_SIGNING_STORE_FILE")
                if (storePasswordValue.isNullOrEmpty()) missingEnvKeys.add("ANDROID_SIGNING_STORE_PASSWORD")
                if (keyAliasValue.isNullOrEmpty()) missingEnvKeys.add("ANDROID_SIGNING_KEY_ALIAS")
                if (keyPasswordValue.isNullOrEmpty()) missingEnvKeys.add("ANDROID_SIGNING_KEY_PASSWORD")

                if (missingEnvKeys.isNotEmpty()) {
                    throw GradleException(
                        "Missing required Android signing values: ${missingEnvKeys.joinToString(", ")}. " +
                            "Provide environment variables or add values to $localSigningPropertiesPath."
                    )
                }
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
