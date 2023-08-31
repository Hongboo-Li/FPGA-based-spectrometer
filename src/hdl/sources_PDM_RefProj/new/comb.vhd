
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use IEEE.math_real.all;
use ieee.std_logic_arith.all;

entity comb is
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
end comb;

architecture Behavioral of comb is

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
-- Gain = 10^(-3*tau/T60)
constant GAIN           : real := 
   real(10**real(((-3.0)*LOOP_TIME_MS)/REVERB_TIME_MS));
-- Delay = tau*Fs
constant DELAY          : integer := 
   integer(real(SAMPLING_FREQ_KHZ*LOOP_TIME_MS));
-- multiplier gain value
constant MUL_VAL        : std_logic_vector(14 downto 0) := 
   conv_std_logic_vector(integer(real(GAIN*(2**15.0))), 15);
-- data bus width
constant DATA_WIDTH     : integer := 16;

------------------------------------------------------------------------
-- Type Declarations
------------------------------------------------------------------------
type x16 is array (0 to (DELAY-1)) of std_logic_vector(DATA_WIDTH downto 0);

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
-- data after the adder
signal data_add         : std_logic_vector(DATA_WIDTH downto 0);
-- temporary delayed data
signal tmp              : x16 := (others => (others => '0'));
-- delayed data
signal delayed_data     : std_logic_vector(DATA_WIDTH downto 0);
signal multiplied_data  : std_logic_vector(31 downto 0);

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin
   
   data_add <= multiplied_data(31 downto (DATA_WIDTH-1)) + 
               (data_i(DATA_WIDTH-1) & data_i);

   SHIFTER: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if en_i = '1' then
            tmp(1 to (DELAY-1)) <= tmp(0 to (DELAY-2));
            tmp(0) <= data_add;
         end if;
      end if;
   end process SHIFTER;
   
   delayed_data <= tmp(DELAY-1);
   
   Multiplier: mul
   port map(
      a     => delayed_data,
      b     => MUL_VAL,
      p     => multiplied_data);
   
   data_o <= delayed_data((DATA_WIDTH-1) downto 0);

end Behavioral;

