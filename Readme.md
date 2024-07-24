# UtilityIP

The utilityIP repository is intended to store small useful IP which don't fit into other repositories, or are too "small" to be in their own repository.

## AXI_Full_IPIF

This IP provides an AXI4 full interface to wishbone-like interface while preserving high throughput.  The core logic is borrowed from the open core provided [here](https://github.com/ZipCPU/wb2axip/blob/master/rtl/demofull.v).

## AXI_to_IPIF_mux

This IP provides an interface between an AXI-lite slave and one or more wishbone-like interfaces to other IP.  The IP can be configured to interface to a single IP, a single IP with many sub elements, or multiple IP.

## bram_to_stream

Simple IP to read from a BRAM and produce a AXI streaming interface from its contents.

## data_mux

Multiplexer IP which allows to multiplex between AXI streaming interfaces, or send a defined idle pattern when appropriate. 

## LFSR_to_stream

This IP produces a PRBS and encodes it into a AXI streaming interface. 

## OSERDES_ip

A basic wrapper around an OSERDES which allows it to be instantiated in a block design.

## stream_bit_reverse

Simple IP which reverses the bit order (big endian vs little endian) of an AXI streaming interface.  

## stream_cat

IP to concatenate AXI streaming interfaces.  

## stream_compare

This IP compares the values from two AXI streaming interfaces and counts any differences as errors.

## stream_split

IP which splits one AXI streaming interface into many.

# interface definitions

## IP_interface

IP interface designed to use with the AXI_Full_IPIF IP.

## IPIF_AXISL

IP interface designed to be used with the AXI_to_IPIF_mux IP.
