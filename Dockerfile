# The most of the earlier part of this file is copyd from nytimes blender image
# No need to reinvent the wheel right ;)

FROM nvidia/cudagl:10.1-base-ubuntu18.04

# Enviorment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PATH "$PATH:/bin/2.82/python/bin/"
ENV BLENDER_PATH "/bin/2.82"
ENV BLENDERPIP "/bin/2.82/python/bin/pip3"
ENV BLENDERPY "/bin/2.82/python/bin/python3.7m"
ENV HW="GPU"

# Install dependencies
RUN apt-get update && apt-get install -y \
	wget \
	libopenexr-dev \
	bzip2 \
	build-essential \
	zlib1g-dev \
	libxmu-dev \
	libxi-dev \
	libxxf86vm-dev \
	libfontconfig1 \
	libxrender1 \
	libgl1-mesa-glx \
	xz-utils

# Download and install Blender
RUN wget https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82-linux64.tar.xz \
	&& tar -xvf blender-2.82-linux64.tar.xz --strip-components=1 -C /bin \
	&& rm -rf blender-2.82-linux64.tar.xz \
	&& rm -rf blender-2.82-linux64

# Download the Python source since it is not bundled with Blender
RUN wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tgz \
	&& tar -xzf Python-3.6.8.tgz \
	&& cp Python-3.6.8/Include/* $BLENDER_PATH/python/include/python3.7m/ \
	&& rm -rf Python-3.6.8.tgz \
	&& rm -rf Python-3.6.8

# Blender comes with a super outdated version of numpy (which is needed for matplotlib / opencv) so override it with a modern one
RUN rm -rf ${BLENDER_PATH}/python/lib/python3.7/site-packages/numpy

# Must first ensurepip to install Blender pip3 and then new numpy
RUN ${BLENDERPY} -m ensurepip && ${BLENDERPIP} install --upgrade pip && ${BLENDERPIP} install numpy

# Install all necessary python packages to be used in blender in the blender python environment directory
RUN ${BLENDERPIP} install coverage
RUN ${BLENDERPIP} install pyyaml
RUN ${BLENDERPIP} install flask

# Mount working directory to /workdir in the container
WORKDIR /workdir