-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- mux4t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: A 4 to 1 multiplexer
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY mux4t1 IS
	PORT (
		i_S0 : IN STD_LOGIC;
		i_S1 : IN STD_LOGIC;
		i_D0 : IN STD_LOGIC;
		i_D1 : IN STD_LOGIC;
		i_D2 : IN STD_LOGIC;
		i_D3 : IN STD_LOGIC;
		o_O : OUT STD_LOGIC);
END mux4t1;

ARCHITECTURE dataflow OF mux4t1 IS

BEGIN
	o_O <= ((i_D0 AND ((NOT i_S0) AND (NOT i_S1))) OR (i_D1 AND ((NOT i_S0) AND (i_S1)))) OR ((i_D2 AND ((i_S0) AND (NOT i_S1))) OR (i_D3 AND ((i_S0) AND (i_S1))));

END dataflow;