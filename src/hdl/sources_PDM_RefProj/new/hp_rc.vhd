
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_signed.all;

entity hp_rc is
   port(
      clk_i    : in  std_logic; -- 100 MHz
      rst_i    : in  std_logic;
      en_i     : in  std_logic; -- sampling frequency
      data_i   : in  std_logic_vector(15 downto 0);
      data_o   : out std_logic_vector(15 downto 0)
   );
end hp_rc;

architecture Behavioral of hp_rc is

------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------
constant D              : integer range 1 to 4096 := 4096; -- fc = ~18.6 Hz
constant SHIFT_POS      : integer := integer(ceil(log2(real(D))));
constant MAX_SHIFT_POS  : integer := 12; -- 4096

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal int_sub    : std_logic_vector(16 downto 0) := (others => '0');
signal int_mult   : std_logic_vector(28 downto 0) := (others => '0');
signal int_temp   : std_logic_vector(28 downto 0) := (others => '0');

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin
   
   -- Subtracting only the integer part and discard the fractional part
   -- of int_temp. The subtractor:
   int_sub <= (data_i(15) & data_i) - int_temp(28 downto 12);
   
   -- Multiply by the power of two => right shift with log2 of the power 
   -- of two. Sign extending:
   int_mult(28 downto (28-SHIFT_POS)+1) <= (others => int_sub(16));
   -- Right shifting:
   int_mult((28-SHIFT_POS) downto 0) <= int_sub;
   
   -- Final output:
   data_o <= int_sub(15 downto 0);

   -- Integral part
   Integrate: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if rst_i = '1' then
            int_temp <= (others => '0');
         else
            if en_i = '1' then
               int_temp <= int_temp + int_mult;
            end if;
         end if;
      end if;
   end process Integrate;

end Behavioral;

