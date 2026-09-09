plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter doit être appliqué après Android et Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.wifi.mouni"

    // mobile_scanner nécessite Android SDK 36
    compileSdk = 36

    // Les plugins Firebase/mobile_scanner utilisent NDK 27
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // DOIT correspondre au package enregistré dans Firebase
        applicationId = "com.wifi.mouni"

        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Pour les tests uniquement
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
