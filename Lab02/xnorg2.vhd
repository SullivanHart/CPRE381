-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- xnorg2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input XNOR 
-- gate.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity xnorg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end xnorg2;

architecture dataflow of xnorg2 is
begin

  o_F <= not(i_A xor i_B);
  
end dataflow;
