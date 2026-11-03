import com.vanniktech.maven.publish.AndroidSingleVariantLibrary
import com.vanniktech.maven.publish.JavadocJar
import com.vanniktech.maven.publish.SourcesJar

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.maven.publish)
}

android {
    namespace = "dev.jdtech.mpv"
    compileSdk = 36
    buildToolsVersion = "37.0.0"
    ndkVersion = "30.0.16248370"

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("proguard-rules.pro")
        externalNativeBuild {
            cmake {
                arguments += listOf(
                    "-DANDROID_STL=c++_shared",
                )
                cFlags += "-Werror"
                cppFlags += "-std=c++11"
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "4.1.2"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

// Plasma's build is released on GitHub (see .github/workflows/publish.yaml),
// not on Maven Central, so there's no publishToMavenCentral or signing here.
mavenPublishing {
    configure(
        platform = AndroidSingleVariantLibrary(
            javadocJar = JavadocJar.Empty(),
            sourcesJar = SourcesJar.Empty(),
            variant = "release",
        )
    )

    // The package and namespace stay dev.jdtech.mpv, so the JNI names and
    // the MPVLib API are the same as upstream's; only the coordinates change.
    coordinates(
        groupId = "ca.gureet.plasma",
        artifactId = "libmpv",
        version = providers.gradleProperty("libmpvVersion").get()
    )

    pom {
        name = "plasma-libmpv"
        description = "libmpv for Android, built for Plasma"
        inceptionYear = "2023"
        url = "https://github.com/gureetk/plasma-libmpv"
        licenses {
            // FFmpeg and mpv are built with --enable-gpl --enable-version3
            license {
                name = "GNU General Public License v3.0 or later"
                url = "https://www.gnu.org/licenses/gpl-3.0.html"
            }
            // the JNI wrapper and build scripts
            license {
                name = "MIT license"
                url = "https://github.com/gureetk/plasma-libmpv/blob/main/LICENSE"
            }
        }
        developers {
            developer {
                id = "jarnedemeulemeester"
                name = "Jarne Demeulemeester"
                email = "jarnedemeulemeester@gmail.com"
            }
        }
        scm {
            url = "https://github.com/gureetk/plasma-libmpv.git"
            connection = "scm:git@github.com:gureetk/plasma-libmpv.git"
            developerConnection = "scm:git@github.com:gureetk/plasma-libmpv.git"
        }
    }
}
