plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.hemoglobe.ai"
    
    // Isay manually 34 kar diya hai taake purane version ka error na aaye
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.hemoglobe.ai"
        
        // STK L21 ke liye 21 behtar hai
        minSdk = flutter.minSdkVersion 
        targetSdk = 36
        
        multiDexEnabled = true
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Ye line Java 8 features ko support karwati hai
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
