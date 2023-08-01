FROM ubuntu:16.04
LABEL authors="mattia_buscema"

# Update system
RUN apt-get update
RUN apt-get upgrade -y

# Install software needed at build and runtime
RUN apt-get install -y build-essential git cmake uhd-host libuhd-dev libuhd003 libboost-all-dev \
    gnuradio gnuradio-dev libcppunit-dev doxygen swig software-properties-common liblog4cpp5-dev

# Copy repository code inside the image
COPY gr-rfid /code/

# Builds the OOT module
RUN cd /code/ &&\
    mkdir -pv build &&\
     cd build &&\
     cmake ../ &&\
     make -j$(nproc) install &&\
     ldconfig

# Setting working director
WORKDIR /code/apps/

# Set up environment variables to be used inside the reader.py
#ENV USRP_ADDRESS="192.168.10.3"
#ENV USRP_RX_GAIN=20
#ENV USRP_TX_GAIN=20
#ENV USRP_FRAME_SIZE=256

#ENV SIGNAL_FREQUENCY=867e6
#ENV SIGNAL_AMPLITUDE=1

#ENV DEBUG=False
#ENV SINK_LOGGING=True


#ENTRYPOINT ["python", "./reader.py"]
CMD ["python", "./reader.py"]
