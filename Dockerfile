FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# #GENERAL PACKAGES
RUN echo "export DISPLAY=:0"  >> /etc/profile
RUN apt-get -y update
RUN apt-get install python3 python3-pip -y
RUN pip3 install --upgrade pip


# #DEPENDENCIES FOR EASY MOCAP
RUN apt-get install python3-opencv -y
RUN apt-get install freeglut3-dev -y
RUN pip3 install opencv-python

# #DEPENDENCIES FOR OPENPOSE
RUN apt-get install -y --no-install-recommends \
python3-dev python3-pip git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
libgoogle-glog-dev libboost-all-dev libcaffe-cuda-dev libhdf5-dev libatlas-base-dev

# GET OPENPOSE
WORKDIR /usr/src/openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

# DOWNLOAD MODELS
WORKDIR /usr/src/openpose/models
RUN apt-get install unzip
RUN wget https://www.lazulistudio.com.br/downloads/openpose.zip
RUN unzip -n openpose.zip
RUN rm openpose.zip

# BUILD OPENPOSE
WORKDIR /usr/src/openpose/build
# replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"
RUN cmake -DBUILD_PYTHON=ON -DGPU_MODE=CPU_ONLY .. && make -j `nproc`

# BUILD EASY MOCAP
WORKDIR /usr/src/easymocap
RUN git clone https://github.com/zju3dv/EasyMocap.git .
RUN pip3 install -r requirements.txt
RUN python3 setup.py develop --user