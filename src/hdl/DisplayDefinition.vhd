--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package DisplayDefinition is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

-- Display definitions for resolution 640 X 480
-- ckVideo = 25MHz
--  constant cstHorAl: integer := 640;  -- pixels/active line
--  constant cstHorFp: integer := 16;  -- pixels/front porch
--  constant cstHorPw: integer := 96;  -- pixels/pulse with
--  constant cstHorBp: integer := 48;  -- pixels/back porch
--  constant cstHorSize: integer := 800;-- cstHorAl + cstHorFp + cstHorPw + cstHorBp; -- pixel/total line
-- constant cstHorSize: integer := cstHorAl + cstHorFp + cstHorPw + cstHorBp; -- pixel/total line
 
--constant cstVerAf: integer := 480;  -- lines/active frame
--  constant cstVerFp: integer := 10;  -- lines/front porch
--  constant cstVerPw: integer := 2;  -- lines/pulse with
--  constant cstVerBp: integer := 29;  -- lines/back porch
--  constant cstVerSize: integer := 521; --cstVerAf + cstVerFp + cstVerPw + cstVerBp; -- lines/total frame    
--  constant cstVerSize: integer := cstVerAf + cstVerFp + cstVerPw + cstVerBp; -- lines/total frame    
-- constants for DCM (50MHz to 25MHz)
-- constant cstCLKFX_DIVIDE: integer := 2;   --  Can be any interger from 1 to 32
--  constant cstCLKFX_MULTIPLY: integer := 2; --  Can be any integer from 1 to 32
--  constant cstCLKIN_DIVIDE_BY_2: boolean := true; --  TRUE/FALSE to enable CLKIN divide by two feature


---- Display definitions for resolution 800 X 600
---- ckVideo = 40MHz
--  constant cstHorAl: integer := 800;  -- pixels/active line
--  constant cstHorFp: integer := 40;  -- pixels/front porch
--  constant cstHorPw: integer := 128;  -- pixels/pulse with
--  constant cstHorBp: integer := 88;  -- pixels/back porch
--   constant cstHorSize: integer := cstHorAl + cstHorFp + cstHorPw + cstHorBp; -- pixel/total line
 
--  constant cstVerAf: integer := 600;  -- lines/active frame
--  constant cstVerFp: integer := 1;  -- lines/front porch
--  constant cstVerPw: integer := 4;  -- lines/pulse with
--  constant cstVerBp: integer := 23;  -- lines/back porch
--  constant cstVerSize: integer := cstVerAf + cstVerFp + cstVerPw + cstVerBp; -- lines/total frame    
---- constants for DCM (50MHz to 40MHz)
--  constant cstCLKFX_DIVIDE: integer := 5;   --  Can be any interger from 1 to 32
--  constant cstCLKFX_MULTIPLY: integer := 4; --  Can be any integer from 1 to 32
--  constant cstCLKIN_DIVIDE_BY_2: boolean := false; --  TRUE/FALSE to enable CLKIN divide by two feature

---- Display definitions for resolution 1280 X 1024
--  ckVideo = 100MHz
  constant cstHorAl: integer := 1280;  -- pixels/active line
  constant cstHorFp: integer := 48;  -- pixels/front porch
  constant cstHorPw: integer := 112;  -- pixels/pulse with
  constant cstHorBp: integer := 248;  -- pixels/back porch
  constant cstHorSize: integer := cstHorAl + cstHorFp + cstHorPw + cstHorBp; -- pixel/total line
 
  constant cstVerAf: integer := 1024;  -- lines/active frame
  constant cstVerFp: integer := 1;  -- lines/front porch
  constant cstVerPw: integer := 3;  -- lines/pulse with
  constant cstVerBp: integer := 38;  -- lines/back porch
  constant cstVerSize: integer := cstVerAf + cstVerFp + cstVerPw + cstVerBp; -- lines/total frame    
---- constants for DCM (50MHz to 40MHz)
  constant cstCLKFX_DIVIDE: integer := 5;   --  Can be any interger from 1 to 32
  constant cstCLKFX_MULTIPLY: integer := 4; --  Can be any integer from 1 to 32
  constant cstCLKIN_DIVIDE_BY_2: boolean := false; --  TRUE/FALSE to enable CLKIN divide by two feature


end DisplayDefinition;

package body DisplayDefinition is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end DisplayDefinition;
