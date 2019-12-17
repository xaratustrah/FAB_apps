# Barrier Bucket Signal Generator (BBSG)
#### 09.04.2009 S. Sanjari

## Introduction

This document describes some initial efforts of the realisation of a barrier bucket signal generator.
A single sine wave pulse is generated using the help program sinus_gen.sce which is written in the MATLAB-like programming language "SCILAB". Scilab is open source and could be downloaded freely from the web site:
http://www.scilab.org/

Scilab could be a small replacement for MATLAB, but it doesn't replace the full functionality. The script "sinus_gen.sce" is stored in SUBVERSION system under the project folder of the fib_bbsg.


This script generates a file "sine_lut_bbsg.vhd" which shouldn't be edited manually. This file is then included in the VHDL folder for further processing of the main TOP_LEVEL Entity.
In the SCILAB- Script, you can change the parameters, the number of points and width of the sample, i.e. the single pulse.
Currently FAB_BBSG runs stand alone on an FAB_ADCDAC Board, and is compatible with Hardware revisions C and later.
There are 2 independent processes constituting two independent pulse generators. Each pulse generator could be triggered independently by an internal trigger generator.

## Future Implementations

The internal pulse generators will be replaced by the external sources. The board will be connected to the FIB board via "uC-LINK" and "Piggy" connectors. FIB will then be a slave expansion for the main BBSG Entity on the FAB_ADCDAC Board. Through the address multiplex mechanism which is also available in similar projects (see e.g. amplitudendetektor) the BBSG entity can communicate with the backplane signals, where it gets the information about the pulse shape, amplitude and delay time.

## Pulse shape

Pulse shape will be loaded either through the control system or statically through USB/RS232, and could be stored in the on-board memory (Flash or SRAM on top of the FAB_ADCDAC Board, or Flash on top of the FIB board.)

## Pulse Offset

The pulse offset could also be realised considering the fact that the outputs of the DAC channels are set to be compatible with a maximum of 13.3V. The required sample points could then be adjusted to the maximum and minimum of this voltage window.

## Hardware filters

In order to be able to realise the sharp peaks of the output signal, 95 MHz filters should be mounted on the board.

## Triggering

Triggering could be realised using on (or both) of the ADC channels with a simple level detection on the digital side, in the VHDL code. Other trigger inputs are possible through the trigger inputs of the FIB board.

## Mechanical aspect

BBSG will be mounted on top of the FIB, they are inserted into the FAIR-19" Rack (or compatible Netzgeräte Backplane. No RF cassette is needed since the boards are mounted directly on the rails.

## Optical Ring

A connection to the optical ring is possible through the FIB expansion card, in slave mode.