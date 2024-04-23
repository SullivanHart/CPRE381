-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- mux32t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an 32 bit 32:1 mux.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MIPS_types.ALL;

ENTITY mux32t1 IS
	PORT (
		i_Data : IN t_bus_32x32;
		i_Sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END mux32t1;

ARCHITECTURE dataflow OF mux32t1 IS
BEGIN
	o_Out <= i_Data(to_integer(unsigned(i_Sel)));
END dataflow;