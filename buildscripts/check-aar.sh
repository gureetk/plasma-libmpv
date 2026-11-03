#!/bin/bash -e

# Plasma's build: checks that every ABI's FFmpeg in the AAR was configured
# with the parts scripts/ffmpeg.sh turns back on, and that every ABI's mpv
# was built with the passthrough patch (patches/mpv).
# Usage: ./check-aar.sh [path to the AAR]

aar=${1:-../libmpv/build/outputs/aar/libmpv-release.aar}
flags=(--enable-encoder=ac3 --enable-muxer=spdif --enable-filter=bwdif)

for abi in armeabi-v7a arm64-v8a x86 x86_64; do
	# FFmpeg keeps its configure line in each library
	config=$(unzip -p "$aar" "jni/$abi/libavcodec.so" | strings | grep -m1 -e '--target-os=android') || {
		echo >&2 "$abi: no FFmpeg configure line found in libavcodec.so"
		exit 1
	}
	for flag in "${flags[@]}"; do
		if [[ " $config " != *" $flag "* ]]; then
			echo >&2 "$abi: FFmpeg was configured without $flag"
			exit 1
		fi
	done
	# Only the patched ao_audiotrack looks up this Java method
	unzip -p "$aar" "jni/$abi/libmpv.so" | strings | grep -q isDirectPlaybackSupported || {
		echo >&2 "$abi: libmpv.so was built without the passthrough patch"
		exit 1
	}
	echo "$abi: ${flags[*]}, passthrough patch"
done
