# Copyright 2020 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

########################################################################
# Check if there is C++ code at all
########################################################################
if(NOT rfid_sources)
    MESSAGE(STATUS "No C++ sources... skipping python bindings")
    return()
endif(NOT rfid_sources)

########################################################################
# Check for pygccxml
########################################################################
GR_PYTHON_CHECK_MODULE_RAW(
    "pygccxml"
    "import pygccxml"
    PYGCCXML_FOUND
    )

include(GrPybind)

########################################################################
# Python Bindings
########################################################################

list(APPEND rfid_python_files
    python_bindings.cc
    gate_python.cc
    reader_python.cc
    tag_decoder_python.cc
    )

GR_PYBIND_MAKE_OOT(rfid
   ../../..
   gr::rfid
   "${rfid_python_files}")

# copy bindings extension for use in QA test module
add_custom_command(TARGET rfid_python POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:rfid_python>
    ${PROJECT_BINARY_DIR}/test_modules/gnuradio/rfid/
)

install(TARGETS rfid_python DESTINATION ${GR_PYTHON_DIR}/gnuradio/rfid COMPONENT pythonapi)
