
FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive
LABEL maintainer "Renwu Gao <gilyou.public@gmail.com>"

# install necessary package
RUN apt-get update && apt-get install -y freeglut3 libglu1-mesa libglu1 libxmu6 \
    vim build-essential g++ libgtk-3-dev libcanberra-gtk3-module  libjpeg8-dev graphviz libopenblas-dev liblapacke-dev \
    python3 python3-dev python3-pip python3-tk python3-lxml python3-six python3-setuptools \
    pkg-config libswscale-dev libtbb2 libgcrypt20 libnotify4 libxtst6 libnss3 python gvfs-bin xdg-utils libcap2 \
    libtbb-dev libjpeg-dev libpng-dev libtiff-dev libavformat-dev libpq-dev libjasper-dev \
    automake autoconf libtool cmake git gconf2 gconf-service libgtk2.0-dev libudev1 libpcl-dev libdcmtk-dev \
    protobuf-compiler vim emacs rsync software-properties-common unzip libfreetype6-dev libzmq3-dev \
    --no-install-recommends \
    && apt-get clean \
    
WORKDIR /
RUN git clone https://github.com/opencv/opencv.git \
 && git clone https://github.com/opencv/opencv_contrib.git
RUN mkdir /opencv/cmake_binary
WORKDIR /opencv/cmake_binary
RUN cmake -DBUILD_TIFF=ON \
  -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=ON \
  -DENABLE_AVX=ON \
  -DWITH_LAPACK=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DWITH_GTK3=ON \
  -DPYTHON_INCLUDE_DIRS=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/`ls -l /usr/lib/x86_64-linux-gnu | awk '{print $9}' | grep libpython2.*` \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DPYTHON_DEFAULT_EXECUTABLE=$(which python3) \
  -DPYTHON3_EXECUTABLE=$(which python3) \
  -DPYTHON3_INCLUDE_DIRS=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  -DPYTHON3_LIBRARY=/usr/lib/x86_64-linux-gnu/`ls -l /usr/lib/x86_64-linux-gnu | awk '{print $9}' | grep libpython3.[0-9][m].so$` \
  -DPYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "from numpy.distutils import misc_util;print(misc_util.get_numpy_include_dirs()[0])") ..
RUN make -j8 && make install
RUN rm -rf /opencv
RUN rm -rf /opencv_contrib
