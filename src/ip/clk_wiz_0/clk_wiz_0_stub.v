// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue May 16 17:12:57 2023
// Host        : LAPTOP-QEFK5BML running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/Xilinx_Vivado_SDK_2019.1_0524_1430/item/Nexys4DdrSpectralSources/src/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(ck4800kHz, ck25MHz, reset, locked, ck100MHz)
/* synthesis syn_black_box black_box_pad_pin="ck4800kHz,ck25MHz,reset,locked,ck100MHz" */;
  output ck4800kHz;
  output ck25MHz;
  input reset;
  output locked;
  input ck100MHz;
endmodule
