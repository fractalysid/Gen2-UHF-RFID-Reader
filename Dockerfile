FROM ubuntu:16.04
LABEL authors="mattia_buscema"

# Update system
RUN apt-get update
RUN apt-get upgrade -y

# Install software needed at build and runtime
RUN apt-get install -y build-essential git cmake uhd-host libuhd-dev libuhd003 \
    libboost-all-dev gnuradio gnuradio-dev libcppunit-dev doxygen swig software-properties-common liblog4cpp5-dev

# Set up environment variables used during compilation
ARG SLOTS=1
ARG QUERIES=1000

# Set up environment variables used at runtime by apps/reader.py
ENV USRP_ADDRESS="192.168.10.3" \
    USRP_RX_GAIN=20 \
    USRP_TX_GAIN=20 \
    USRP_FRAME_SIZE=256 \
    USRP_SBX_DAUGHTERBOARD=False \

    SIGNAL_FREQUENCY=867e6 \
    SIGNAL_AMPLITUDE=1 \

    DEBUG=False \
    SINK_LOGGING=False

# Copy repository code inside the image
COPY gr-rfid /code/

# Modify source code to account for environment variables
RUN sed -i "s/const int FIXED_Q =.*/const int FIXED_Q = ${SLOTS};/" /code/include/rfid/global_vars.h
RUN sed -i "s/const int MAX_NUM_QUERIES = .*/const int MAX_NUM_QUERIES = ${QUERIES};/" /code/include/rfid/global_vars.h

# Builds the OOT module
RUN cd /code/ &&\
    mkdir -pv build &&\
    cd build &&\
    cmake ../ &&\
    make -j$(nproc) install &&\
    ldconfig

# Setting working director
WORKDIR /code/apps/

# TODO: add code to increase niceness to -20
#ENTRYPOINT ["python", "./reader.py"]
CMD ["python", "./reader.py"]
