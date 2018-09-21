
##
# Build some tools manually
##
FROM ubuntu:latest

WORKDIR /tmp
RUN apt-get update \
    && apt-get install -y \
        make \
        gcc \
        g++ \
        cmake \
        wget \
        git \
    && apt-get clean

RUN git clone https://github.com/castano/nvidia-texture-tools.git
RUN mkdir -p nvidia-texture-tools/build \
    && cd nvidia-texture-tools/build \
    && cmake ../ \
    && make install

RUN git clone https://github.com/stelcheck/crunch.git
RUN cd crunch/crnlib \
    && make release \
    && cd ../crunch \
    && make release

RUN wget  https://github.com/GPUOpen-Tools/Compressonator/releases/download/v3.0.3707/Compressonator_Linux_x86_64_3.0.105.tar.gz \
    && tar -zxvf Compressonator_Linux_x86_64_3.0.105.tar.gz \
    && mv Compressonator_Linux_x86_64_3.0.105 Compressonator

##
# Main image
##
FROM alpine:latest  

# crunch
COPY --from=0 /tmp/crunch/bin/crunch /usr/bin

# Compressonator
COPY --from=0 /tmp/Compressonator/ /opt
RUN ln -s /tmp/Compressonator/CompressonatorCLI /usr/bin/

# nvidia-texture-tools
RUN mkdir -p \
    /usr/share/doc/nvtt/ \
    /usr/lib/static/ \
    /usr/include/nvtt/

COPY --from=0 /usr/local/lib/static/libnvcore.a /usr/lib/static/
COPY --from=0 /usr/local/lib/static/libnvmath.a /usr/lib/static/
COPY --from=0 /usr/local/lib/static/libnvimage.a /usr/lib/static/
COPY --from=0 /usr/local/lib/static/libnvthread.a /usr/lib/static/
COPY --from=0 /usr/local/lib/static/libnvtt.a /usr/lib/static/
COPY --from=0 /usr/local/include/nvtt/nvtt.h /usr/include/nvtt/
COPY --from=0 /usr/local/include/nvtt/nvtt_wrapper.h /usr/include/nvtt/
COPY --from=0 /usr/local/bin/nvcompress /usr/bin
COPY --from=0 /usr/local/bin/nvdecompress /usr/bin
COPY --from=0 /usr/local/bin/nvddsinfo /usr/bin
COPY --from=0 /usr/local/bin/nvimgdiff /usr/bin
COPY --from=0 /usr/local/bin/nvassemble /usr/bin
COPY --from=0 /usr/local/bin/nvzoom /usr/bin
COPY --from=0 /usr/local/bin/nv-gnome-thumbnailer /usr/bin
COPY --from=0 /usr/local/bin/nvtestsuite /usr/bin
COPY --from=0 /usr/local/bin/nvhdrtest /usr/bin

RUN echo "@edgecommunity http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk update \
    && apk add \
        imagemagick \
        pngquant@edgecommunity \
        lame

RUN mkdir /assets
WORKDIR /assets
CMD "sh"