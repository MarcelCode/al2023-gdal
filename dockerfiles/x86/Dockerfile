FROM public.ecr.aws/sam/build-provided.al2023:latest as builder

LABEL author="Marcel Siegmann <siegmann@eomap.de>"

RUN dnf update -y && \
    dnf install -y git autoconf libtool flex bison cmake make \
      tar gzip gcc gcc-c++ automake-1.16.5-9.amzn2023.0.3.noarch libpng-devel nasm \
      libxml2-devel readline-devel openssl-devel curl-devel findutils binutils zip \
      cmake3 && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/lib/dnf/history

ENV PREFIX=/opt

WORKDIR /opt

ENV LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

# pkg-config
ENV PKGCONFIG_VERSION=0.29.2
RUN mkdir /tmp/pkg-config \
  && curl -sfL https://pkg-config.freedesktop.org/releases/pkg-config-${PKGCONFIG_VERSION}.tar.gz | tar zxf - -C /tmp/pkg-config --strip-components=1 \
  && cd /tmp/pkg-config \
  && CFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --with-internal-glib \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/pkg-config

ENV PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/

# sqlite
ENV SQLITE_VERSION_YEAR=2024
ENV SQLITE_VERSION=3450100
RUN mkdir /tmp/sqlite \
  && curl -sfL https://www.sqlite.org/${SQLITE_VERSION_YEAR}/sqlite-autoconf-${SQLITE_VERSION}.tar.gz | tar zxf - -C /tmp/sqlite --strip-components=1 \
  && cd /tmp/sqlite \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --disable-static \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/sqlite

# libdeflate
ENV LIBDEFLATE_VERSION=1.14
RUN mkdir /tmp/libdeflate \
  && curl -sfL https://github.com/ebiggers/libdeflate/archive/v${LIBDEFLATE_VERSION}.tar.gz | tar zxf - -C /tmp/libdeflate --strip-components=1 \
  && cd /tmp/libdeflate \
  && make -j $(nproc) --silent PREFIX=$PREFIX && make install \
  && rm -rf /tmp/libdeflate

# libtiff
ENV LIBTIFF_VERSION=4.6.0
RUN mkdir /tmp/libtiff \
  && curl -sfL https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz | tar zxf - -C /tmp/libtiff --strip-components=1 \
  && cd /tmp/libtiff \
  && LDFLAGS="-Wl,-rpath,'\$\$ORIGIN'" CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
    --prefix=$PREFIX \
    --disable-static \
    --enable-rpath \
    --with-libdeflate-lib-dir=$PREFIX/lib \
    --with-libdeflate-include-dir=$PREFIX/include \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/libtiff

# Proj
ENV PROJ_VERSION=9.3.1
RUN mkdir /tmp/proj && mkdir /tmp/proj/data \
  && curl -sfL https://github.com/OSGeo/proj/archive/${PROJ_VERSION}.tar.gz | tar zxf - -C /tmp/proj --strip-components=1 \
  && cd /tmp/proj \
  && mkdir build && cd build \
  && cmake3 .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_INSTALL_INCLUDEDIR:PATH=include \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/proj

# GeoTIFF
ENV LIBGEOTIFF_VERSION=1.7.1
RUN mkdir /tmp/libgeotiff \
  && curl -sfL https://github.com/OSGeo/libgeotiff/releases/download/${LIBGEOTIFF_VERSION}/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz | tar zxf - -C /tmp/libgeotiff --strip-components=1 \
  && cd /tmp/libgeotiff \
  && LDFLAGS="-Wl,-rpath,'\$\$ORIGIN'" CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
    --prefix=$PREFIX \
    --with-proj=$PREFIX \
    --with-zip=yes \
    --with-zlib \
    --with-libtiff=$PREFIX \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/libgeotiff

# geos
ENV GEOS_VERSION=3.12.1
RUN mkdir /tmp/geos \
  && curl -sfL https://github.com/libgeos/geos/archive/refs/tags/${GEOS_VERSION}.tar.gz | tar zxf - -C /tmp/geos --strip-components=1 \
  && cd /tmp/geos \
  && mkdir build && cd build \
  && cmake3 .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
    -DBUILD_DOCUMENTATION=OFF \
    -DBUILD_TESTING=OFF \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/geos

# GDAL \
ARG GDAL_VERSION
RUN mkdir /tmp/gdal \
  && curl -sfL https://github.com/OSGeo/gdal/archive/refs/tags/v${GDAL_VERSION}.tar.gz | tar zxf - -C /tmp/gdal --strip-components=1 \
  && cd /tmp/gdal \
  && mkdir build && cd build \
  && cmake3 .. \
    -DGDAL_BUILD_OPTIONAL_DRIVERS=OFF \
    -DOGR_BUILD_OPTIONAL_DRIVERS=OFF \
    -DGDAL_USE_INTERNAL_LIBS=WHEN_NO_EXTERNAL \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
    -DGDAL_SET_INSTALL_RELATIVE_RPATH=ON \
    -DBUILD_PYTHON_BINDINGS=OFF \
    -DGDAL_USE_TIFF_INTERNAL=OFF \
    -DGDAL_USE_GEOTIFF_INTERNAL=OFF \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/gdal

FROM public.ecr.aws/sam/build-provided.al2023:latest as runner

ENV PREFIX=/opt

COPY --from=builder /opt/lib/ $PREFIX/lib/
COPY --from=builder /opt/include/ $PREFIX/include/
COPY --from=builder /opt/share/ $PREFIX/share/
COPY --from=builder /opt/bin/ $PREFIX/bin/

RUN export GDAL_VERSION=$(gdal-config --version)

ENV \
  GDAL_DATA=$PREFIX/share/gdal \
  PROJ_LIB=$PREFIX/share/proj \
  PROJ_DATA=$PREFIX/share/proj \
  GDAL_CONFIG=$PREFIX/bin/gdal-config \
  PATH=$PREFIX/bin:$PATH \
  LD_PRELOAD=$PREFIX/lib/libsqlite3.so