-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- mux32t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an 32 bit 32:1 mux.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

entity mux32t1 is
	port( 	i_Data  : in t_bus_32x32;
		i_Sel : in std_logic_vector(4 downto 0);
		o_Out : out std_logic_vector(31 downto 0));
end mux32t1;

architecture dataflow of mux32t1 is
begin
	o_Out 		<= i_Data(to_integer(unsigned(i_Sel)));
end dataflow;
