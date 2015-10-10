FROM debian:8

# Adapted from http://www.omnicron.com/~ford/teensy/setup-teensy

RUN apt-get update
RUN apt-get install -y libusb-dev git make gcc-arm-none-eabi gcc unzip

ENV COMMIT 605d9dc91102c4fa99c1bd37ff51571e7e672773

# Clone and compile teensy_loader_cli
RUN git clone https://github.com/PaulStoffregen/teensy_loader_cli.git /loader && \
    (cd /loader && git reset $COMMIT --hard  && make) && \
    install -Dm755 /loader/teensy_loader_cli /usr/bin && \
    rm -rf /loader

# Configure device permissions
ADD http://www.pjrc.com/teensy/49-teensy.rules /etc/udev/rules.d/49-teensy.rules

# Download Teensy headers
ADD http://www.seanet.com/~karllunt/Teensy3xlib.zip /downloads/teensy.zip
RUN unzip -aa -d /teensy /downloads/teensy.zip

# Apply patch
RUN sed -i s/mk20d7/MK20D7/ /teensy/include/common.h

COPY ./src /src
COPY Makefile /src/Makefile
WORKDIR /src

RUN make build
ENTRYPOINT ["make"]


