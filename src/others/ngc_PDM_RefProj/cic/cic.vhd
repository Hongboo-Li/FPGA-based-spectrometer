
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
LIBRARY XilinxCoreLib;
-- synthesis translate_on
ENTITY cic IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC
  );
END cic;

ARCHITECTURE cic_a OF cic IS
-- synthesis translate_off
COMPONENT wrapped_cic
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC
  );
END COMPONENT;

-- Configuration specification
--  FOR ALL : wrapped_cic USE ENTITY XilinxCoreLib.cic_compiler_v3_0(behavioral)
  FOR ALL : wrapped_cic USE ENTITY xilinx.com_ip_cic_compiler_v4_0:(behavioral)

    GENERIC MAP (
      C_C1 => 22,
      C_C2 => 22,
      C_C3 => 22,
      C_C4 => 22,
      C_C5 => 22,
      C_C6 => 0,
      C_CLK_FREQ => 1,
      C_COMPONENT_NAME => "cic",
      C_DIFF_DELAY => 1,
      C_FAMILY => "artix7",
      C_FILTER_TYPE => 1,
      C_HAS_ACLKEN => 0,
      C_HAS_ARESETN => 0,
      C_HAS_DOUT_TREADY => 0,
      C_HAS_ROUNDING => 0,
      C_I1 => 22,
      C_I2 => 22,
      C_I3 => 22,
      C_I4 => 22,
      C_I5 => 22,
      C_I6 => 0,
      C_INPUT_WIDTH => 2,
      C_MAX_RATE => 16,
      C_MIN_RATE => 16,
      C_M_AXIS_DATA_TDATA_WIDTH => 24,
      C_M_AXIS_DATA_TUSER_WIDTH => 1,
      C_NUM_CHANNELS => 1,
      C_NUM_STAGES => 5,
      C_OUTPUT_WIDTH => 22,
      C_RATE => 16,
      C_RATE_TYPE => 0,
      C_SAMPLE_FREQ => 1,
      C_S_AXIS_CONFIG_TDATA_WIDTH => 1,
      C_S_AXIS_DATA_TDATA_WIDTH => 8,
      C_USE_DSP => 1,
      C_USE_STREAMING_INTERFACE => 1,
      C_XDEVICEFAMILY => "artix7"
    );
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_cic
  PORT MAP (
    aclk => aclk,
    s_axis_data_tdata => s_axis_data_tdata,
    s_axis_data_tvalid => s_axis_data_tvalid,
    s_axis_data_tready => s_axis_data_tready,
    m_axis_data_tdata => m_axis_data_tdata,
    m_axis_data_tvalid => m_axis_data_tvalid
  );
-- synthesis translate_on

END cic_a;
