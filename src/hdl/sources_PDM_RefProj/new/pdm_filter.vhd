
library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity pdm_filter is
   port(
      -- global signals
      clk_i             : in  std_logic; -- 100 MHz system clock
      rst_i             : in  std_logic; -- active-high system reset
      
      -- PDM interface to microphone
      pdm_clk_o         : out std_logic;
      pdm_lrsel_o       : out std_logic;
      pdm_data_i        : in  std_logic;
      
      -- output data
      fs_o              : out std_logic;
      data_o            : out std_logic_vector(15 downto 0)
   );
end pdm_filter;

architecture Behavioral of pdm_filter is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
-- 6.144 MHz clock generator
component clk_gen
   port(
      clk_100MHz_i         : in  std_logic;
      clk_6_144MHz_o       : out std_logic;
      rst_i                : in  std_logic;
      locked_o             : out std_logic);
end component;

-- Cascaded Integrator-Comb filter with:
--    N = 5
--    R = 8
--    M = 1
component cic
   port(
      aclk                 : in  std_logic;
      s_axis_data_tdata    : in  std_logic_vector(7 downto 0);
      s_axis_data_tvalid   : in  std_logic;
      s_axis_data_tready   : out std_logic;
      m_axis_data_tdata    : out std_logic_vector(23 downto 0);
      m_axis_data_tvalid   : out std_logic);
end component;

-- FIR Halfband filter with the transition band between [0.1136, 0.3864] 
-- pi rad/sample and having the following 15 coefficients:
-- [-100, 0, 614, 0, -2295, 0, 9971, 16383, 9971, 0, -2295, 0, 614, 0,
-- -100]
component hb_fir
   port(
      aclk                 : in  std_logic;
      s_axis_data_tvalid   : in  std_logic;
      s_axis_data_tready   : out std_logic;
      s_axis_data_tdata    : in  std_logic_vector(23 downto 0);
      m_axis_data_tvalid   : out std_logic;
      m_axis_data_tready   : in  std_logic;
      m_axis_data_tdata    : out std_logic_vector(23 downto 0));
end component;

-- FIR Lowpass filter
component lp_fir
   port(
      aclk                 : in  std_logic;
      s_axis_data_tvalid   : in  std_logic;
      s_axis_data_tready   : out std_logic;
      s_axis_data_tdata    : in  std_logic_vector(23 downto 0);
      m_axis_data_tvalid   : out std_logic;
      m_axis_data_tdata    : out std_logic_vector(23 downto 0));
end component;

-- RC Highpass filter, with fc = ~18.6 Hz
component hp_rc
   port(
      clk_i                : in  std_logic;
      rst_i                : in  std_logic;
      en_i                 : in  std_logic;
      data_i               : in  std_logic_vector(15 downto 0);
      data_o               : out std_logic_vector(15 downto 0));
end component;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
-- Clock related signals
signal clk_3_072MHz     : std_logic;
signal clk_3_072MHz_int : std_logic;
signal clk_6_144MHz_int : std_logic;
signal clk_6_144MHz_div : std_logic;
signal clk_locked       : std_logic;

-- CIC signals
signal s_cic_tdata      : std_logic_vector(7 downto 0);
signal m_cic_tdata      : std_logic_vector(23 downto 0);
signal m_cic_tvalid     : std_logic;

-- HB signals
signal m_hb_tvalid      : std_logic;
signal m_hb_tready      : std_logic;
signal m_hb_tdata       : std_logic_vector(23 downto 0);

-- LP signals
signal m_lp_tvalid      : std_logic;
signal m_lp_tready      : std_logic;
signal m_lp_tdata       : std_logic_vector(23 downto 0);

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

   -- Sampling clock generator (3.072 MHz)
   ClkGen: clk_gen
   port map(
      clk_100MHz_i         => clk_i,
      clk_6_144MHz_o       => clk_6_144MHz_int,
      rst_i                => rst_i,
      locked_o             => clk_locked);
   
   -- Dividing by 2 the 6.144 MHz clock
   ClkDiv2: BUFR
   generic map (
      BUFR_DIVIDE          => "2",
      SIM_DEVICE           => "7SERIES")
   port map(
      O                    => clk_6_144MHz_div,
      CE                   => '1',
      CLR                  => '0',
      I                    => clk_6_144MHz_int);
   
   -- Buffering the divided clock (3.072 MHz)
   ClkDivBuf: BUFG
   port map(
      O                    => clk_3_072MHz_int,
      I                    => clk_6_144MHz_div);
   
   -- Outputing the microphone clock
   clk_3_072MHz <= clk_3_072MHz_int when clk_locked = '1' else '1';
   pdm_clk_o <= clk_3_072MHz;
   
   -- With L/R sel. signal tied to GND => output = DATA1 (rising edge).
   -- So sampling can be made on the rising edge of m_clk.
   pdm_lrsel_o <= '0';
   
   -- As the minimum input data width is 8, the input PDM data is feeded
   -- into the second bit of the 8-bit bus:
   --     7      6      5      4      3      2      1      0
   -- |------|------|------|------|------|------|------|------|
   -- | sign | sign | sign | sign | sign | sign | sign | data |
   -- |------|------|------|------|------|------|------|------|
   --  \___________________ ___________________/    \      \
   --                      V                         \      always '1'
   --                sign extension                   not pdm_data
   --   
   s_cic_tdata(7 downto 1) <= (others => (not pdm_data_i));
   s_cic_tdata(0) <= '1';
   
   -- First stage: CIC decimator.
   -- This filter downsample's the incomming 3.072 MHz signal to 192 kHz.
   CICd: cic
   port map(
      aclk                 => clk_3_072MHz,
      s_axis_data_tdata    => s_cic_tdata,
      s_axis_data_tvalid   => '1',
      s_axis_data_tready   => open,
      m_axis_data_tdata    => m_cic_tdata,
      m_axis_data_tvalid   => m_cic_tvalid);
   
   -- Second stage: Halfband filter with decimation ratio of 2 and input
   -- sampling frequency of 192 kHz, resulting in a 96 kHz output sample 
   -- rate.
   -- According to the Bmax = Nlog2(RM)+B formula, the output of the CIC
   -- filter is 22-bit wide but rounded up to 24:
   --  23     ...     22   21   20           ...        1   0
   -- |-----------------|------|-------------------------|-----|
   -- |   sign extend   | sign |            data         | '0' |
   -- |-----------------|------|-------------------------|-----|
   -- Because s_cic_tdata(0) is always '1', the output of the CIC will 
   -- also have its LSB '0' so we discard it, meaning that the actual 
   -- output of the CIC will be m_cic_tdata(15 downto 1).
   -- The output of the filter is symmetrically rounded to infinity and 
   -- truncated to 24 bits.
   HB: hb_fir
   port map(
      aclk                 => clk_3_072MHz,
      s_axis_data_tvalid   => m_cic_tvalid,
      s_axis_data_tready   => open,
      s_axis_data_tdata    => m_cic_tdata,
      m_axis_data_tvalid   => m_hb_tvalid,
      m_axis_data_tready   => m_hb_tready,
      m_axis_data_tdata    => m_hb_tdata);
   
   -- Third stage: Lowpass filter with no decimation and the input 
   -- sampling frequency of 96 kHz.
   -- The output of the filter is symmetrically rounded to infinity to 
   -- 24 bits.
   LP: lp_fir
   port map(
      aclk                 => clk_3_072MHz,
      s_axis_data_tvalid   => m_hb_tvalid,
      s_axis_data_tready   => m_hb_tready,
      s_axis_data_tdata    => m_hb_tdata,
      m_axis_data_tvalid   => m_lp_tvalid,
      m_axis_data_tdata    => m_lp_tdata);
   
   -- Fourth stage: First order highpass filter, used for removing any 
   -- DC component.
   HP: hp_rc
   port map(
      clk_i                => clk_3_072MHz,
      rst_i                => rst_i,
      en_i                 => m_lp_tvalid,
      data_i               => m_lp_tdata(16 downto 1),
      data_o               => data_o);
   
   fs_o <= m_lp_tvalid;
   
end Behavioral;

