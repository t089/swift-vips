FROM swift:5.6-focal 
RUN apt-get -qq update && apt-get -q -y install \
  tzdata \
    libssl-dev \
    zlib1g-dev \
 libexpat1-dev \
  git build-essential  libfftw3-dev \
  gobject-introspection  \
  libexif-dev \
  libglib2.0-dev  \
  automake libtool gtk-doc-tools \
  libpng-dev \
  libjpeg-turbo8-dev \
  libwebp-dev \
  libheif-dev \
  && rm -r /var/lib/apt/lists/*


#libvips
RUN git clone https://github.com/libvips/libvips.git && cd libvips && ./autogen.sh && make && make install && make clean

ENV LD_LIBRARY_PATH /usr/local/lib