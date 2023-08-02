# Gen2 UHF RFID Reader
This is a Gen2 UHF RFID Reader. It is able to identify commercial Gen2 RFID Tags with FM0 line coding and 40kHz data rate (BLF), and extract their EPC. It requires USRPN200 and a RFX900 or SBX daughterboard.  

The project is based on the RFID Gen2 Reader available at https://github.com/ransford/gen2_rfid. The reader borrows elements from the software developed by Buettner, i.e. Data flow: Gate -> Decoder -> Reader as well as the conception regarding the detection of the reader commands. CRC calculation and checking functions were also adapted from https://www.cgran.org/browser/projects/gen2_rfid/.

### Implemented GNU Radio Blocks:

- Gate : Responsible for reader command detection.  
- Tag decoder : Responsible for frame synchronization, channel estimation, symbol period estimation and detection.  
- Reader : Create/send reader commands.

## Build and run
No installation is required on the host system as everything happens inside a container.
- install_dependencies.sh: installs podman/docker and tweak kernel parameters for running the program (with persistent configuration) (requires root privileges)
- build_image.sh: builds the container where the application is built
- run.sh: runs the application inside the container

```shell
git clone https://github.com/fractalysid/Gen2-UHF-RFID-Reader.git
cd Gen2-UHF-RFID-Reader/
./build_image.sh
./run.sh
```

## Configuration
All configuration is done by modifying variables in configuration.env and build.env.
Modifying variables in build.env requires image to be rebuilt (launching ```./build_image.sh```).

build.env
- SLOTS: Number of different tags to be decoded (number of tags = 2^SLOTS) (default: 0)
- QUERIES: Max number of queries after which the program terminates (default: 1000)

configuration.env
- USRP_ADDRESS: IP address of USRP (default: 192.168.10.3)
- USRP_RX_GAIN: gain at receiver (default: 20)
- USRP_TX_GAIN: gain at transmitter (default: 20)
- USRP_FRAME_SIZE: receive buffer size (default: 256) 
- USRP_SBX_DAUGHTERBOARD: set to True if using an SBX daughterboard
- SIGNAL_FREQUENCY: frequency of the signal (default: 867e6 )
- SIGNAL_AMPLITUDE: output signal amplitude (default: 1, range from 0 to 1)
- DEBUG: run script on debug data, without using USRP (default: False)
- SINK_LOGGING: save captured data on misc/data/source (default: False). May slow down execution


## How to run

```shell
./run.sh
```

- Real time execution:

    Set ```DEBUG=False``` in configuration.env

    After termination, part of EPC message (EPC[104:111]) of identified Tags is printed.  

- Offline:

    Set ```DEBUG=True``` in configuration.env (A test file already exists named file_source_test).

    The reader works with offline traces without using a USRP.  
    The output after running the software with test file is:  
    
    | Number of queries/queryreps sent : 71  
    | Current Inventory round : 72  

    | Correctly decoded EPC : 70  
    | Number of unique tags : 1  
    | Tag ID : 27  Num of reads : 70  
 
## Logging (to be implemented)

- Configuration file : /home/username/.gnuradio/config.conf  
    Edit the above file and add the following lines  

    [LOG]  
    debug_file = /PathToLogFile/Filename  
    debug_level = info  
    
    Logging may cause latency issues if it is enabled during real time execution!

## Debugging  

The reader may fail to decode a tag response for the following reasons

1) Latency: For real time execution you should disable the output on the terminal. If you see debug messages, you should either install log4cpp or comment the corresponding lines in the source code e.g., GR_LOG_INFO(d_debug_logger, "EPC FAIL TO DECODE");

2) Antenna placement. Place the antennas side by side with a distance of 50-100cm between them and the tag 2m (it can detect a tag up to 6m) away facing the antennas.

3) Parameter tuning. The most important is self.ampl which controls the power of the transmitted signal (takes values between 0 and 1).

If the reader still fails to decode tag responses, uncomment the following line in reader.py file

 #self.connect(self.source, self.file_sink_source)

Run the software for a few seconds (~5s). A file will be created in misc/data directory named source. This file contains the received samples. You can plot the amplitude of the received samples using the script located in misc/code folder. The figure should be similar to the .eps figure included in the folder. Plotting the figure can give some indication regarding the problem. You can also plot the output of any block by uncommenting the corresponding line in the reader.py file. Output files will be created in misc/data folder:

- /misc/data/source  
- /misc/data/matched_filter  
- /misc/data/gate 
- /misc/data/decoder  
- /misc/data/reader

Useful discussions that cover common software issues and fixes:

https://github.com/nkargas/Gen2-UHF-RFID-Reader/issues/1

https://github.com/nkargas/Gen2-UHF-RFID-Reader/issues/4

https://github.com/nkargas/Gen2-UHF-RFID-Reader/issues/10
    
## Hardware:

  - 1x USRPN200/N210  
  - 1x RFX900/SBX daughterboard  
  - 2x circular polarized antennas  

<img src="./example_setup.png" width="300">

## Tested on:
  Ubuntu 14.04 64-bit  
  GNU Radio 3.7.4
  
## If you use this software please cite:
N. Kargas, F. Mavromatis and A. Bletsas, "Fully-Coherent Reader with Commodity SDR for Gen2 FM0 and Computational RFID", IEEE Wireless Communications Letters (WCL), Vol. 4, No. 6, pp. 617-620, Dec. 2015. 

## Contact:
  Nikos Kargas (email: karga005@umn.edu)  

This research has been co-financed by the European Union (European Social Fund-ESF) and Greek national funds through the Operational Program Education and Lifelong Learning of the National Strategic Reference Framework (NSRF) - Research Funding Program: THALES-Investing in knowledge society through the European Social Fund.
