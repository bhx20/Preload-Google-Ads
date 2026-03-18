plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.plug.preload.example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.plug.preload.example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            // ✅ FIX 1: Prevent shrink crash
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // ✅ FIX 2: Disable lint crash
    lint {
        checkReleaseBuilds = false
        abortOnError = false
        disable.add("NullSafeMutableLiveData")
    }
}

flutter {
    source = "../.."
}