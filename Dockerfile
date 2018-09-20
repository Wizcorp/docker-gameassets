
##
# Build some tools manually
##
FROM alpine:latest

WORKDIR /tmp
RUN apk update \
    && apk add \
        make \
        gcc \
        g++ \
        git

RUN git clone https://github.com/stelcheck/crunch.git \
    && cd crunch/crnlib \
    && make release \
    && cd ../crunch \
    && make release

##
# Main image
##
FROM alpine:latest  
COPY --from=0 /tmp/crunch/bin/crunch /usr/bin
RUN echo "@edgecommunity http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk update \
    && apk add \
        imagemagick \
        pngquant@edgecommunity \
        lame