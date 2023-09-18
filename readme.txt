基于FPGA的频谱仪

This project is a spectrometer based on Nexys4DDR.
This project uses VHDL language and Vivado 2019.1.
You need to use a VGA monitor to see the output which should be connected to the board.

This spectrometer displays the sound signal and its spectrum in real time and The sound frequency can reach 11kHz which is limited by the microphone chip in development board.If you want to reach higher frequency,you can connect another high-performance microphone chip to the board.

To run this porject,first you should open proj\Nexys4Spectral\Nexys4Spectral in Vivado.
Then just generate bitstream and download into the board.After that,you can see the output in VGA monitor.

Attention,some files maybe useless.However, it does not affect the overall functionality, so don't bother.
