# libmpv for Android

Based on [mpv-android](https://github.com/mpv-android/mpv-android)

## Plasma's build

This fork of [libmpv-android](https://github.com/jarnedemeulemeester/libmpv-android) is the build of libmpv that Plasma, an Android TV launcher, uses. It differs from upstream in three ways:

- **FFmpeg** also builds the AC-3 encoder, the S/PDIF muxer and the bwdif deinterlacer (`buildscripts/scripts/ffmpeg.sh`). mpv uses them to encode surround sound to Dolby Digital (`af=lavcac3enc`), to pass Dolby and DTS through (`audio-spdif`), and to deinterlace when it decodes in software or copy-back mode.
- **Coordinates** are `ca.gureet.plasma:libmpv`, and the version is mpv's plus `-plasma.N`, for example `0.41.0-plasma.1` (set in `gradle.properties`). The package is still `dev.jdtech.mpv`, so the API is upstream's.
- **Releases** are on this repository's [releases page](https://github.com/gureetk/plasma-libmpv/releases) as `libmpv-<version>.aar` with `SHA256SUMS`. Pushing the tag `v<version>` builds and publishes one. Nothing goes to Maven Central.

The AAR as a whole is GPL-3.0-or-later, because FFmpeg and mpv are built with `--enable-gpl --enable-version3`. The wrapper and the build scripts are MIT ([LICENSE](LICENSE)).

## Building from source

Take a look at [README.md](buildscripts/README.md) inside the `buildscripts` directory.
