plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lumeo_v2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.lumeo_v2"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
    // ONLY release signing
    create("release") {
        storeFile = file("keystore/test.jks")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = "androiddebugkey"
        keyPassword = System.getenv("KEYSTORE_PASSWORD")
    }
}

buildTypes {
    getByName("debug") {
        // let Android auto-handle debug signing
    }
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
    }
}
}

flutter {
    source = "../.."
}