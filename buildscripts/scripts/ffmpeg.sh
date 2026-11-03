#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

# Plasma's build turns three parts back on after the blanket disables below
# (configure reads its options in order, so they have to come after them):
#   ac3 encoder   mpv's lavcac3enc filter (Encode Surround to Dolby Digital)
#   spdif muxer   mpv's spdif decoder, which wraps passthrough audio in IEC 61937
#   bwdif filter  mpv's deinterlacer for software and copy-back decoding
../configure \
	--target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --cc=$CC \
	--arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
	--extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
	--enable-{jni,mediacodec,mbedtls,libdav1d,libxml2} --disable-vulkan \
	--disable-static --enable-shared --enable-{gpl,version3} \
	--disable-{stripping,doc,programs} \
	--disable-{muxers,encoders,devices,filters} \
	--enable-encoder=ac3 --enable-muxer=spdif --enable-filter=bwdif \
	--disable-v4l2-m2m

# Stop here rather than build without one of them
for component in AC3_ENCODER SPDIF_MUXER BWDIF_FILTER; do
	grep -qx "#define CONFIG_$component 1" config_components.h || {
		echo >&2 "FFmpeg's configure left out $component"
		exit 1
	}
done

make -j$cores
make DESTDIR="$prefix_dir" install

ln -sf "$prefix_dir"/lib/libswresample.so "$native_dir"
ln -sf "$prefix_dir"/lib/libpostproc.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavutil.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavcodec.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavformat.so "$native_dir"
ln -sf "$prefix_dir"/lib/libswscale.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavfilter.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavdevice.so "$native_dir"
