library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
library unisim;
use unisim.vcomponents.all;

entity audio_demo is
   port(
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      
      -- PDM interface with the MIC
      pdm_clk_o   : out std_logic;
      pdm_lrsel_o : out std_logic;
      pdm_data_i  : in  std_logic;
      
      -- parallel data from mic
      data_mic_valid : out std_logic;
      data_mic       : out std_logic_vector(15 downto 0);
     
      -- PWM interface with the audio out
      pdm_data_o  : out std_logic;
      pdm_en_o    : out std_logic
   );
end audio_demo;

architecture Behavioral of audio_demo is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
-- The PDM filter
component pdm_filter is
   port(
      clk_i             : in  std_logic;
      rst_i             : in  std_logic;
      pdm_clk_o         : out std_logic;
      pdm_lrsel_o       : out std_logic;
      pdm_data_i        : in  std_logic;
      fs_o              : out std_logic;
      data_o            : out std_logic_vector(15 downto 0));
end component;

-- Comb filter
component comb is
   generic(
      LOOP_TIME_MS      : real := 40.0;
      REVERB_TIME_MS    : real := 1000.0;
      SAMPLING_FREQ_KHZ : real := 48.0);
   port(
      clk_i             : in  std_logic;
      rst_i             : in  std_logic;
      en_i              : in  std_logic;
      data_i            : in  std_logic_vector(15 downto 0);
      data_o            : out std_logic_vector(15 downto 0));
end component;

-- All-pass filter
component allpass is
   generic(
      LOOP_TIME_MS      : real := 40.0;
      REVERB_TIME_MS    : real := 1000.0;
      SAMPLING_FREQ_KHZ : real := 48.0);
   port(
      clk_i             : in  std_logic;
      rst_i             : in  std_logic;
      en_i              : in  std_logic;
      data_i            : in  std_logic_vector(15 downto 0);
      data_o            : out std_logic_vector(15 downto 0));
end component;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal data_int   : std_logic_vector(15 downto 0);
signal pdm_acc    : std_logic_vector(16 downto 0);
signal pdm_data   : std_logic_vector(15 downto 0);
signal clk_int    : std_logic;
signal fs_int     : std_logic;
signal fs_tmp     : std_logic;
signal fss_tmp    : std_logic;
signal fs_comb    : std_logic;
signal fs_rise    : std_logic;
signal cnt        : integer := 0;
signal data_comb  : std_logic_vector(15 downto 0);
signal data_comb1 : std_logic_vector(15 downto 0);
signal data_comb2 : std_logic_vector(15 downto 0);
signal data_comb3 : std_logic_vector(15 downto 0);
signal data_comb4 : std_logic_vector(15 downto 0);
signal data_all   : std_logic_vector(15 downto 0);
signal data_all1  : std_logic_vector(15 downto 0);
signal data_all2  : std_logic_vector(15 downto 0);

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

   data_mic_valid <= fs_comb; -- 48MHz data enable
   data_mic <= data_int;      -- data from pdm_filter

   
--   IBUFG_inst : IBUFG
--   generic map (
--      IBUF_LOW_PWR => TRUE,
--      IOSTANDARD => "DEFAULT")
--   port map (
--      O => clk_int,
--      I => clk_i);

   clk_int <= clk_i;  -- removing the ibufg above (MD)

   -- filtering the PDM signal
   PdmFilter: pdm_filter
   port map(
      clk_i       => clk_int,
      rst_i       => rst_i,
      pdm_clk_o   => pdm_clk_o,
      pdm_lrsel_o => pdm_lrsel_o,
      pdm_data_i  => pdm_data_i,
      fs_o        => fs_int,
      data_o      => data_int);
   
   POSEDGE: process(clk_int)
   begin
      if rising_edge(clk_int) then
         fs_tmp <= fs_int;
         fss_tmp <= fs_tmp;
      end if;
   end process POSEDGE;
   
   -- rising edge of fs_int
   fs_rise <= '1' when fs_tmp = '1' and fss_tmp = '0' else '0';
   
   -- dividing the fs by 2, resulting in a 48 kHz impluse rate
   DIV2: process(clk_int)
   begin
      if rising_edge(clk_int) then
         if rst_i = '1' then
            cnt <= 0;
         elsif fs_rise = '1' then
            if cnt >= 1 then
               cnt <= 0;
            else
               cnt <= cnt + 1;
            end if;
         end if;
      end if;
   end process DIV2;
   
   fs_comb <= '1' when cnt = 1 and fs_rise = '1' else '0';
   
   -- tau = 29.7 ms, T60 = 1 s
   Comb1: comb
   generic map(
      LOOP_TIME_MS      => 29.7,
      REVERB_TIME_MS    => 1000.0,
      SAMPLING_FREQ_KHZ => 48.0)
   port map(
      clk_i             => clk_int,
      rst_i             => rst_i,
      en_i              => fs_comb,
      data_i            => data_int,
      data_o            => data_comb1);
   
   -- tau = 37.1 ms, T60 = 1 s
   Comb2: comb
   generic map(
      LOOP_TIME_MS      => 37.1,
      REVERB_TIME_MS    => 1000.0,
      SAMPLING_FREQ_KHZ => 48.0)
   port map(
      clk_i             => clk_int,
      rst_i             => rst_i,
      en_i              => fs_comb,
      data_i            => data_int,
      data_o            => data_comb2);
   
   -- tau = 41.1 ms, T60 = 1 s
   Comb3: comb
   generic map(
      LOOP_TIME_MS      => 41.1,
      REVERB_TIME_MS    => 1000.0,
      SAMPLING_FREQ_KHZ => 48.0)
   port map(
      clk_i             => clk_int,
      rst_i             => rst_i,
      en_i              => fs_comb,
      data_i            => data_int,
      data_o            => data_comb3);
   
   -- tau = 43.7 ms, T60 = 1 s
   Comb4: comb
   generic map(
      LOOP_TIME_MS      => 43.7,
      REVERB_TIME_MS    => 1000.0,
      SAMPLING_FREQ_KHZ => 48.0)
   port map(
      clk_i             => clk_int,
      rst_i             => rst_i,
      en_i              => fs_comb,
      data_i            => data_int,
      data_o            => data_comb4);
   
   data_comb <= data_comb1 + data_comb2 + data_comb3 + data_comb4;
   
   -- tau = 5 ms, T60 = 96.83 ms
   AllPass1: allpass
   generic map(
      LOOP_TIME_MS      => 5.0,
      REVERB_TIME_MS    => 96.83,
      SAMPLING_FREQ_KHZ => 48.0)
   port map(
      clk_i             => clk_int,
      rst_i             => rst_i,
      en_i              => fs_comb,
      data_i            => data_comb,
      data_o            => data_all1);
   
   -- tau = 1.7 ms, T60 = 32.92 ms
   AllPass2: allpass
   generic map(
      LOOP_TIME_MS      => 1.7,
      REVERB_TIME_MS    => 32.92,
      SAMPLING_FREQ_KHZ => 48.0)
   port map(
      clk_i             => clk_int,
      rst_i             => rst_i,
      en_i              => fs_comb,
      data_i            => data_all1,
      data_o            => data_all2);
   
   -- Output data (generating PDM again to output it to the
   --  analog filter, audio out)
   pdm_data <= (not data_all2(15)) & data_all2(14 downto 0);
   
   PdmGen: process(clk_int)
   begin
      if rising_edge(clk_int) then
         pdm_acc <= ("0" & pdm_acc(15 downto 0)) + ("0" & pdm_data);
      end if;
   end process PdmGen;
   
   pdm_data_o <= pdm_acc(16);
   pdm_en_o <= '1';

end Behavioral;

