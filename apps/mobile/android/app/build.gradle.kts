plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePath = System.getenv("STONE_SET_RELEASE_KEYSTORE_PATH")
val releaseKeystorePassword = System.getenv("STONE_SET_RELEASE_STORE_PASSWORD")
val releaseKeyAlias = System.getenv("STONE_SET_RELEASE_KEY_ALIAS")
val releaseKeyPassword = System.getenv("STONE_SET_RELEASE_KEY_PASSWORD")
val releaseSigningValues = listOf(
    releaseKeystorePath,
    releaseKeystorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
)
val hasReleaseSigning = releaseSigningValues.all { !it.isNullOrBlank() }
val hasPartialReleaseSigning = releaseSigningValues.any { !it.isNullOrBlank() } && !hasReleaseSigning
val releaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
val allowUnsignedRelease = System.getenv("STONE_SET_ALLOW_UNSIGNED_RELEASE") == "true"

if (hasPartialReleaseSigning) {
    throw GradleException("Incomplete Stone Set release-signing configuration.")
}
if (releaseTaskRequested && !hasReleaseSigning && !allowUnsignedRelease) {
    throw GradleException(
        "Permanent release signing is required. " +
            "Set all STONE_SET_RELEASE_* values, or explicitly allow an unsigned CI compile.",
    )
}

android {
    namespace = "io.github.hermann33.stoneset"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.hermann33.stoneset"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("stoneSetRelease") {
                storeFile = file(requireNotNull(releaseKeystorePath))
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("stoneSetRelease")
            } else {
                null
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
