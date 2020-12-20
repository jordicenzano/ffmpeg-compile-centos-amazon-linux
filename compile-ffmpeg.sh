#!/bin/bash    

# Compile ffmpeg in centOS based Linux
# by Jordi Cenzano

# Stop at any error
set -e

# Update
sudo yum update update -y

# Upgrade
sudo yum upgrade -y

# Prepare for ffmpeg
sudo yum -y install tcl curl unzip wget git autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel openssl-devel

# Install network resources
sudo yum -y install iproute net-tools

# Compile ffmpeg from sources ----------------

# Create dir
mkdir -p ~/ffmpeg_sources

# Compile NASM	
echo "COMPILING NASM"	
cd ~/ffmpeg_sources	
curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.bz2	
tar xjvf nasm-2.14.02.tar.bz2	
cd nasm-2.14.02	
./autogen.sh	
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"	
make	
sudo make install

# Compile YASM
echo "COMPILING YASM"
cd ~/ffmpeg_sources
curl -O -L https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
sudo make install

# Compile x264
echo "COMPILING H264"
cd ~/ffmpeg_sources
git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
sudo make install

# Compile x265
# echo "COMPILING H265"
# cd ~/ffmpeg_sources
# hg clone https://bitbucket.org/multicoreware/x265
# cd ~/ffmpeg_sources/x265/build/linux
# cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
# make
# sudo make install

# Compile fdk-aac
echo "COMPILING fdk-aac"
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
sudo make install

# Compile libmp3lame
echo "COMPILING libmp3lame"
cd ~/ffmpeg_sources
curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
sudo make install

# Compile libopus
echo "COMPILING libopus"
cd ~/ffmpeg_sources
curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
tar xzvf opus-1.3.1.tar.gz
cd opus-1.3.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
sudo make install

# Compile libvpx
echo "COMPILING libvpx"
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
make
sudo make install

# Compile SRT
echo "COMPILING SRT"
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/Haivision/srt.git
cd srt
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_BINDIR="$HOME/ffmpeg_build/bin" -DCMAKE_INSTALL_INCLUDEDIR="$HOME/ffmpeg_build/include" -DCMAKE_INSTALL_LIBDIR="$HOME/ffmpeg_build/lib" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off
make
sudo make install

# Compile ffmpeg
echo "COMPILING ffmpeg"
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
	--prefix="$HOME/ffmpeg_build" \
	--pkg-config-flags="--static" \
	--extra-cflags="-I$HOME/ffmpeg_build/include" \
	--extra-ldflags="-L$HOME/ffmpeg_build/lib" \
	--extra-libs=-lpthread \
	--extra-libs=-lm \
	--bindir="$HOME/bin" \
	--enable-gpl \
	--enable-libfdk-aac \
	--enable-libfreetype \
	--enable-libmp3lame \
	--enable-libopus \
	--enable-libvpx \
	--enable-libx264 \
#	--enable-libx265 \
	--enable-nonfree \
	--enable-openssl \
	--enable-libsrt
PATH="$HOME/bin:$PATH" make
sudo make install
hash -r
