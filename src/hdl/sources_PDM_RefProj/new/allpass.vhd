
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use IEEE.math_real.all;
use ieee.std_logic_arith.all;

entity allpass is
   generic(
      LOOP_TIME_MS      : real := 40.0;   -- tau [ms]
      REVERB_TIME_MS    : real := 1000.0; -- T60 [ms]
      SAMPLING_FREQ_KHZ : real := 48.0    -- Fs  [kHz]
   );
   port(
      -- global and control ports
      clk_i             : in  std_logic; -- 100 MHz system clock
      rst_i             : in  std_logic; -- active high system reset
      en_i              : in  std_logic; -- sampling frequency-synchronous 
                                         -- impulse
      -- input/output data
      data_i            : in  std_logic_vector(15 downto 0);
      data_o            : out std_logic_vector(15 downto 0)
   );
end allpass;

architecture Behavioral of allpass is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
-- Multiplier core
component mul
   port (
      a : in  std_logic_vector(16 downto 0);
      b : in  std_logic_vector(14 downto 0);
      p : out std_logic_vector(31 downto 0));
end component;

------------------------------------------------------------------------
-- Constant Definitions
------------------------------------------------------------------------
-- Gain = 0.001^(tau/T60)
constant GAIN           : real := 
   real(0.001**real(LOOP_TIME_MS/REVERB_TIME_MS));
-- Delay = tau*Fs
constant DELAY          : integer := 
   integer(real(SAMPLING_FREQ_KHZ*LOOP_TIME_MS));
-- multiplier gain value
constant MUL_VAL2       : std_logic_vector(14 downto 0) := 
   conv_std_logic_vector(integer(real(GAIN*(2**15.0))), 15);
constant MUL_VAL1       : std_logic_vector(14 downto 0) := 
   conv_std_logic_vector(integer(real(GAIN*(-1.0)*(2**15.0))), 15);
-- data bus width
constant DATA_WIDTH     : integer := 16;

------------------------------------------------------------------------
-- Type Declarations
------------------------------------------------------------------------
type x16 is array (0 to (DELAY-1)) of std_logic_vector(DATA_WIDTH downto 0);

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal tmp              : x16 := (others => (others => '0'));
signal data_add1        : std_logic_vector(DATA_WIDTH downto 0);
signal data_add2        : std_logic_vector(DATA_WIDTH downto 0);
signal delayed_data     : std_logic_vector(DATA_WIDTH downto 0);
signal multiplied_data1 : std_logic_vector(31 downto 0);
signal multiplied_data2 : std_logic_vector(31 downto 0);

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin
   
   data_add1 <= (data_i(DATA_WIDTH-1) & data_i) + 
                 multiplied_data2(31 downto (DATA_WIDTH-1));

   SHIFTER: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if en_i = '1' then
            tmp(1 to (DELAY-1)) <= tmp(0 to (DELAY-2));
            tmp(0) <= data_add1;
         end if;
      end if;
   end process SHIFTER;
   
   delayed_data <= tmp(DELAY-1);
   
   Multiplier2: mul
   port map(
      a     => delayed_data,
      b     => MUL_VAL2,
      p     => multiplied_data2);
   
   Multiplier1: mul
   port map(
      a     => data_add1,
      b     => MUL_VAL1,
      p     => multiplied_data1);
   
   data_add2 <= delayed_data + multiplied_data1(31 downto (DATA_WIDTH-1));
   data_o <= data_add2((DATA_WIDTH-1) downto 0);

end Behavioral;

