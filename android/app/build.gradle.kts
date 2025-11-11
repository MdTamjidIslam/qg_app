plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.twitter_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.twitter_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 22
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // ⬇️ OpenInstall placeholders (এইখানে দিন)
        manifestPlaceholders.putAll(
            mapOf(
                "OPENINSTALL_APPKEY" to "i44ctk", // কনসোল থেকে নেয়া AppKey
                "OPENINSTALL_SCHEME" to "yourappscheme"            // আপনার কাস্টম scheme (a–z, 0–9, . - _)
            )
        )
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
