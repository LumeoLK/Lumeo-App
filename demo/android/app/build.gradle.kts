plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    
}

android {
    namespace = "com.lumeo.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.lumeo.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
signingConfigs {
    create("release") {
        storeFile = file("keystore/test.jks")

        storePassword = System.getenv("KEYSTORE_PASSWORD")

     
        keyAlias = "androiddebugkey"

    
        keyPassword = System.getenv("KEYSTORE_PASSWORD")
    }
}
}

flutter {
    source = "../.."
}


