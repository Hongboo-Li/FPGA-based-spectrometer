
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
LIBRARY XilinxCoreLib;
-- synthesis translate_on
ENTITY lp_fir IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END lp_fir;

ARCHITECTURE lp_fir_a OF lp_fir IS
-- synthesis translate_off
COMPONENT wrapped_lp_fir
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END COMPONENT;

-- Configuration specification
--  FOR ALL : wrapped_lp_fir USE ENTITY XilinxCoreLib.fir_compiler_v6_3(behavioral)
  FOR ALL : wrapped_lp_fir USE ENTITY xilinx.com_ip_fir_compiler_v7_2:(behavioral)

    GENERIC MAP (
      c_accum_op_path_widths => "44",
      c_accum_path_widths => "34,33",
      c_channel_pattern => "fixed",
      c_coef_file => "lp_fir.mif",
      c_coef_file_lines => 81,
      c_coef_mem_packing => 0,
      c_coef_memtype => 2,
      c_coef_path_sign => "0,0",
      c_coef_path_src => "0,0",
      c_coef_path_widths => "20,20",
      c_coef_reload => 0,
      c_coef_width => 20,
      c_col_config => "3",
      c_col_mode => 1,
      c_col_pipe_len => 4,
      c_component_name => "lp_fir",
      c_config_packet_size => 0,
      c_config_sync_mode => 0,
      c_config_tdata_width => 1,
      c_data_has_tlast => 0,
      c_data_mem_packing => 0,
      c_data_memtype => 0,
      c_data_path_sign => "1,0",
      c_data_path_src => "0,1",
      c_data_path_widths => "11,11",
      c_data_width => 22,
      c_datapath_memtype => 0,
      c_decim_rate => 1,
      c_ext_mult_cnfg => "0,1,0,11",
      c_filter_type => 0,
      c_filts_packed => 0,
      c_has_aclken => 0,
      c_has_aresetn => 0,
      c_has_config_channel => 0,
      c_input_rate => 32,
      c_interp_rate => 1,
      c_ipbuff_memtype => 0,
      c_latency => 39,
      c_m_data_has_tready => 0,
      c_m_data_has_tuser => 0,
      c_m_data_tdata_width => 24,
      c_m_data_tuser_width => 1,
      c_mem_arrangement => 1,
      c_num_channels => 1,
      c_num_filts => 1,
      c_num_madds => 3,
      c_num_reload_slots => 1,
      c_num_taps => 162,
      c_opbuff_memtype => 0,
      c_opt_madds => "none",
      c_optimization => 0,
      c_output_path_widths => "21",
      c_output_rate => 32,
      c_output_width => 21,
      c_oversampling_rate => 27,
      c_reload_tdata_width => 1,
      c_round_mode => 1,
      c_s_data_has_fifo => 0,
      c_s_data_has_tuser => 0,
      c_s_data_tdata_width => 24,
      c_s_data_tuser_width => 1,
      c_symmetry => 1,
      c_xdevicefamily => "artix7",
      c_zero_packing_factor => 1
    );
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_lp_fir
  PORT MAP (
    aclk => aclk,
    s_axis_data_tvalid => s_axis_data_tvalid,
    s_axis_data_tready => s_axis_data_tready,
    s_axis_data_tdata => s_axis_data_tdata,
    m_axis_data_tvalid => m_axis_data_tvalid,
    m_axis_data_tdata => m_axis_data_tdata
  );
-- synthesis translate_on

END lp_fir_a;
