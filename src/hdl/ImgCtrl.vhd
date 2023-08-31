
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

use work.DisplayDefinition.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ImgCtrl is
    Port ( ck100MHz : in STD_LOGIC;
     -- time domain data signals       
           enaTime : in STD_LOGIC;
           weaTime : in STD_LOGIC;
           addraTime : in STD_LOGIC_VECTOR (11 downto 0);
           dinaTime : in STD_LOGIC_VECTOR (7 downto 0);
     -- frequency domain data signals
--            enaFreq : in STD_LOGIC;
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
end ImgCtrl;

architecture Behavioral of ImgCtrl is



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

--COMPONENT dist_mem_gen_0
--  PORT (
--    addrom : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
--    r_data : OUT STD_LOGIC_VECTOR(1023 DOWNTO 0);
--  );
--END COMPONENT
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

  signal sampleDisplayTime: STD_LOGIC_VECTOR (7 downto 0);  -- time domain sample for display
  signal sampleDisplayFreq: STD_LOGIC_VECTOR (7 downto 0);  -- freq domain sample for display

  signal vecadrHor: std_logic_vector(11 downto 0); -- pixel counter (vector)
  signal vecadrVer: std_logic_vector(9 downto 0); -- lines counter (vector)
  
  signal addrom:std_logic_vector(13 downto 0);
  signal r_data:std_logic_vector(1023 downto 0);
  
  signal intRed: STD_LOGIC_VECTOR (3 downto 0); 
  signal intGreen: STD_LOGIC_VECTOR (3 downto 0); 
  signal intBlue: STD_LOGIC_VECTOR (3 downto 0); 
 
begin

   vecadrHor <= conv_std_logic_vector(0, 12) when adrHor = cstHorSize - 1 else
                conv_std_logic_vector(adrHor + 1, 12);  -- read in advance for compensating the synchronous BRAM delay 
   vecadrVer <= conv_std_logic_vector(adrVer, 10);

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
TimeBlkMemForDisplay: blk_mem_gen_0
  PORT MAP (
    clka => ck100MHz,
    ena => enaTime, -- active while counting
    wea(0) => weaTime,  -- wea is std_logic_vector(0 downto 0) ...
    addra => addraTime,
    dina => dinaTime,
    clkb => ckVideo,  -- Video clock 
    enb => '1',
    addrb => vecadrHor,      
    doutb => sampleDisplayTime
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
FreqBlkMemForDisplay: blk_mem_gen_0
  PORT MAP (
    clka => ck100MHz,
    ena => '1', -- always active 
    wea(0) => weaFreq,  -- wea is std_logic_vector(0 downto 0) ...
    addra => addraFreq,
    dina =>dinaFreq, -- selected byte!!!

    clkb => ckVideo,  -- Video clock 
    enb => '1',
--    addrb => ("000") & vecadrHor(9 downto 3), -- divide by 8. Display 1280/8 = 160 points. Point = 96Khz/512 = 187.5Hz
    addrb => vecadrHor,
    doutb => sampleDisplayFreq
  );
  
-- PictureForDisplay: dis_mem_gen_0
--   PORT MAP(
--     addrom =>addrom,
--    r_data =>r_data
--   );
-- INST_TAG_END ------ End INSTANTIATION Template ---------


  intRed <= "1111" when (adrVer = cstVerAf/4 - conv_integer(sampleDisplayTime) or adrVer = cstVerAf/4 - conv_integer(sampleDisplayTime)+1) and adrHor <= cstHorAl*1210/1280
         else "0000" when
                          -- time range (upper half of the VGA display)
                          adrVer = cstVerAf/4 and -- - conv_integer(sampleDisplayTime) and 
                          -- a marker every 48 time samples
                          ((adrHor = 1*96) or 
                           (adrHor = 2*96) or 
                           (adrHor = 3*96) or 
                           (adrHor = 4*96) or 
                           (adrHor = 5*96) or 
                           (adrHor = 6*96) or 
                           (adrHor = 7*96) or 
                           (adrHor = 8*96) or 
                           ((adrHor =  9*96) and 
                            (adrHor = 10*96)) or 
                           (adrHor = 11*96) or 
                           (adrHor = 12*96) )  
        else "1111" when adrVer = cstVerAf/4 and adrHor <= cstHorAl*1210/1280
        else "1111" when adrVer = cstVerAf*990/1024 and adrHor<=cstHorAl*1066/1280
        else "1111" when adrHor >= cstHorAl*1/1280 and adrHor <=cstHorAl*2/1280 and adrVer >= cstVerAf*16/1024 and adrVer <= cstVerAf*500/1024
        else "1111" when adrHor >= cstHorAl*1/1280 and adrHor <=cstHorAl*2/1280 and adrVer >= cstVerAf*526/1024 and adrVer <= cstVerAf*990/1024

        --此处为添加代码    
        else "1111" when (adrHor = cstHorAl*1210/1280 and adrVer >= cstVerAf/4-4 and adrVer <= cstVerAf/4+4) or (adrHor = cstHorAl*1066/1280 and adrVer >= cstVerAf*990/1024-4 and adrVer <= cstVerAf*990/1024+4)
        else "1111" when (adrHor = cstHorAl*1211/1280 and adrVer >= cstVerAf/4-3 and adrVer <= cstVerAf/4+3) or (adrHor = cstHorAl*1067/1280 and adrVer >= cstVerAf*990/1024-3 and adrVer <= cstVerAf*990/1024+3)
        else "1111" when (adrHor = cstHorAl*1212/1280 and adrVer >= cstVerAf/4-2 and adrVer <= cstVerAf/4+2) or (adrHor = cstHorAl*1068/1280 and adrVer >= cstVerAf*990/1024-2 and adrVer <= cstVerAf*990/1024+2)
        else "1111" when (adrHor = cstHorAl*1213/1280 and adrVer >= cstVerAf/4-1 and adrVer <= cstVerAf/4+1) or (adrHor = cstHorAl*1069/1280 and adrVer >= cstVerAf*990/1024-1 and adrVer <= cstVerAf*990/1024+1)
        else "1111" when (adrHor = cstHorAl*1214/1280 and adrVer >= cstVerAf/4 and adrVer <= cstVerAf/4) or (adrHor = cstHorAl*1070/1280 and adrVer >= cstVerAf*990/1024 and adrVer <= cstVerAf*990/1024)
        --上述为显示箭头
        else "1111" when (adrHor = cstHorAl*1210/1280 and adrVer >= cstVerAf/4+5 and adrVer <= cstVerAf/4+9)
        else "1111" when (adrVer = cstVerAf/4+7 and adrHor >= cstHorAl*1208/1280 and adrHor <= cstHorAl*1212/1280)
        else "1111" when (adrVer = cstVerAf/4+9 and adrHor >= cstHorAl*1210/1280 and adrHor <= cstHorAl*1212/1280)
        --上述为显示t
        else "1111" when (adrHor = cstHorAl*1071/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024) or (adrHor = cstHorAl*1076/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024) or (adrHor = cstHorAl*1080/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024)
        else "1111" when (adrVer = cstVerAf*995/1024 and adrHor >= cstHorAl*1076/1280 and adrHor <= cstHorAl*1081/1280) or (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*1081/1280 and adrHor <= cstHorAl*1086/1280) or (adrVer = cstVerAf*999/1024 and adrHor >= cstHorAl*1081/1280 and adrHor <= cstHorAl*1086/1280)
        else "1111" when (adrVer = cstVerAf*995/1024 and adrHor = cstHorAl*1072/1280) or ((adrVer = cstVerAf*994/1024 or adrVer = cstVerAf*996/1024)and adrHor = cstHorAl*1073/1280) or ((adrVer = cstVerAf*993/1024 or adrVer = cstVerAf*997/1024)and adrHor = cstHorAl*1074/1280) or ((adrVer = cstVerAf*992/1024 or adrVer = cstVerAf*999/1024)and adrHor = cstHorAl*1075/1280)
        else "1111" when (adrVer = cstVerAf*998/1024 and adrHor = cstHorAl*1081/1280) or (adrVer = cstVerAf*997/1024 and adrHor = cstHorAl*1082/1280) or (adrVer = cstVerAf*996/1024 and adrHor = cstHorAl*1083/1280) or (adrVer = cstVerAf*995/1024 and adrHor = cstHorAl*1084/1280) or 
        (adrVer = cstVerAf*994/1024 and adrHor = cstHorAl*1085/1280) or (adrVer = cstVerAf*993/1024 and adrHor = cstHorAl*1086/1280)
        --上述为显示kHz
        
        
        else "1111" when adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024 and adrHor = cstHorAl*85/1280 --显示1
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrHor = cstHorAl*173/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*170/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示2
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrHor = cstHorAl*258/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示3
        
        else "1111" when (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*340/1280 and adrHor <= cstHorAl*343/1280) or 
        (adrHor = cstHorAl*340/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*343/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024)--显示4
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrHor = cstHorAl*425/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*428/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示5
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrHor = cstHorAl*510/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*513/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示6
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*595/1280 and adrHor <= cstHorAl*598/1280) or 
        (adrHor = cstHorAl*598/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示7
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrHor = cstHorAl*680/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*683/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示8
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrHor = cstHorAl*765/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*768/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示9
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*852/1280 and adrHor <= cstHorAl*854/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*852/1280 and adrHor <= cstHorAl*854/1280) or 
        (adrHor = cstHorAl*850/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*852/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*854/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示10
        
        else "1111" when(adrHor = cstHorAl*935/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*938/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示11

        --此处为添加代码
        
        else "1111" when (adrVer>=520 and adrVer<=531 and adrHor= 4) or (adrVer>=521 and adrVer<=530 and adrHor=6) or (adrVer>=521 and adrVer<=530 and adrHor =10) or (adrVer=526 and adrHor>=7 and adrHor<=9) or (adrHor =13 and adrVer>=522 and adrVer <=529) or (adrVer=521 and adrHor =14) or (adrVer=529 and adrHor =14) or (adrVer=526 and adrHor>=15 and adrHor<=20) or (adrHor=17 and adrVer>=521 and adrVer<=529) or (adrVer=520 and adrHor >=18 and adrHor <=19)or (adrHor=20 and adrVer=521 ) or (adrVer=521 and adrHor=22) or (adrVer=529 and adrHor=22) or (adrHor=23 and adrVer>=522 and adrVer<=529) or (adrHor=25 and adrVer>=520 and adrVer<=530) 
--        else "1111" when (adrHor=1066 and adrVer>=1000 and adrVer<=1010) or (adrVer=1005 and adrHor>=1063 and adrHor<=1067) or (adrVer=999 and adrHor>=1067 and adrHor<=1068) or (adrVer=1000 and adrHor=1069) or (adrHor=1072 and adrVer>=999 and adrVer<=1011) or (adrHor=1085 and adrVer>=1000 and adrVer<=1009) or (adrHor =1090 and adrVer>=1000 and adrVer<=1009) or(adrVer=1005 and adrHor>=1086 and adrHor <=1089) or (adrVer=1004 and adrHor>=1093 and adrHor<=1098) or (adrVer=1010 and adrHor>=1093 and adrHor<=1098) or(adrHor=1094 and adrVer=1009)or (adrHor=1095 and adrVer=1008)or (adrHor=1095 and adrVer=1007) or (adrHor=1096 and adrVer>=1005 and adrVer<=1006)  or (adrHor=1076 and adrVer>=1000 and adrVer<=1010 ) or (adrVer=1005 and adrHor >= 1075 and adrHor <= 1080 ) or (adrHor =1080 and adrVer>=1005 and adrVer<=1007) or (adrVer=1007 and adrHor>=1075 and adrHor <=1080)or (adrHor=1076 and adrVer=1008)or (adrHor =1077 and adrVer=1009)or (adrHor =1078 and adrVer=1010)
--        else "1111" when (adrHor=53 and adrVer>=993 and adrVer<=1000) or (adrHor=160 and adrVer>=993 and adrVer<=1000) or (adrHor>=150 and adrHor<=160 and adrVer=993) or (adrHor>=150 and adrHor<=160 and adrVer=996) or(adrHor>=150 and adrHor<=160 and adrVer=1000) or (adrHor=107 and adrVer>=993 and adrVer<=995) or (adrVer=993 and adrHor>=100 and adrHor<=106) or(adrVer=995 and adrHor>=100 and adrHor<=106) or (adrVer=1000 and adrHor>=100 and adrHor<=106) or (adrHor=100 and adrVer>=995 and adrVer<=1000) or (adrHor =373 and adrVer>=993 and adrVer<=1000 ) or (adrVer=993 and adrHor>=369 and adrHor<=373 ) or (adrHor=587 and adrVer>=993 and adrVer<=1000) or (adrHor=590 and adrVer>=993 and adrVer<=1000) or (adrHor=907 and adrVer>=993 and adrVer<=1000) or (adrHor=917 and adrVer>=993 and adrVer<=1000)or (adrVer=993 and adrHor>=913 and adrHor<=916)
--        else "1111" when (adrVer=270 and adrHor>=1220 and adrHor<=1226) or (adrHor=1223 and adrVer>=267 and adrVer<=273) or (adrHor>=1223 and adrHor<=1226 and adrVer=273)
       else "1111" when ((adrVer=950 or adrVer=910 or adrVer=830 or adrVer=670 or adrVer=590 ) and adrHor>=1 and adrHor<=3) or (adrVer=910 and adrHor>=5 and adrHor<=7) or(adrVer=908 and adrHor>=5 and adrHor<=7)       or (adrVer=912 and adrHor >=5 and adrHor<=7) or (adrHor=7 and adrVer=909)        or(adrVer=911 and adrHor=5)         or (adrVer=908 and adrHor>=9 and adrHor<=11)   or(adrVer=912 and adrHor>=9 and adrHor<=11)    or (adrHor=9 and adrVer>=908 and adrVer<=912)   or (adrHor=11 and adrVer>=908 and adrVer<=912)   or(adrHor=7 and adrVer>=948 and adrVer<=952)   or (adrHor>=9 and adrHor<=11 and adrVer=952)   or (adrHor >=9 and adrHor<=11 and adrVer=948)  or (adrHor=9 and adrVer>=948 and adrVer<=952)  or (adrHor=11 and adrVer>=948 and adrVer<=952)  or(adrVer>=828 and adrVer<=832 and (adrHor =7 or adrHor =9 or adrHor =11))   or (adrHor =5 and adrVer>=828 and adrVer<=832) or(adrVer =830 and adrHor =6)   or ((adrVer=828 or adrVer=832) and adrHor =10)or (adrVer>=668 and adrVer<=672 and (adrHor=5 or adrHor =7 or adrHor =9 or adrHor=11))     or (adrHor=6 and (adrVer=668 or adrVer =670 or adrVer=672))            or (adrHor =10 and (adrVer=668 or adrVer=672))             or (adrVer>=588 and adrVer<=592 and (adrHor=7 or adrHor=9 or adrHor=11 or adrHor=13 or adrHor=15))             or(adrHor=10 and (adrVer=588 or adrVer=592)) or (adrHor=14 and (adrVer=588 or adrVer=592))----10 20 40 80 100
--          else "1111" when (adrHor=213 and adrVer>=993 and adrVer<=1000) or (adrVer=993 and adrHor<=213 and adrHor>=209) or (adrHor = 209 and adrVer<=993 and adrVer>=996) or (adrHor>=263 and adrHor <=267 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor =263 and adrVer>=993 and adrVer<=996) or(adrHor =267 and adrVer>=996 and adrVer<=1000)or (adrHor=320 and adrVer>=993 and adrVer<=1000) or (adrHor=324 and adrVer>=996 and adrVer<=1000) or (adrHor>=320 and adrHor <=324 and (adrVer =993 or adrVer=996 or adrVer =1000)) or (adrVer>=993 and adrVer<=1000 and (adrHor =426 or adrHor =430)) or (adrHor>=426 and adrHor<=430 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor>=480 and adrHor<=485 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=480 and adrVer>=993 and adrVer<=996) or (adrVer>=993 and adrVer<=1000 and adrHor =485) or (adrVer>=993 and adrVer<=1000 and (adrHor=531 or adrHor=535 or adrHor=539)) or (adrHor>=535 and adrHor<=539 and (adrVer=993 or adrVer=1000)) or (adrHor=638 and adrVer>=993 and adrVer<=1000) or (adrHor>=642 and adrHor<=646 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=642 and adrVer>=996 and adrVer<=1000) or(adrHor =646 and adrVer>=993 and adrVer<=996)--4 5 6 8 9 10 12 
--              else "1111"when ((adrHor=691 or adrHor=697) and adrVer>=993 and adrVer<=1000) or(adrHor>=693 and adrHor<=697 and (adrVer=993 or adrVer=996 or adrVer=1000)) or  (adrVer>=993 and adrVer<=1000 and (adrHor=743 or adrHor=749)) or(adrHor=745 and adrVer>=993 and adrVer<=996) or (adrVer=996 and adrHor>=745 and adrHor<=749) or (adrHor=797 and adrVer>=993 and adrVer<=1000) or (adrHor>=799 and adrHor<=803 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=799 and adrVer>=993 and adrVer<=996 ) or(adrHor=803 and adrVer>=996 and adrVer<=1000) or ((adrHor=850 or adrHor=852)and adrVer>=993 and adrVer<=1000) or((adrVer=993 or adrVer=996 or adrVer=1000) and adrHor>=852 and adrHor<=856) or(adrHor=856 and adrVer>=996 and adrVer<=1000) or((adrHor=957 or adrHor=959 or adrHor=963)and adrVer>=993 and adrVer<=1000) or(adrHor>=959 and adrHor<=963 and (adrVer=993 or adrVer=996 or adrVer=1000)) or((adrHor=1010 or adrHor=1016) and adrVer>=993 and adrVer<=1000) or (adrHor>=1012 and adrHor<=1016 and (adrVer=993 or adrVer=993 or adrVer=1000)) or (adrHor=1012 and adrVer>=993 and adrVer<=996) or ((adrHor=1058 or adrHor=1062)and adrVer>=993 and adrVer<=1000) or(adrHor>=1058 and adrHor<=1062 and (adrVer=993 or adrVer=1000)) or (adrHor>=1052 and adrHor<=1056 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=1056 and adrVer>=993 and adrVer<=996) or(adrHor=1052 and adrVer>=996 and adrVer<=1000) ---13 14 15 16 18 19 20  
--               else "1111" when (adrVer>=590 and adrVer<=930 and adrHor>=1 and adrHor<=3 and (adrVer MOD 4 =0))
        else "0000";
  intGreen <= "1111" when --adrVer >= cstVerAf/2 and 
--                (((adrHor +3) MOD 8 = 0) or ((adrHor + 4) MOD 8 =0) or ((adrHor + 5) MOD 8 =0)) and 
--                adrVer >= cstVerAf*990/1024 - 3*conv_integer("0" & sampleDisplayFreq(7) & sampleDisplayFreq(6 downto 0))  and adrVer <= cstVerAf*991/1024 and adrHor<=cstHorAl*1013/1280
                adrVer >= cstVerAf*990/1024 - 3*conv_integer("0" & sampleDisplayFreq(7) & sampleDisplayFreq(6 downto 0))  and adrVer <= cstVerAf*991/1024 and adrHor<=cstHorAl*1013/1280
 
 
          else "1111" when (adrVer = cstVerAf/4 - conv_integer(sampleDisplayTime) or adrVer = cstVerAf/4 - conv_integer(sampleDisplayTime)+1) and adrHor <= cstHorAl*1210/1280
           else "0000" when
                         -- time range (upper half of the VGA display)
                         adrVer = cstVerAf/4 and -- - conv_integer(sampleDisplayTime) and 
                         -- a marker every 48 time samples
                         ((adrHor = 1*96) or 
                          (adrHor = 2*96) or 
                          (adrHor = 3*96) or 
                          (adrHor = 4*96) or 
                          (adrHor = 5*96) or 
                          (adrHor = 6*96) or 
                          (adrHor = 7*96) or 
                          (adrHor = 8*96) or 
                          ((adrHor =  9*96) and 
                           (adrHor = 10*96)) or 
                          (adrHor = 11*96) or 
                          (adrHor = 12*96) )  
          else "1111" when adrVer = cstVerAf/4 and adrHor <= cstHorAl*1210/1280
          else "1111" when adrVer = cstVerAf*990/1024 and adrHor<=cstHorAl*1066/1280
          else "1111" when adrHor >= cstHorAl*1/1280 and adrHor <=cstHorAl*2/1280 and adrVer >= cstVerAf*16/1024 and adrVer <= cstVerAf*500/1024
          else "1111" when adrHor >= cstHorAl*1/1280 and adrHor <=cstHorAl*2/1280 and adrVer >= cstVerAf*526/1024 and adrVer <= cstVerAf*990/1024
          --此处为添加代码
        else "1111" when (adrHor = cstHorAl*1210/1280 and adrVer >= cstVerAf/4-4 and adrVer <= cstVerAf/4+4) or (adrHor = cstHorAl*1066/1280 and adrVer >= cstVerAf*990/1024-4 and adrVer <= cstVerAf*990/1024+4)
        else "1111" when (adrHor = cstHorAl*1211/1280 and adrVer >= cstVerAf/4-3 and adrVer <= cstVerAf/4+3) or (adrHor = cstHorAl*1067/1280 and adrVer >= cstVerAf*990/1024-3 and adrVer <= cstVerAf*990/1024+3)
        else "1111" when (adrHor = cstHorAl*1212/1280 and adrVer >= cstVerAf/4-2 and adrVer <= cstVerAf/4+2) or (adrHor = cstHorAl*1068/1280 and adrVer >= cstVerAf*990/1024-2 and adrVer <= cstVerAf*990/1024+2)
        else "1111" when (adrHor = cstHorAl*1213/1280 and adrVer >= cstVerAf/4-1 and adrVer <= cstVerAf/4+1) or (adrHor = cstHorAl*1069/1280 and adrVer >= cstVerAf*990/1024-1 and adrVer <= cstVerAf*990/1024+1)
        else "1111" when (adrHor = cstHorAl*1214/1280 and adrVer >= cstVerAf/4 and adrVer <= cstVerAf/4) or (adrHor = cstHorAl*1070/1280 and adrVer >= cstVerAf*990/1024 and adrVer <= cstVerAf*990/1024)
        --上述为显示箭头
        else "1111" when (adrHor = cstHorAl*1210/1280 and adrVer >= cstVerAf/4+5 and adrVer <= cstVerAf/4+9)
        else "1111" when (adrVer = cstVerAf/4+7 and adrHor >= cstHorAl*1208/1280 and adrHor <= cstHorAl*1212/1280)
        else "1111" when (adrVer = cstVerAf/4+9 and adrHor >= cstHorAl*1210/1280 and adrHor <= cstHorAl*1212/1280)
        --上述为显示t
        else "1111" when (adrHor = cstHorAl*1071/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024) or (adrHor = cstHorAl*1076/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024) or (adrHor = cstHorAl*1080/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024)
        else "1111" when (adrVer = cstVerAf*995/1024 and adrHor >= cstHorAl*1076/1280 and adrHor <= cstHorAl*1081/1280) or (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*1081/1280 and adrHor <= cstHorAl*1086/1280) or (adrVer = cstVerAf*999/1024 and adrHor >= cstHorAl*1081/1280 and adrHor <= cstHorAl*1086/1280)
        else "1111" when (adrVer = cstVerAf*995/1024 and adrHor = cstHorAl*1072/1280) or ((adrVer = cstVerAf*994/1024 or adrVer = cstVerAf*996/1024)and adrHor = cstHorAl*1073/1280) or ((adrVer = cstVerAf*993/1024 or adrVer = cstVerAf*997/1024)and adrHor = cstHorAl*1074/1280) or ((adrVer = cstVerAf*992/1024 or adrVer = cstVerAf*999/1024)and adrHor = cstHorAl*1075/1280)
        else "1111" when (adrVer = cstVerAf*998/1024 and adrHor = cstHorAl*1081/1280) or (adrVer = cstVerAf*997/1024 and adrHor = cstHorAl*1082/1280) or (adrVer = cstVerAf*996/1024 and adrHor = cstHorAl*1083/1280) or (adrVer = cstVerAf*995/1024 and adrHor = cstHorAl*1084/1280) or 
        (adrVer = cstVerAf*994/1024 and adrHor = cstHorAl*1085/1280) or (adrVer = cstVerAf*993/1024 and adrHor = cstHorAl*1086/1280)
        --上述为显示kHz
               
        
        else "1111" when adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024 and adrHor = cstHorAl*85/1280 --显示1
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrHor = cstHorAl*173/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*170/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示2
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrHor = cstHorAl*258/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示3
        
        else "1111" when (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*340/1280 and adrHor <= cstHorAl*343/1280) or 
        (adrHor = cstHorAl*340/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*343/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024)--显示4
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrHor = cstHorAl*425/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*428/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示5
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrHor = cstHorAl*510/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*513/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示6
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*595/1280 and adrHor <= cstHorAl*598/1280) or 
        (adrHor = cstHorAl*598/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示7
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrHor = cstHorAl*680/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*683/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示8
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrHor = cstHorAl*765/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*768/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示9
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*852/1280 and adrHor <= cstHorAl*854/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*852/1280 and adrHor <= cstHorAl*854/1280) or 
        (adrHor = cstHorAl*850/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*852/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*854/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示10
        
        else "1111" when(adrHor = cstHorAl*935/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*938/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示11
        --此处为添加代码
            
           else "1111" when (adrVer>=520 and adrVer<=531 and adrHor= 4) or (adrVer>=521 and adrVer<=530 and adrHor=6) or (adrVer>=521 and adrVer<=530 and adrHor =10) or (adrVer=526 and adrHor>=7 and adrHor<=9) or (adrHor =13 and adrVer>=522 and adrVer <=529) or (adrVer=521 and adrHor =14) or (adrVer=529 and adrHor =14) or (adrVer=526 and adrHor>=15 and adrHor<=20) or (adrHor=17 and adrVer>=521 and adrVer<=529) or (adrVer=520 and adrHor >=18 and adrHor <=19)or (adrHor=20 and adrVer=521 ) or (adrVer=521 and adrHor=22) or (adrVer=529 and adrHor=22) or (adrHor=23 and adrVer>=522 and adrVer<=529) or (adrHor=25 and adrVer>=520 and adrVer<=530) 
--        else "1111" when (adrHor=1066 and adrVer>=1000 and adrVer<=1010) or (adrVer=1005 and adrHor>=1063 and adrHor<=1067) or (adrVer=999 and adrHor>=1067 and adrHor<=1068) or (adrVer=1000 and adrHor=1069) or (adrHor=1072 and adrVer>=999 and adrVer<=1011) or (adrHor=1085 and adrVer>=1000 and adrVer<=1009) or (adrHor =1090 and adrVer>=1000 and adrVer<=1009) or(adrVer=1005 and adrHor>=1086 and adrHor <=1089) or (adrVer=1004 and adrHor>=1093 and adrHor<=1098) or (adrVer=1010 and adrHor>=1093 and adrHor<=1098) or(adrHor=1094 and adrVer=1009)or (adrHor=1095 and adrVer=1008)or (adrHor=1095 and adrVer=1007) or (adrHor=1096 and adrVer>=1005 and adrVer<=1006)  or (adrHor=1076 and adrVer>=1000 and adrVer<=1010 ) or (adrVer=1005 and adrHor >= 1075 and adrHor <= 1080 ) or (adrHor =1080 and adrVer>=1005 and adrVer<=1007) or (adrVer=1007 and adrHor>=1075 and adrHor <=1080)or (adrHor=1076 and adrVer=1008)or (adrHor =1077 and adrVer=1009)or (adrHor =1078 and adrVer=1010)
--        else "1111" when (adrHor=53 and adrVer>=993 and adrVer<=1000) or (adrHor=160 and adrVer>=993 and adrVer<=1000) or (adrHor>=150 and adrHor<=160 and adrVer=993) or (adrHor>=150 and adrHor<=160 and adrVer=996) or(adrHor>=150 and adrHor<=160 and adrVer=1000) or (adrHor=107 and adrVer>=993 and adrVer<=995) or (adrVer=993 and adrHor>=100 and adrHor<=106) or(adrVer=995 and adrHor>=100 and adrHor<=106) or (adrVer=1000 and adrHor>=100 and adrHor<=106) or (adrHor=100 and adrVer>=995 and adrVer<=1000) or (adrHor =373 and adrVer>=993 and adrVer<=1000 ) or (adrVer=993 and adrHor>=369 and adrHor<=373 ) or (adrHor=587 and adrVer>=993 and adrVer<=1000) or (adrHor=590 and adrVer>=993 and adrVer<=1000) or (adrHor=907 and adrVer>=993 and adrVer<=1000) or (adrHor=917 and adrVer>=993 and adrVer<=1000)or (adrVer=993 and adrHor>=913 and adrHor<=916)
--          else "1111" when (adrVer=270 and adrHor>=1220 and adrHor<=1226) or (adrHor=1223 and adrVer>=267 and adrVer<=273) or (adrHor>=1223 and adrHor<=1226 and adrVer=273)
       else "1111" when ((adrVer=950 or adrVer=910 or adrVer=830 or adrVer=670 or adrVer=590 ) and adrHor>=1 and adrHor<=3) or (adrVer=910 and adrHor>=5 and adrHor<=7) or(adrVer=908 and adrHor>=5 and adrHor<=7)       or (adrVer=912 and adrHor >=5 and adrHor<=7) or (adrHor=7 and adrVer=909)        or(adrVer=911 and adrHor=5)         or (adrVer=908 and adrHor>=9 and adrHor<=11)   or(adrVer=912 and adrHor>=9 and adrHor<=11)    or (adrHor=9 and adrVer>=908 and adrVer<=912)   or (adrHor=11 and adrVer>=908 and adrVer<=912)   or(adrHor=7 and adrVer>=948 and adrVer<=952)   or (adrHor>=9 and adrHor<=11 and adrVer=952)   or (adrHor >=9 and adrHor<=11 and adrVer=948)  or (adrHor=9 and adrVer>=948 and adrVer<=952)  or (adrHor=11 and adrVer>=948 and adrVer<=952)  or(adrVer>=828 and adrVer<=832 and (adrHor =7 or adrHor =9 or adrHor =11))   or (adrHor =5 and adrVer>=828 and adrVer<=832) or(adrVer =830 and adrHor =6)   or ((adrVer=828 or adrVer=832) and adrHor =10)or (adrVer>=668 and adrVer<=672 and (adrHor=5 or adrHor =7 or adrHor =9 or adrHor=11))     or (adrHor=6 and (adrVer=668 or adrVer =670 or adrVer=672))            or (adrHor =10 and (adrVer=668 or adrVer=672))             or (adrVer>=588 and adrVer<=592 and (adrHor=7 or adrHor=9 or adrHor=11 or adrHor=13 or adrHor=15))             or(adrHor=10 and (adrVer=588 or adrVer=592)) or (adrHor=14 and (adrVer=588 or adrVer=592))----10 20 40 80 100
--          else "1111" when (adrHor=213 and adrVer>=993 and adrVer<=1000) or (adrVer=993 and adrHor<=213 and adrHor>=209) or (adrHor = 209 and adrVer<=993 and adrVer>=996) or (adrHor>=263 and adrHor <=267 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor =263 and adrVer>=993 and adrVer<=996) or(adrHor =267 and adrVer>=996 and adrVer<=1000)or (adrHor=320 and adrVer>=993 and adrVer<=1000) or (adrHor=324 and adrVer>=996 and adrVer<=1000) or (adrHor>=320 and adrHor <=324 and (adrVer =993 or adrVer=996 or adrVer =1000)) or (adrVer>=993 and adrVer<=1000 and (adrHor =426 or adrHor =430)) or (adrHor>=426 and adrHor<=430 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor>=480 and adrHor<=485 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=480 and adrVer>=993 and adrVer<=996) or (adrVer>=993 and adrVer<=1000 and adrHor =485) or (adrVer>=993 and adrVer<=1000 and (adrHor=531 or adrHor=535 or adrHor=539)) or (adrHor>=535 and adrHor<=539 and (adrVer=993 or adrVer=1000)) or (adrHor=638 and adrVer>=993 and adrVer<=1000) or (adrHor>=642 and adrHor<=646 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=642 and adrVer>=996 and adrVer<=1000) or(adrHor =646 and adrVer>=993 and adrVer<=996)--4 5 6 8 9 10 12 
--              else "1111"when ((adrHor=691 or adrHor=697) and adrVer>=993 and adrVer<=1000) or(adrHor>=693 and adrHor<=697 and (adrVer=993 or adrVer=996 or adrVer=1000)) or  (adrVer>=993 and adrVer<=1000 and (adrHor=743 or adrHor=749)) or(adrHor=745 and adrVer>=993 and adrVer<=996) or (adrVer=996 and adrHor>=745 and adrHor<=749) or (adrHor=797 and adrVer>=993 and adrVer<=1000) or (adrHor>=799 and adrHor<=803 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=799 and adrVer>=993 and adrVer<=996 ) or(adrHor=803 and adrVer>=996 and adrVer<=1000) or ((adrHor=850 or adrHor=852)and adrVer>=993 and adrVer<=1000) or((adrVer=993 or adrVer=996 or adrVer=1000) and adrHor>=852 and adrHor<=856) or(adrHor=856 and adrVer>=996 and adrVer<=1000) or((adrHor=957 or adrHor=959 or adrHor=963)and adrVer>=993 and adrVer<=1000) or(adrHor>=959 and adrHor<=963 and (adrVer=993 or adrVer=996 or adrVer=1000)) or((adrHor=1010 or adrHor=1016) and adrVer>=993 and adrVer<=1000) or (adrHor>=1012 and adrHor<=1016 and (adrVer=993 or adrVer=993 or adrVer=1000)) or (adrHor=1012 and adrVer>=993 and adrVer<=996) or ((adrHor=1058 or adrHor=1062)and adrVer>=993 and adrVer<=1000) or(adrHor>=1058 and adrHor<=1062 and (adrVer=993 or adrVer=1000)) or (adrHor>=1052 and adrHor<=1056 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=1056 and adrVer>=993 and adrVer<=996) or(adrHor=1052 and adrVer>=996 and adrVer<=1000) ---13 14 15 16 18 19 20 
--               else "1111" when (adrVer>=590 and adrVer<=930 and adrHor>=1 and adrHor<=3 and (adrVer MOD 4 =0)) 
          else "0000";
  intBlue <= "1111" when --adrVer >= cstVerAf/2 and 
                -- frequency range (lower half of the VGA display)
--                (((adrHor +3) MOD 8 = 0) or ((adrHor + 4) MOD 8 =0) or ((adrHor + 5) MOD 8 =0)) and 
                adrVer >= cstVerAf*990/1024 - 3*conv_integer("0" & sampleDisplayFreq(7) & sampleDisplayFreq(6 downto 0)) and adrVer <= cstVerAf*991/1024 and adrHor<=cstHorAl*1013/1280 --and

                -- a frequency marker every 10 bins 
--                (adrHor/16 = 0 or adrHor/16 = 10 or adrHor/16 = 20 or adrHor/16 = 30 or adrHor/16 = 40 or adrHor/16 = 50 or adrHor/16 = 60 or adrHor/16 = 70 )
        else "1111"    when (adrVer = cstVerAf/4 - conv_integer(sampleDisplayTime) or adrVer = cstVerAf/4 - conv_integer(sampleDisplayTime)+1) and adrHor <= cstHorAl*1210/1280
        else "1111" when adrVer = cstVerAf/4 and adrHor <= cstHorAl*1210/1280
        else "1111" when adrVer = cstVerAf*990/1024 and adrHor<=cstHorAl*1066/1280
        else "1111" when adrHor >= cstHorAl*1/1280 and adrHor <=cstHorAl*2/1280 and adrVer >= cstVerAf*16/1024 and adrVer <= cstVerAf*500/1024
        else "1111" when adrHor >= cstHorAl*1/1280 and adrHor <=cstHorAl*2/1280 and adrVer >= cstVerAf*526/1024 and adrVer <= cstVerAf*990/1024        
        else "1111" when
                -- time range (upper half of the VGA display)
                adrVer = cstVerAf/4 and -- - conv_integer(sampleDisplayTime) and 
                -- a marker every 48 time samples
                ((adrHor = 1*96) or 
                 (adrHor = 2*96) or 
                 (adrHor = 3*96) or 
                 (adrHor = 4*96) or 
                 (adrHor = 5*96) or 
                 (adrHor = 6*96) or 
                 (adrHor = 7*96) or 
                 (adrHor = 8*96) or 
                 ((adrHor =  9*96) and 
                  (adrHor = 10*96)) or 
                 (adrHor = 11*96) or 
                 (adrHor = 12*96) )  
           --此处为添加代码    
        else "1111" when (adrHor = cstHorAl*1210/1280 and adrVer >= cstVerAf/4-4 and adrVer <= cstVerAf/4+4) or (adrHor = cstHorAl*1066/1280 and adrVer >= cstVerAf*990/1024-4 and adrVer <= cstVerAf*990/1024+4)
        else "1111" when (adrHor = cstHorAl*1211/1280 and adrVer >= cstVerAf/4-3 and adrVer <= cstVerAf/4+3) or (adrHor = cstHorAl*1067/1280 and adrVer >= cstVerAf*990/1024-3 and adrVer <= cstVerAf*990/1024+3)
        else "1111" when (adrHor = cstHorAl*1212/1280 and adrVer >= cstVerAf/4-2 and adrVer <= cstVerAf/4+2) or (adrHor = cstHorAl*1068/1280 and adrVer >= cstVerAf*990/1024-2 and adrVer <= cstVerAf*990/1024+2)
        else "1111" when (adrHor = cstHorAl*1213/1280 and adrVer >= cstVerAf/4-1 and adrVer <= cstVerAf/4+1) or (adrHor = cstHorAl*1069/1280 and adrVer >= cstVerAf*990/1024-1 and adrVer <= cstVerAf*990/1024+1)
        else "1111" when (adrHor = cstHorAl*1214/1280 and adrVer >= cstVerAf/4 and adrVer <= cstVerAf/4) or (adrHor = cstHorAl*1070/1280 and adrVer >= cstVerAf*990/1024 and adrVer <= cstVerAf*990/1024)
        --上述为显示箭头
        else "1111" when (adrHor = cstHorAl*1210/1280 and adrVer >= cstVerAf/4+5 and adrVer <= cstVerAf/4+9)
        else "1111" when (adrVer = cstVerAf/4+7 and adrHor >= cstHorAl*1208/1280 and adrHor <= cstHorAl*1212/1280)
        else "1111" when (adrVer = cstVerAf/4+9 and adrHor >= cstHorAl*1210/1280 and adrHor <= cstHorAl*1212/1280)
        --上述为显示t
        else "1111" when (adrHor = cstHorAl*1071/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024) or (adrHor = cstHorAl*1076/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024) or (adrHor = cstHorAl*1080/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*999/1024)
        else "1111" when (adrVer = cstVerAf*995/1024 and adrHor >= cstHorAl*1076/1280 and adrHor <= cstHorAl*1081/1280) or (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*1081/1280 and adrHor <= cstHorAl*1086/1280) or (adrVer = cstVerAf*999/1024 and adrHor >= cstHorAl*1081/1280 and adrHor <= cstHorAl*1086/1280)
        else "1111" when (adrVer = cstVerAf*995/1024 and adrHor = cstHorAl*1072/1280) or ((adrVer = cstVerAf*994/1024 or adrVer = cstVerAf*996/1024)and adrHor = cstHorAl*1073/1280) or ((adrVer = cstVerAf*993/1024 or adrVer = cstVerAf*997/1024)and adrHor = cstHorAl*1074/1280) or ((adrVer = cstVerAf*992/1024 or adrVer = cstVerAf*999/1024)and adrHor = cstHorAl*1075/1280)
        else "1111" when (adrVer = cstVerAf*998/1024 and adrHor = cstHorAl*1081/1280) or (adrVer = cstVerAf*997/1024 and adrHor = cstHorAl*1082/1280) or (adrVer = cstVerAf*996/1024 and adrHor = cstHorAl*1083/1280) or (adrVer = cstVerAf*995/1024 and adrHor = cstHorAl*1084/1280) or 
        (adrVer = cstVerAf*994/1024 and adrHor = cstHorAl*1085/1280) or (adrVer = cstVerAf*993/1024 and adrHor = cstHorAl*1086/1280)
        --上述为显示kHz
            
        
        else "1111" when adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024 and adrHor = cstHorAl*85/1280 --显示1
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*170/1280 and adrHor <= cstHorAl*173/1280) or 
        (adrHor = cstHorAl*173/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*170/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示2
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*255/1280 and adrHor <= cstHorAl*258/1280) or 
        (adrHor = cstHorAl*258/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示3
        
        else "1111" when (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*340/1280 and adrHor <= cstHorAl*343/1280) or 
        (adrHor = cstHorAl*340/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*343/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024)--显示4
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*425/1280 and adrHor <= cstHorAl*428/1280) or 
        (adrHor = cstHorAl*425/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*428/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示5
        
        else "1111" when (adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*510/1280 and adrHor <= cstHorAl*513/1280) or 
        (adrHor = cstHorAl*510/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*513/1280 and adrVer >= cstVerAf*996/1024 and adrVer <= cstVerAf*1000/1024) --显示6
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*595/1280 and adrHor <= cstHorAl*598/1280) or 
        (adrHor = cstHorAl*598/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示7
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*680/1280 and adrHor <= cstHorAl*683/1280) or 
        (adrHor = cstHorAl*680/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*683/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示8
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrVer = cstVerAf*996/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*765/1280 and adrHor <= cstHorAl*768/1280) or 
        (adrHor = cstHorAl*765/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*996/1024) or 
        (adrHor = cstHorAl*768/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示9
        
        else "1111" when(adrVer = cstVerAf*992/1024 and adrHor >= cstHorAl*852/1280 and adrHor <= cstHorAl*854/1280) or 
        (adrVer = cstVerAf*1000/1024 and adrHor >= cstHorAl*852/1280 and adrHor <= cstHorAl*854/1280) or 
        (adrHor = cstHorAl*850/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*852/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*854/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示10
        
        else "1111" when(adrHor = cstHorAl*935/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) or 
        (adrHor = cstHorAl*938/1280 and adrVer >= cstVerAf*992/1024 and adrVer <= cstVerAf*1000/1024) --显示11
        --此处为添加代码
         else "1111" when (adrVer>=520 and adrVer<=531 and adrHor= 4) or (adrVer>=521 and adrVer<=530 and adrHor=6) or (adrVer>=521 and adrVer<=530 and adrHor =10) or (adrVer=526 and adrHor>=7 and adrHor<=9) or (adrHor =13 and adrVer>=522 and adrVer <=529) or (adrVer=521 and adrHor =14) or (adrVer=529 and adrHor =14) or (adrVer=526 and adrHor>=15 and adrHor<=20) or (adrHor=17 and adrVer>=521 and adrVer<=529) or (adrVer=520 and adrHor >=18 and adrHor <=19)or (adrHor=20 and adrVer=521 ) or (adrVer=521 and adrHor=22) or (adrVer=529 and adrHor=22) or (adrHor=23 and adrVer>=522 and adrVer<=529) or (adrHor=25 and adrVer>=520 and adrVer<=530)    
--        else "1111" when (adrHor=1066 and adrVer>=1000 and adrVer<=1010) or (adrVer=1005 and adrHor>=1063 and adrHor<=1067) or (adrVer=999 and adrHor>=1067 and adrHor<=1068) or (adrVer=1000 and adrHor=1069) or (adrHor=1072 and adrVer>=999 and adrVer<=1011) or (adrHor=1085 and adrVer>=1000 and adrVer<=1009) or (adrHor =1090 and adrVer>=1000 and adrVer<=1009) or(adrVer=1005 and adrHor>=1086 and adrHor <=1089) or (adrVer=1004 and adrHor>=1093 and adrHor<=1098) or (adrVer=1010 and adrHor>=1093 and adrHor<=1098) or(adrHor=1094 and adrVer=1009)or (adrHor=1095 and adrVer=1008)or (adrHor=1095 and adrVer=1007) or (adrHor=1096 and adrVer>=1005 and adrVer<=1006)  or (adrHor=1076 and adrVer>=1000 and adrVer<=1010 ) or (adrVer=1005 and adrHor >= 1075 and adrHor <= 1080 ) or (adrHor =1080 and adrVer>=1005 and adrVer<=1007) or (adrVer=1007 and adrHor>=1075 and adrHor <=1080)or (adrHor=1076 and adrVer=1008)or (adrHor =1077 and adrVer=1009)or (adrHor =1078 and adrVer=1010)
--        else "1111" when (adrHor=53 and adrVer>=993 and adrVer<=1000) or (adrHor=160 and adrVer>=993 and adrVer<=1000) or (adrHor>=150 and adrHor<=160 and adrVer=993) or (adrHor>=150 and adrHor<=160 and adrVer=996) or(adrHor>=150 and adrHor<=160 and adrVer=1000) or (adrHor=107 and adrVer>=993 and adrVer<=995) or (adrVer=993 and adrHor>=100 and adrHor<=106) or(adrVer=995 and adrHor>=100 and adrHor<=106) or (adrVer=1000 and adrHor>=100 and adrHor<=106) or (adrHor=100 and adrVer>=995 and adrVer<=1000) or (adrHor =373 and adrVer>=993 and adrVer<=1000 ) or (adrVer=993 and adrHor>=369 and adrHor<=373 ) or (adrHor=587 and adrVer>=993 and adrVer<=1000) or (adrHor=590 and adrVer>=993 and adrVer<=1000) or (adrHor=907 and adrVer>=993 and adrVer<=1000) or (adrHor=917 and adrVer>=993 and adrVer<=1000)or (adrVer=993 and adrHor>=913 and adrHor<=916)
--        else "1111" when (adrVer=270 and adrHor>=1220 and adrHor<=1226) or (adrHor=1223 and adrVer>=267 and adrVer<=273) or (adrHor>=1223 and adrHor<=1226 and adrVer=273)
       else "1111" when ((adrVer=950 or adrVer=910 or adrVer=830 or adrVer=670 or adrVer=590 ) and adrHor>=1 and adrHor<=3) or (adrVer=910 and adrHor>=5 and adrHor<=7) or(adrVer=908 and adrHor>=5 and adrHor<=7)       or (adrVer=912 and adrHor >=5 and adrHor<=7) or (adrHor=7 and adrVer=909)        or(adrVer=911 and adrHor=5)         or (adrVer=908 and adrHor>=9 and adrHor<=11)   or(adrVer=912 and adrHor>=9 and adrHor<=11)    or (adrHor=9 and adrVer>=908 and adrVer<=912)   or (adrHor=11 and adrVer>=908 and adrVer<=912)   or(adrHor=7 and adrVer>=948 and adrVer<=952)   or (adrHor>=9 and adrHor<=11 and adrVer=952)   or (adrHor >=9 and adrHor<=11 and adrVer=948)  or (adrHor=9 and adrVer>=948 and adrVer<=952)  or (adrHor=11 and adrVer>=948 and adrVer<=952)  or(adrVer>=828 and adrVer<=832 and (adrHor =7 or adrHor =9 or adrHor =11))   or (adrHor =5 and adrVer>=828 and adrVer<=832) or(adrVer =830 and adrHor =6)   or ((adrVer=828 or adrVer=832) and adrHor =10)or (adrVer>=668 and adrVer<=672 and (adrHor=5 or adrHor =7 or adrHor =9 or adrHor=11))     or (adrHor=6 and (adrVer=668 or adrVer =670 or adrVer=672))            or (adrHor =10 and (adrVer=668 or adrVer=672))             or (adrVer>=588 and adrVer<=592 and (adrHor=7 or adrHor=9 or adrHor=11 or adrHor=13 or adrHor=15))             or(adrHor=10 and (adrVer=588 or adrVer=592)) or (adrHor=14 and (adrVer=588 or adrVer=592))----10 20 40 80 100
--        else "1111" when (adrHor=213 and adrVer>=993 and adrVer<=1000) or (adrVer=993 and adrHor<=213 and adrHor>=209) or (adrHor = 209 and adrVer<=993 and adrVer>=996) or (adrHor>=263 and adrHor <=267 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor =263 and adrVer>=993 and adrVer<=996) or(adrHor =267 and adrVer>=996 and adrVer<=1000)or (adrHor=320 and adrVer>=993 and adrVer<=1000) or (adrHor=324 and adrVer>=996 and adrVer<=1000) or (adrHor>=320 and adrHor <=324 and (adrVer =993 or adrVer=996 or adrVer =1000)) or (adrVer>=993 and adrVer<=1000 and (adrHor =426 or adrHor =430)) or (adrHor>=426 and adrHor<=430 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor>=480 and adrHor<=485 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=480 and adrVer>=993 and adrVer<=996) or (adrVer>=993 and adrVer<=1000 and adrHor =485) or (adrVer>=993 and adrVer<=1000 and (adrHor=531 or adrHor=535 or adrHor=539)) or (adrHor>=535 and adrHor<=539 and (adrVer=993 or adrVer=1000)) or (adrHor=638 and adrVer>=993 and adrVer<=1000) or (adrHor>=642 and adrHor<=646 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=642 and adrVer>=996 and adrVer<=1000) or(adrHor =646 and adrVer>=993 and adrVer<=996)--4 5 6 8 9 10 12 
--        else "1111"when ((adrHor=691 or adrHor=697) and adrVer>=993 and adrVer<=1000) or(adrHor>=693 and adrHor<=697 and (adrVer=993 or adrVer=996 or adrVer=1000)) or  (adrVer>=993 and adrVer<=1000 and (adrHor=743 or adrHor=749)) or(adrHor=745 and adrVer>=993 and adrVer<=996) or (adrVer=996 and adrHor>=745 and adrHor<=749) or (adrHor=797 and adrVer>=993 and adrVer<=1000) or (adrHor>=799 and adrHor<=803 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=799 and adrVer>=993 and adrVer<=996 ) or(adrHor=803 and adrVer>=996 and adrVer<=1000) or ((adrHor=850 or adrHor=852)and adrVer>=993 and adrVer<=1000) or((adrVer=993 or adrVer=996 or adrVer=1000) and adrHor>=852 and adrHor<=856) or(adrHor=856 and adrVer>=996 and adrVer<=1000) or((adrHor=957 or adrHor=959 or adrHor=963)and adrVer>=993 and adrVer<=1000) or(adrHor>=959 and adrHor<=963 and (adrVer=993 or adrVer=996 or adrVer=1000)) or((adrHor=1010 or adrHor=1016) and adrVer>=993 and adrVer<=1000) or (adrHor>=1012 and adrHor<=1016 and (adrVer=993 or adrVer=993 or adrVer=1000)) or (adrHor=1012 and adrVer>=993 and adrVer<=996) or ((adrHor=1058 or adrHor=1062)and adrVer>=993 and adrVer<=1000) or(adrHor>=1058 and adrHor<=1062 and (adrVer=993 or adrVer=1000)) or (adrHor>=1052 and adrHor<=1056 and (adrVer=993 or adrVer=996 or adrVer=1000)) or (adrHor=1056 and adrVer>=993 and adrVer<=996) or(adrHor=1052 and adrVer>=996 and adrVer<=1000) ---13 14 15 16 18 19 20  
--        else "1111" when (adrVer>=590 and adrVer<=930 and adrHor>=1 and adrHor<=3 and (adrVer MOD 4 =0))
        else "0000";

  red <= intRed when flgActiveVideo = '1' else "0000";
  green <= intGreen when flgActiveVideo = '1' else "0000";
  blue <= intBlue when flgActiveVideo = '1' else "0000";

end Behavioral;

