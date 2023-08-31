// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Jun 13 15:15:33 2023
// Host        : LAPTOP-QEFK5BML running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/Xilinx_Vivado_SDK_2019.1_0524_1430/item/Nexys4DdrSpectralSources_pro1/Nexys4DdrSpectralSources_pro/src/ip/blk_mem_gen_0/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module blk_mem_gen_0(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[11:0],dina[7:0],clkb,enb,addrb[11:0],doutb[7:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [11:0]addra;
  input [7:0]dina;
  input clkb;
  input enb;
  input [11:0]addrb;
  output [7:0]doutb;
endmodule
