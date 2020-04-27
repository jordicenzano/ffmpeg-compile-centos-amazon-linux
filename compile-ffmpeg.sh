# Compile ffmpeg in centOS based Linux
# by Jordi Cenzano

# Stop at any error
set -e

# Update
yum update update -y

# Upgrade
yum upgrade -y

# Install curl
yum install curl -y

#I nstall unzip
yum install unzip -y

# Install wget
yum install wget -y

# Install wget
yum install git -y

# Prepare docker for ffmpeg
yum -y install autoconf automake build-essential libass-dev libfreetype6-dev \
  libsdl2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev cmake libssl-dev

# Compile ffmpeg from sources ----------------

# Create dir
mkdir -p ~/ffmpeg_sources

# Compile NASM
cd ~/ffmpeg_sources && \
  wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 && \
  tar xjvf nasm-2.13.03.tar.bz2 && \
  cd nasm-2.13.03 && \
  ./autogen.sh && \
  PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
  make && \
  make install

# Compile YASM
cd ~/ffmpeg_sources && \
  wget -O yasm-1.3.0.tar.gz https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && \
  tar xzvf yasm-1.3.0.tar.gz && \
  cd yasm-1.3.0 && \
  ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
  make && \
  make install

# Compile x264
cd ~/ffmpeg_sources && \
  git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
  cd x264 && \
  PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic && \
  PATH="$HOME/bin:$PATH" make && \
  make install

# Compile fdk-aac
cd ~/ffmpeg_sources && \
  wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master && \
  tar xzvf fdk-aac.tar.gz && \
  cd mstorsjo-fdk-aac* && \
  autoreconf -fiv && \
  ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
  make && \
  make install

# Compile libmp3lame
cd ~/ffmpeg_sources && \
  wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
  tar xzvf lame-3.99.5.tar.gz && \
  cd lame-3.99.5 && \
  ./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared && \
  make && \
  make install

# Compile libopus
cd ~/ffmpeg_sources && \
  wget https://archive.mozilla.org/pub/opus/opus-1.1.5.tar.gz && \
  tar xzvf opus-1.1.5.tar.gz && \
  cd opus-1.1.5 && \
  ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
  make && \
  make install

# Compile libvpx
yum install git -y && \
  cd ~/ffmpeg_sources && \
  git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
  cd libvpx && \
  PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth && \
  PATH="$HOME/bin:$PATH" make && \
  make install

# Compile SRT
cd ~/ffmpeg_sources && \
  git clone --depth 1 https://github.com/Haivision/srt.git && \
  cd srt && \
  cmake -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON && \
  make && \
  make install

# Compile ffmpeg
cd ~/ffmpeg_sources && \
  wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
  tar xjvf ffmpeg-snapshot.tar.bz2 && \
  cd ffmpeg && \
  PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-nonfree \
    --enable-openssl \
    --enable-libsrt && \
  PATH="$HOME/bin:$PATH" make && \
  make install && \
  hash -r

# Install network resources
yum -y install iproute iputils-ping net-tools

# Clean up
yum clean
