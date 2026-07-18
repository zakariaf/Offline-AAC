import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key signing (E11-T02). `key.properties` and the `.jks` it points at are
// git-ignored and kept OUTSIDE the repo tree, with an offline backup. The
// `exists()` guard below is load-bearing: CI has no keystore, so the release
// build there stays unsigned — which is the point. CI proves the bundle
// compiles; it does not sign, and a repo with no signing secret has no signing
// secret to leak. Never move the keystore into CI secrets. See RELEASE.md.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "io.applander.reed"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.applander.reed"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // versionCode / versionName come from `version: x.y.z+N` in pubspec.yaml.
        // Bump `+N` by exactly 1 per upload attempt, including rejected ones —
        // Play burns the versionCode on the attempt, not the success. Never
        // derive it from github.run_number, a timestamp, or a commit count.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Populated from android/key.properties. Nullable casts on purpose:
            // this block is evaluated even on CI (no keystore), and a non-null
            // cast would throw at configuration time. The nulls are harmless
            // because the release buildType only SELECTS this config when
            // key.properties actually exists (see below).
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Upload key when key.properties is present; otherwise fall back to
            // debug signing so `flutter run --release` and CI's unsigned build
            // still work.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // DELIBERATE — do NOT enable R8/minification (E11-T03). A missing
            // keep rule does not fail the build; it fails at runtime as a tile
            // tap that makes no sound — the TTS engine binding, the SQLite
            // native loader, anything reached through a platform channel is
            // exactly what R8 strips when nobody wrote a rule, and neither the
            // analyzer nor the test suite can see it. There is also nothing to
            // protect: Reed's exit plan is publishing this source under MIT, so
            // obfuscation would rename symbols on code that is being given away
            // while destroying the only field signal — the user-exported crash
            // log. See RELEASE.md → "The obfuscation decision".
            isMinifyEnabled = false
            isShrinkResources = false
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
