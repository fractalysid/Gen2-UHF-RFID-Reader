FROM ubuntu:16.04
LABEL authors="mattia_buscema"
# TODO: optimize image building speed and size by using a multi-stage build

# Update system
RUN apt-get update
RUN apt-get upgrade -y

# Install software needed at build and runtime
RUN apt-get install -y build-essential git cmake uhd-host libuhd-dev libuhd003 \
    libboost-all-dev gnuradio gnuradio-dev libcppunit-dev doxygen swig software-properties-common liblog4cpp5-dev

# Set up environment variables used during compilation
ARG SLOTS=1
ARG QUERIES=1000
ARG LOGGING=False

# Set up environment variables used at runtime by apps/reader.py
ENV USRP_ADDRESS="192.168.10.3" \
    USRP_RX_GAIN=20 \
    USRP_TX_GAIN=20 \
    USRP_FRAME_SIZE=256 \
    USRP_SBX_DAUGHTERBOARD=False \

    SIGNAL_FREQUENCY=867e6 \
    SIGNAL_AMPLITUDE=1 \

    DEBUG=False \

    SINK_LOGGING=False \
    SINK_SOURCE=True \
    SINK_GATE=False \
    SINK_READER=False \
    SINK_MATCHED_FILTER=False

# Copy repository code inside the image
# TODO: find a way to use file matching to avoid using the complete list of files and directories
# These directories and files should not change, or do it very infrequently
COPY gr-rfid/CMakeLists.txt code/CMakeLists.txt
COPY gr-rfid/apps/CMakeLists.txt code/apps/
COPY gr-rfid/cmake/ code/cmake/
COPY gr-rfid/docs/ code/docs/
COPY gr-rfid/examples/ code/examples/
COPY gr-rfid/grc/ code/grc/
COPY gr-rfid/misc/ code/misc/
COPY gr-rfid/python/ code/python/
COPY gr-rfid/swig/ code/swig/

# These may change
COPY gr-rfid/lib/ code/lib/
COPY gr-rfid/include/ code/include/

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

# Now we can copy the python script, which is updated more frequently
COPY gr-rfid/apps/reader.py code/apps/

# Create config file for gnuradio to enable logging
RUN if [ "$LOGGING" = "True" ]; then mkdir -p /root/.gnuradio && echo "[LOG]\nlog_level = debug\ndebug_level = debug\nlog_file = stdout\ndebug_file = /code/misc/data/debug.log\n" >> /root/.gnuradio/config.conf; fi

# Setting working directory
WORKDIR /code/apps/

# TODO: add code to increase niceness to -20
#ENTRYPOINT ["python", "./reader.py"]
CMD ["python", "./reader.py"]
