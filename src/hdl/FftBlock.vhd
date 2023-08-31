
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FftBlock is
Port ( 
    flgStartAcquisition : in std_logic;  -- resets the lad state machine
--    btnL: in STD_LOGIC;  -- debugResetLoadStateMachine
    sw: in std_logic_vector(2 downto 0); -- selecting output data byte (sensitivity) (sw2:0)
    ckaTime : in STD_LOGIC;
    enaTime : out STD_LOGIC;
    weaTime : out STD_LOGIC;
    addraTime : out STD_LOGIC_VECTOR (11 downto 0);
    dinaTime : in STD_LOGIC_VECTOR (7 downto 0);
    ckFreq : in STD_LOGIC;
    flgFreqSampleValid : out STD_LOGIC;
    addrFreq : out STD_LOGIC_VECTOR (11 downto 0);
    byteFreqSample : out STD_LOGIC_VECTOR (7 downto 0)
--    --debug
--    debugcntFftLoadTime: out STD_LOGIC_VECTOR (9 downto 0);
--    debugcntFftUnloadFreq: out STD_LOGIC_VECTOR (9 downto 0);

--    debugaclk : out STD_LOGIC;
--    debugaresetn : out std_logic;
--    debugStateCode: out std_logic_vector(2 downto 0);

--    debugs_axis_config_tdata : out STD_LOGIC_VECTOR(7 DOWNTO 0);
--    debugs_axis_config_tvalid : out STD_LOGIC;
--    debugs_axis_config_tready : OUT STD_LOGIC;
--    debugs_axis_data_tdata : out STD_LOGIC_VECTOR(15 DOWNTO 0);
--    debugs_axis_data_tvalid : out STD_LOGIC;
--    debugs_axis_data_tready : OUT STD_LOGIC;
--    debugs_axis_data_tlast : out STD_LOGIC;
--    debugm_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
--    debugm_axis_data_tvalid : OUT STD_LOGIC;
--    debugm_axis_data_tready : out STD_LOGIC;
--    debugm_axis_data_tlast : OUT STD_LOGIC;
--    debugevent_frame_started : OUT STD_LOGIC;
--    debugevent_tlast_unexpected : OUT STD_LOGIC;
--    debugevent_tlast_missing : OUT STD_LOGIC;
--    debugevent_status_channel_halt : OUT STD_LOGIC;
--    debugevent_data_in_channel_halt : OUT STD_LOGIC;
--    debugevent_data_out_channel_halt : OUT STD_LOGIC;
--    debugm_axis_data_tbyte: out std_logic_vector(7 downto 0)
    );   
end FftBlock;

architecture Behavioral of FftBlock is

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;
ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF blk_mem_gen_0 : COMPONENT IS TRUE;
ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF blk_mem_gen_0 : COMPONENT IS "clka,ena,wea[0:0],addra[11:0],dina[7:0],clkb,enb,addrb[11:0],doutb[7:0]";

-- COMP_TAG_END ------ End COMPONENT Declaration ------------


------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT xfft_1
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : in std_logic;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_status_channel_halt : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC;
    event_data_out_channel_halt : OUT STD_LOGIC
  );
END COMPONENT;
--ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF xfft_1 : COMPONENT IS TRUE;
--ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF xfft_1 : COMPONENT IS "aclk,s_axis_config_tdata[7:0],s_axis_config_tvalid,s_axis_config_tready,s_axis_data_tdata[15:0],s_axis_data_tvalid,s_axis_data_tready,s_axis_data_tlast,m_axis_data_tdata[47:0],m_axis_data_tvalid,m_axis_data_tready,m_axis_data_tlast,event_frame_started,event_tlast_unexpected,event_tlast_missing,event_status_channel_halt,event_data_in_channel_halt,event_data_out_channel_halt";
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

--  internal signals
   signal intEnaTime :  STD_LOGIC;
   signal intWeaTime :  STD_LOGIC;
   signal intAddraTime : STD_LOGIC_VECTOR (12 downto 0);


-- constant and signal declarations

-- xfft_1 interface
   signal aresetn : std_logic;
   constant s_axis_config_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";  -- reverse order
   signal s_axis_config_tvalid : STD_LOGIC;
   signal s_axis_config_tready : STD_LOGIC;
   signal s_axis_data_tdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
   signal s_axis_data_tbyte : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- a byte of above
   signal s_axis_data_tvalid : STD_LOGIC;
   signal s_axis_data_tready : STD_LOGIC;
   signal s_axis_data_tlast : STD_LOGIC;
   signal m_axis_data_tdata : STD_LOGIC_VECTOR(47 DOWNTO 0);
   signal m_axis_data_tbyte : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- a byte of above
   signal m_axis_data_tvalid : STD_LOGIC;
   signal m_axis_data_tready : STD_LOGIC;
   signal m_axis_data_tlast : STD_LOGIC;
   signal event_frame_started : STD_LOGIC;
   signal event_tlast_unexpected : STD_LOGIC;
   signal event_tlast_missing : STD_LOGIC;
   signal event_status_channel_halt : STD_LOGIC;
   signal event_data_in_channel_halt : STD_LOGIC;
   signal event_data_out_channel_halt : STD_LOGIC;
   
-- AXI state machine signals
   type typeAxiLoad is (stRes0, stRes1, stConfig, stIdle);
   signal stAxiLoadCur, stAxiLoadNext: typeAxiLoad := stRes0;
   
-- time acquisition signals
   signal oldDinaTime : STD_LOGIC_VECTOR (7 downto 0);  -- previous time sample (for edge detection)
   signal flgReset : std_logic;  -- reset for time acquisition counter (includes edge sync)
   
   signal demo : STD_LOGIC_VECTOR (10 downto 0);
   
-- Load/Unload counters' signals
   signal cntFftLoadTime, cntFftUnloadFreq: STD_LOGIC_VECTOR (11 downto 0);
   signal flgCountLoad: std_logic; -- active while counting

   signal cenLoadCounter: std_logic; -- count enable for Load counter
   signal cenUnloadCounter: std_logic; -- count enable for Unload counter

   signal ckFft: std_logic; -- clock inside the FFT Block

--   signal m_axis_data_tpower: STD_LOGIC_VECTOR (47 downto 0);
   signal m_axis_data_tpower: STD_LOGIC_VECTOR (35 downto 0);  -- 18x18 bit multiplication

---- debug
--    attribute mark_debug : string;
--    attribute mark_debug of aresetn : signal is "true";
----    attribute mark_debug of s_axis_config_tdata : signal is "true";  -- reverse order
--   attribute mark_debug of s_axis_config_tvalid : signal is "true";
--   attribute mark_debug of s_axis_config_tready : signal is "true";
--   attribute mark_debug of s_axis_data_tdata : signal is "true";
--   attribute mark_debug of s_axis_data_tbyte : signal is "true";  -- a byte of above
--   attribute mark_debug of s_axis_data_tvalid : signal is "true";
--   attribute mark_debug of s_axis_data_tready : signal is "true";
--   attribute mark_debug of s_axis_data_tlast : signal is "true";
--   attribute mark_debug of m_axis_data_tdata : signal is "true";
--   attribute mark_debug of m_axis_data_tbyte : signal is "true";  -- a byte of above
--   attribute mark_debug of m_axis_data_tvalid : signal is "true";
--   attribute mark_debug of m_axis_data_tready : signal is "true";
--   attribute mark_debug of m_axis_data_tlast : signal is "true";
--   attribute mark_debug of event_frame_started : signal is "true";
--   attribute mark_debug of event_tlast_unexpected : signal is "true";
--   attribute mark_debug of event_tlast_missing : signal is "true";
--   attribute mark_debug of event_status_channel_halt : signal is "true";
--   attribute mark_debug of event_data_in_channel_halt : signal is "true";
--   attribute mark_debug of event_data_out_channel_halt : signal is "true";

begin

   enaTime <= intEnaTime;
   weaTime <= intWeaTime;
--   addraTime <= intAddraTime;
   
   ckFft <= ckaTime; -- run at 100MHz

---- debug
--debugcntFftLoadTime <= cntFftLoadTime;
--debugcntFftUnloadFreq <= cntFftUnloadFreq;
--debugaclk <= ckFft;
--debugaresetn <= aresetn;
--debugs_axis_config_tdata <= s_axis_config_tdata;
--debugs_axis_config_tvalid <= s_axis_config_tvalid;
--debugs_axis_config_tready <= s_axis_config_tready;
--debugs_axis_data_tdata <= s_axis_data_tdata;
--debugs_axis_data_tvalid <= s_axis_data_tvalid;
--debugs_axis_data_tready <= s_axis_data_tready;
--debugs_axis_data_tlast <= s_axis_data_tlast;
--debugm_axis_data_tdata <= m_axis_data_tdata;
--debugm_axis_data_tvalid <= m_axis_data_tvalid;
--debugm_axis_data_tready <= m_axis_data_tready;
--debugm_axis_data_tlast <= m_axis_data_tlast;
--debugevent_frame_started <= event_frame_started;
--debugevent_tlast_unexpected <= event_tlast_unexpected;
--debugevent_tlast_missing <= event_tlast_missing;
--debugevent_status_channel_halt <= event_status_channel_halt;
--debugevent_data_in_channel_halt <= event_data_in_channel_halt;
--debugevent_data_out_channel_halt <= event_data_out_channel_halt;

-- debugStateCode <= "000" when stAxiLoadCur = stRes0 else
--                   "001" when stAxiLoadCur = stRes1 else
--                   "010" when stAxiLoadCur = stConfig else
--                   "011" when stAxiLoadCur = stIdle else
--                   "110";-- when stAxiLoadCur = stDone else

   ResetStateMachine: process (ckFft)
   begin
      if (ckFft'event and ckFft = '1') then
--         if (btnL = '1') then      -- reset laod state machine
--            stAxiLoadCur <= stRes0;
--         else  
            stAxiLoadCur <= stAxiLoadNext;
--         end if;        
      end if;
   end process;
 
   --MOORE State-Machine - Outputs based on state only
   OUTPUT_DECODE: process (stAxiLoadCur)
   begin
   -- default values
      aresetn <= '1';  -- inactive
      s_axis_config_tvalid <= '1';  -- make it always active (config data  always vaslid)
--      s_axis_data_tvalid <= '0';  
      s_axis_data_tvalid <= '1';  -- debug ALWAYS valid
      s_axis_data_tlast <= not flgCountLoad;  --  not active while counting;
      m_axis_data_tready <= '1';  -- always ready to get frequency samples
      
      if stAxiLoadCur = stRes0 or stAxiLoadCur = stRes1  then
         aresetn <= '0';  -- active
      end if;

   end process;
 
   NEXT_STATE_DECODE: process (stAxiLoadCur)
   begin
      --declare default state for next_state to avoid latches
      stAxiLoadNext <= stAxiLoadCur;  --default is to stay in current state

      case (stAxiLoadCur) is
         when stRes0 =>
               stAxiLoadNext <= stRes1;

         when stRes1 =>
               stAxiLoadNext <= stConfig;

         when stConfig =>
            if s_axis_config_tready = '1' then
               stAxiLoadNext <= stIdle;
            end if;

-- stay forever in stIdle

         when stIdle =>
            null;

         when others =>
            stAxiLoadNext <= stRes0;
            
      end case;      
   end process;

   addraTime <= intAddraTime(11 downto 0);  -- 10bit out
   intEnaTime <= not intAddraTime(12);  -- blocked when cnt(10) = 1

TimeAcqSync: process(ckaTime)  -- sync time acquisition on rising edge at level zero
   begin
   if rising_edge(ckaTime) then
      if intWeaTime = '1' then
         oldDinaTime <= dinaTime;   -- store current sample for later
      end if;   
      if flgStartAcquisition = '1' then
         flgReset <= '1';
      elsif intWeaTime = '1' and -- valid sample
            oldDinaTime < 0 and  -- last sample negative
            dinaTime >= 0 then    -- current sample positive
         flgReset <= '0';
      end if;
   end if;
end process;                    
   
TimeCounter: process(ckaTime)
   begin
      if rising_edge(ckaTime) then
         if flgReset = '1' then
            intAddraTime <= (others => '0');
         elsif intWeaTime = '1' then
            if intAddraTime(12) = '1' then -- blocking condition
               null;
            else
               intAddraTime <= intAddraTime + '1';
            end if;
         end if;
      end if;
   end process;                    

FftLoadCounter: process(ckFft)
   begin
      if rising_edge(ckFft) then
         if s_axis_data_tready = '1' then
            cntFftLoadTime <= cntFftLoadTime + '1';
         end if;
         flgCountLoad <= '1'; -- active low
         if cntFftLoadTime = "111111111110" then
--            cntFftLoadTime <= (others => '0');  -- reset (useles)
            flgCountLoad <= '0'; -- active low
         end if;   
--         if event_tlast_missing = '1' then  -- lost of sync
         if aresetn = '0' then  -- fft reset
            cntFftLoadTime <= (others => '0');  -- reset (sync with fft)
         end if;   
      end if;
   end process;      

FftUnloadCounter: process(ckFft)
   begin
      if rising_edge(ckFft) then
         cntFftUnloadFreq <= cntFftUnloadFreq + '1';
         if cntFftUnloadFreq = "111111111111" then
            cntFftUnloadFreq <= (others => '0');  -- reset (useles)
         elsif m_axis_data_tlast = '1' then  -- sync
            cntFftUnloadFreq <= (others => '0');  -- reset (sync)
         end if;   
      end if;
   end process;      

--   demo <= ("0" & cntFftUnloadFreq) + "01111111111" - "00010010110";
--   addrFreq <= demo(9 downto 0);
   addrFreq <= cntFftUnloadFreq;

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
TimeBlkMemForFft: blk_mem_gen_0
  PORT MAP (
--    clka => ck2400kHz,
    clka => ckaTime,
    ena => intEnaTime, -- active while counting
    wea(0) => intWeaTime,  -- wea is std_logic_vector(0 downto 0) ...
    addra => intAddraTime(11 downto 0),
    dina => dinaTime,
    clkb => ckFft,  -- Video clock 
    enb => '1',
    addrb => cntFftLoadTime,
    doutb => s_axis_data_tbyte
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

   s_axis_data_tdata(7 downto 0) <= s_axis_data_tbyte ;  -- real part of the time data
   s_axis_data_tdata(15 downto 8) <= (others => '0');    -- imaginary part of the time data

   m_axis_data_tpower <= m_axis_data_tdata(18 downto 1) * m_axis_data_tdata(18 downto 1) +   -- 18x18 bit multiplication
                         m_axis_data_tdata(42 downto 25) * m_axis_data_tdata(42 downto 25);  -- 36 bit signaed result (always positive)
   -- m_axis_data_tdata has 19 significant bits in each real and immaginary parts  
     
   byteFreqSample <= m_axis_data_tpower(30 downto 23) when sw(2 downto 0) = "000" else  -- FFT output range (gain) 
--   byteFreqSample <= m_axis_data_tpower(47 downto 40) when sw(2 downto 0) = "000" else  -- FFT output range (gain) 
                     m_axis_data_tpower(29 downto 22) when sw(2 downto 0) = "001" else
                     m_axis_data_tpower(28 downto 21) when sw(2 downto 0) = "010" else
                     m_axis_data_tpower(27 downto 20) when sw(2 downto 0) = "011" else
                     m_axis_data_tpower(26 downto 19) when sw(2 downto 0) = "100" else
                     m_axis_data_tpower(25 downto 18) when sw(2 downto 0) = "101" else
                     m_axis_data_tpower(24 downto 17) when sw(2 downto 0) = "110" else
                     m_axis_data_tpower(23 downto 16);-- when sw(2 downto 0) = "111" else
                       
--  debugm_axis_data_tbyte <= m_axis_data_tbyte; -- debug                         

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
FftInst: xfft_1
  PORT MAP (
    aclk => ckFft,
    aresetn => aresetn,
    s_axis_config_tdata => s_axis_config_tdata,
    s_axis_config_tvalid => s_axis_config_tvalid,
    s_axis_config_tready => s_axis_config_tready,
    s_axis_data_tdata => s_axis_data_tdata,
    s_axis_data_tvalid => s_axis_data_tvalid,
    s_axis_data_tready => s_axis_data_tready,
    s_axis_data_tlast => s_axis_data_tlast,
    m_axis_data_tdata => m_axis_data_tdata,
    m_axis_data_tvalid => flgFreqSampleValid,
    m_axis_data_tready => m_axis_data_tready,
    m_axis_data_tlast => m_axis_data_tlast,
    event_frame_started => event_frame_started,
    event_tlast_unexpected => event_tlast_unexpected,
    event_tlast_missing => event_tlast_missing,
    event_status_channel_halt => event_status_channel_halt,
    event_data_in_channel_halt => event_data_in_channel_halt,
    event_data_out_channel_halt => event_data_out_channel_halt
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

end Behavioral;
