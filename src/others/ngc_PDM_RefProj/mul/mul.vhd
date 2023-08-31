

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
LIBRARY XilinxCoreLib;
-- synthesis translate_on
ENTITY mul IS
  PORT (
    a : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END mul;

ARCHITECTURE mul_a OF mul IS
-- synthesis translate_off
COMPONENT wrapped_mul
  PORT (
    a : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

-- Configuration specification
--  FOR ALL : wrapped_mul USE ENTITY XilinxCoreLib.mult_gen_v11_2(behavioral)
  FOR ALL : wrapped_mul USE ENTITY xilinx.com_ip_mult_gen_v12_0:(behavioral)

    GENERIC MAP (
      c_a_type => 0,
      c_a_width => 17,
      c_b_type => 0,
      c_b_value => "10000001",
      c_b_width => 15,
      c_ccm_imp => 0,
      c_ce_overrides_sclr => 0,
      c_has_ce => 0,
      c_has_sclr => 0,
      c_has_zero_detect => 0,
      c_latency => 0,
      c_model_type => 0,
      c_mult_type => 1,
      c_optimize_goal => 0,
      c_out_high => 31,
      c_out_low => 0,
      c_round_output => 0,
      c_round_pt => 0,
      c_verbosity => 0,
      c_xdevicefamily => "artix7"
    );
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_mul
  PORT MAP (
    a => a,
    b => b,
    p => p
  );
-- synthesis translate_on

END mul_a;
