
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.DisplayDefinition.all;  -- VGA timing constants

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TopNexys4Spectral is
    Port ( ck100MHz : in STD_LOGIC;
    -- microphone signals
           micData : in STD_LOGIC;
           micClk: inout STD_LOGIC;  -- microphone clk (3.072MHz)  -- provizoriu inout, in fact out
           micLRSel: out STD_LOGIC;  -- microphone sel (0 for micClk rising edge)
    -- VGA signals
           vgaRed : out  STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out  STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out  STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out  STD_LOGIC;
           Vsync : out  STD_LOGIC;
    -- PWM interface with the audio out
           pdm_data_o  : out std_logic;
           pdm_en_o    : out std_logic;
   -- led string signal
           bitDataNrz : out  std_logic;  -- serial data for the LED string 
   -- on-board LEDs
--           led : out std_logic_vector(15 downto 0);  -- not used
   -- debug  
           sw: in std_logic_vector(15 downto 0) -- debug for selecting  output data byte (sensitivity) (sw2:0) 
           );
end TopNexys4Spectral;

architecture Behavioral of TopNexys4Spectral is

   signal wordTimeSample: std_logic_vector(15 downto 0); -- from audio_demo data_mic
                                           -- to dina of the Time buffer 
   signal flgTimeSampleValid: std_logic;   -- from audio_demo sample data_mic_valid
                                           -- to wea of the Time buffer
   signal flgTimeFrameActive: std_logic;   -- from FFT_Block time address counter 
                                           -- to ena of the Time buffer
   signal addraTime: std_logic_vector(11 downto 0); -- from FFT_Block time address counter 
                                           -- to addra of time buffer

   signal byteFreqSample: std_logic_vector(7 downto 0); -- from FftBlock data_mic
                                           -- to dina of the Time buffer 
   signal flgFreqSampleValid: std_logic;   -- from FftBlock sample flgFreqSampleValid
                                           -- to wea of the frequency buffer
   signal addraFreq: std_logic_vector(11 downto 0); -- from FFT_Block frequency address counter 
                                           -- to addra of frequency buffer
-- video signals
  signal ck25MHz: std_logic;  -- Video clock
  signal flgActiveVideo: std_logic;
  signal adrHor: integer range 0 to cstHorSize - 1; -- pixel counter
  signal adrVer: integer range 0 to cstVerSize - 1; -- lines counter

-- StartTiemAcquisition
   signal flgStartAcquisition: STD_LOGIC;  -- StartTimeAcq 10Hz
   constant cstDivPresc: integer := 10000000; -- divide 100MHz downto 10Hz
   signal cntPresc: integer range 0 to cstDivPresc-1;

component audio_demo is
   port(
   clk_i       : in  std_logic;
   rst_i       : in  std_logic;
   
   -- PDM interface with the MIC
   pdm_clk_o   : out std_logic;
   pdm_lrsel_o : out std_logic;
   pdm_data_i  : in  std_logic;
   
   -- parallel data from mic
   data_mic_valid : out std_logic;  -- 48MHz data enable
   data_mic       : out std_logic_vector(15 downto 0);  -- data from pdm decoder
  
   -- PWM interface with the audio out
   pdm_data_o  : out std_logic;
   pdm_en_o    : out std_logic
);
end component;

    component clk_wiz_0
    port
        (-- Clock in ports
        ck100MHz    : in    std_logic;
        -- Clock out ports
        ck4800kHz   : out   std_logic;
        ck25MHz     : out   std_logic;
        -- Status and control signals
        reset       : in    std_logic;
        locked      : out   std_logic
        );
    end component;

ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF clk_wiz_0 : COMPONENT IS TRUE;


ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF clk_wiz_0 : COMPONENT IS "ck100MHz,ck4800kHz,ck25MHz,reset,locked";

	COMPONENT VgaCtrl
	PORT(
		ckVideo : IN std_logic;          
		adrHor : OUT integer range 0 to cstHorSize - 1; -- pixel counter;
		adrVer : OUT integer range 0 to cstVerSize - 1; -- lines counter;
		flgActiveVideo : OUT std_logic;
		HS : OUT std_logic;
		VS : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ImgCtrl
    Port ( ck100MHz : in STD_LOGIC;
     -- time domain data signals       
        enaTime : in STD_LOGIC;
        weaTime : in STD_LOGIC;
        addraTime : in STD_LOGIC_VECTOR (11 downto 0);
        dinaTime : in STD_LOGIC_VECTOR (7 downto 0);
     -- frequency domain data signals
--      enaFreq : in STD_LOGIC;
        weaFreq : in STD_LOGIC;
        addraFreq : in STD_LOGIC_VECTOR (11 downto 0);
        dinaFreq : in STD_LOGIC_VECTOR (7 downto 0);
     -- video signals
        ckVideo : in STD_LOGIC;
        flgActiveVideo: in std_logic;  -- active video flag
        adrHor: in integer range 0 to cstHorSize - 1; -- pixel counter
        adrVer: in integer range 0 to cstVerSize - 1; -- lines counter
        red : out  STD_LOGIC_VECTOR (3 downto 0);
        green : out  STD_LOGIC_VECTOR (3 downto 0);
        blue : out  STD_LOGIC_VECTOR (3 downto 0));
	END COMPONENT;
	
	component FftBlock
    Port ( 
        flgStartAcquisition : in std_logic;  -- resets the lad state machine
--        btnL: in STD_LOGIC;  -- debugResetLoadStateMachine
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
        );   
   end component;

begin

   prescaller: process(ck100MHz)  -- 10Hz flgStartAcquisition pulses,
                                     --将100MHz分频为10Hz，flgStartAcquisition为输出10Hz脉冲
   begin
      if rising_edge(ck100MHz) then
         if cntPresc = cstDivPresc - 1 then
            cntPresc <= 0;
            flgStartAcquisition <= '1';
         else
            cntPresc <= cntPresc +1;
            flgStartAcquisition <= '0';
         end if;
      end if;
   end process;         

clkGenInst: clk_wiz_0
      port map ( 
   
      -- Clock in ports
      ck100MHz => ck100MHz,
     -- Clock out ports  
      ck4800kHz => open,
      ck25MHz => ck25MHz,
     -- Status and control signals                
      reset => '0',
      locked => open            
    );

Audio_demo_inst: audio_demo
      port map ( 
         clk_i         => ck100MHz,
         rst_i         => '0',            -- never reset audio_demo
   -- PDM interface with the MIC
         pdm_clk_o     => micClk,        
         pdm_data_i    => micData,                
         pdm_lrsel_o   => micLRSel,                
   -- parallel data from mic
         data_mic_valid => flgTimeSampleValid,   -- 48MHz data enable
         data_mic      => wordTimeSample,  -- provizoriu
   -- PWM interface with the audio out
         pdm_data_o    => pdm_data_o,          
         pdm_en_o      => pdm_en_o
      );
   
--此处进行了修改
Inst_fftBlock: FftBlock Port Map(
      flgStartAcquisition => flgStartAcquisition,
      sw => "000",
--      sw => sw(2 downto 0),
      ckaTime => ck100MHz,  -- instead of ck100MHz
      enaTime => flgTimeFrameActive,
      weaTime => flgTimeSampleValid,
      addraTime => addraTime,
      dinaTime => wordTimeSample(10 downto 3),
      ckFreq => ck25MHz,
      flgFreqSampleValid => flgFreqSampleValid,
      addrFreq => addraFreq,
      byteFreqSample => byteFreqSample
   );

Inst_VgaCtrl: VgaCtrl PORT MAP(
		ckVideo => ck100MHz,
		adrHor => adrHor,
		adrVer => adrVer,
		flgActiveVideo => flgActiveVideo,
		HS => Hsync,
		VS => Vsync
	);

Inst_ImgCtrl: ImgCtrl PORT MAP(
        ck100MHz => ck100MHz,  -- instead of ck100MHz
     -- time domain data signals       
        enaTime => flgTimeFrameActive,
        weaTime => flgTimeSampleValid,
        addraTime => addraTime,
        dinaTime => wordTimeSample(10 downto 3),
     -- frequency domain data signals
--     ena => '1', -- always active 
        weaFreq => flgFreqSampleValid,  -- wea is std_logic_vector(0 downto 0) ...
        addraFreq => addraFreq,
        dinaFreq => byteFreqSample, -- selected byte!!!
     -- video signals
        ckVideo => ck100MHz,
        flgActiveVideo => flgActiveVideo,
        adrHor => adrHor,
        adrVer => adrVer,
        red => vgaRed,
        green => vgaGreen,
        blue => vgaBlue
	);

end Behavioral;
