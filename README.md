# 18758-project
A wireless digital communications system

This was my final project for CMU's 18-758, a wireless communications class.
The goal was to design and implement a digital communications protocol for use
in wireless systems. Using MATLAB, I developed a pair of scripts: one to encode
a digital signal, and one to decode a received signal.

The encoded signal was sent through a real radio, and the received result was
downloaded and decoded. Our system was required to support messages of at least
3000 bits, with an error rate of less than 0.2%. All constant values were
selected to minimize the error rate given the possible message length and
bitrate available.

## Encoder Design

The encoder is given a series of bits to transmit, padded to a predetermined
length. The bits are coded using a 4-state
[convolutional code](https://en.wikipedia.org/wiki/Convolutional_code)
for error correcting. Then, the coded bits are interleaved to add robustness
against localized error events, and modulated using 8 point
[phase-shift keying](https://en.wikipedia.org/wiki/Phase-shift_keying) to
generate a transmission signal.

After generating the transmission signal, a pilot sequence is prepended. The
sequence is a pre-computed bit signal, encoded naively as square wave for easy
detection.  This pilot sequence can be used to pinpoint the beginning of the
transmission in time, and to aid in recovery of the signal.
