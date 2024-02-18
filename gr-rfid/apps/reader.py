# Developed by: Nikos Kargas
# Modified by: Mattia Buscema

# used for the print function (with end= and sep)
from __future__ import print_function

# gnuradio libraries
from gnuradio import gr
from gnuradio import uhd
from gnuradio import blocks
from gnuradio import filter
from gnuradio import analog
from gnuradio import digital
from gnuradio import qtgui
from gnuradio.filter import firdes
from gnuradio.fft import window
import rfid

# used to read environmental variables
from os import environ

# used to make a time-based loop for the reading
import time


class reader_top_block(gr.top_block):

    # Configure usrp source
    def u_source(self):
        self.source = uhd.usrp_source(
            device_addr=self.usrp_address_source,
            stream_args=uhd.stream_args(
                cpu_format="fc32",
                channels=range(1),
            ),
        )
        self.source.set_samp_rate(self.adc_rate)
        self.source.set_center_freq(self.freq, 0)
        self.source.set_gain(self.rx_gain, 0)
        self.source.set_antenna("RX2", 0)

        if environ.get("USRP_SBX_DAUGHTERBOARD", False) == "True":
            print("* SBX daughterboard")
            self.source.set_auto_dc_offset(False)  # Uncomment this line for SBX daughterboard

    # Configure usrp sink
    def u_sink(self):
        self.sink = uhd.usrp_sink(
            device_addr=self.usrp_address_sink,
            stream_args=uhd.stream_args(
                cpu_format="fc32",
                channels=range(1),
            ),
        )
        self.sink.set_samp_rate(self.dac_rate)
        self.sink.set_center_freq(self.freq, 0)
        self.sink.set_gain(self.tx_gain, 0)
        self.sink.set_antenna("TX/RX", 0)

    def __init__(self):
        gr.top_block.__init__(self)

        # rt = gr.enable_realtime_scheduling()

        # Reads environments variables
        self.env_usrp_address = environ.get("USRP_ADDRESS", "192.168.10.3")
        self.env_usrp_rx_gain = int(environ.get("USRP_RX_GAIN", 20))
        self.env_usrp_tx_gain = int(environ.get("USRP_TX_GAIN", 20))
        self.env_usrp_frame_size = int(environ.get("USRP_FRAME_SIZE", 256))

        self.env_signal_freq = float(environ.get("SIGNAL_FREQUENCY", 867e6))
        self.env_signal_ampl = float(environ.get("SIGNAL_AMPLITUDE", 0.1))
        self.env_slots = int(environ.get("SLOTS", 1))

        self.env_debug = bool(environ.get("DEBUG", False) == "True")
        self.env_sink_logging = bool(environ.get("SINK_LOGGING", False) == "True")
        self.env_sink_source = bool(environ.get("SINK_SOURCE", True) == "True")  # the only one True by default
        self.env_sink_gate = bool(environ.get("SINK_GATE", False) == "True")
        self.env_sink_reader = bool(environ.get("SINK_READER", False) == "True")
        self.env_sink_matched_filter = bool(environ.get("SINK_MATCHED_FILTER", False) == "True")

        ######## Variables #########
        self.dac_rate = 1e6  # DAC rate
        self.adc_rate = 100e6 / 50  # ADC rate (2MS/s complex samples)
        self.decim = 5  # Decimation (downsampling factor)
        self.samp_rate = int(self.adc_rate / self.decim)
        self.ampl = self.env_signal_ampl  # Output signal amplitude (signal power vary for different RFX900 cards)
        self.freq = self.env_signal_freq  # 867 MHz
        self.rx_gain = self.env_usrp_rx_gain  # RX Gain (gain at receiver)
        self.tx_gain = self.env_usrp_tx_gain  # RFX900 no Tx gain option

        self.usrp_address_source = "addr=%s,recv_frame_size=%i" % (
            self.env_usrp_address, self.env_usrp_frame_size)  # 1472 is standard for 1GigE
        self.usrp_address_sink = "addr=%s,recv_frame_size=%i" % (
            self.env_usrp_address, self.env_usrp_frame_size)  # 1472

        # Each FM0 symbol consists of ADC_RATE/BLF samples (2e6/40e3 = 50 samples)
        # 10 samples per symbol after matched filtering and decimation
        self.num_taps = [1] * 25  # matched to half symbol period

        ######## File sinks for debugging (1 for each block) #########
        self.file_sink_source = blocks.file_sink(gr.sizeof_gr_complex * 1, "../misc/data/source", False)
        self.file_sink_source_filtered = blocks.file_sink(gr.sizeof_gr_complex * 1, "../misc/data/source_filtered")
        self.file_sink_matched_filter = blocks.file_sink(gr.sizeof_gr_complex * 1, "../misc/data/matched_filter", False)
        self.file_sink_gate = blocks.file_sink(gr.sizeof_gr_complex * 1, "../misc/data/gate", False)
        self.file_sink_decoder = blocks.file_sink(gr.sizeof_gr_complex * 1, "../misc/data/decoder", False)
        self.file_sink_reader = blocks.file_sink(gr.sizeof_float * 1, "../misc/data/reader", False)

        ######## Blocks #########
        self.matched_filter = filter.fir_filter_ccc(self.decim, self.num_taps)
        self.gate = rfid.gate(self.samp_rate)
        self.tag_decoder = rfid.tag_decoder(self.samp_rate)
        self.reader = rfid.reader(self.samp_rate, int(self.dac_rate))
        self.amp = blocks.multiply_const_ff(self.ampl)
        self.to_complex = blocks.float_to_complex()

        # High-pass filter to remove DC subharmonics
        self.high_pass_filter_0 = filter.fir_filter_ccf(
            1,
            firdes.high_pass(
                1,
                self.adc_rate, # full rate because we apply this before decimations
                600,
                200,
                window.WIN_HAMMING,
                6.76))

        self.band_reject_filter_0 = filter.fir_filter_ccf(
            1,
            firdes.band_reject(
                1,
                self.adc_rate,  # full rate because we apply this before decimations
                50,
                450,
                100,
                window.WIN_HAMMING,
                6.76))

        #self.dc_blocker_xx_0 = filter.dc_blocker_cc(32, True)

        if self.env_debug == False:  # Real Time Execution

            # USRP blocks
            self.u_source()
            self.u_sink()

            ######## Connections #########
            #self.connect(self.source, self.matched_filter)
            # With the filter here, it does not work (no queries are sent)
            #self.connect(self.source, self.high_pass_filter_0)
            #self.connect(self.source, self.dc_blocker_xx_0)
            #self.connect(self.dc_blocker_xx_0, self.high_pass_filter_0)
            #self.connect(self.high_pass_filter_0, self.matched_filter)
            #self.connect(self.dc_blocker_xx_0, self.matched_filter)
            self.connect(self.source, self.band_reject_filter_0)
            self.connect(self.band_reject_filter_0, self.matched_filter)

            self.connect(self.matched_filter, self.gate)

            #self.connect(self.matched_filter, self.high_pass_filter_0)
            #self.connect(self.high_pass_filter_0, self.gate)

            self.connect(self.gate, self.tag_decoder)

            #self.connect(self.gate, self.high_pass_filter_0)
            #self.connect(self.high_pass_filter_0, self.tag_decoder)

            self.connect((self.tag_decoder, 0), self.reader)
            self.connect(self.reader, self.amp)

            #self.connect(self.reader, self.high_pass_filter_1)
            #self.connect(self.high_pass_filter_1, self.amp)
            self.connect(self.amp, self.to_complex)
            #self.connect(self.amp, self.high_pass_filter_1)
            #self.connect(self.high_pass_filter_1, self.to_complex)

            self.connect(self.to_complex, self.sink)

            # File sinks for logging
            if self.env_sink_logging == True:
                if self.env_sink_source:
                    self.connect(self.source, self.file_sink_source)
                    #self.connect(self.high_pass_filter_0, self.file_sink_source_filtered)
                    self.connect(self.band_reject_filter_0, self.file_sink_source_filtered)
                    #self.connect(self.dc_blocker_xx_0, self.file_sink_source_filtered)
                if self.env_sink_gate:
                    self.connect(self.gate, self.file_sink_gate)
                if self.env_sink_reader:
                    self.connect(self.reader, self.file_sink_reader)
                if self.env_sink_matched_filter:
                    self.connect(self.matched_filter, self.file_sink_matched_filter)

        else:  # Offline Data
            print("* DEBUG")

            self.file_source = blocks.file_source(gr.sizeof_gr_complex * 1, "../misc/debug_data/file_source_test",
                                                  False)  # instead of uhd.usrp_source
            self.file_sink = blocks.file_sink(gr.sizeof_gr_complex * 1, "../misc/debug_data/file_sink",
                                              False)  # instead of uhd.usrp_sink

            ######## Connections #########
            self.connect(self.file_source, self.matched_filter)
            self.connect(self.matched_filter, self.gate)
            self.connect(self.gate, self.tag_decoder)
            self.connect((self.tag_decoder, 0), self.reader)
            self.connect(self.reader, self.amp)
            self.connect(self.amp, self.to_complex)
            self.connect(self.to_complex, self.file_sink)

        # This must always be present
        self.connect((self.tag_decoder, 1), self.file_sink_decoder)  # (Do not comment this line)



if __name__ == '__main__':

    main_block = reader_top_block()
    main_block.start()

    timeout = int(environ.get("READING_TIMEOUT", 10))

    while timeout > 0:
        time.sleep(1)
        timeout -= 1
        print(timeout, end='', sep=' ')

    main_block.reader.print_results()
    main_block.stop()
