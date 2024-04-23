-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: A 2 to 1 multiplexer
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY mux2t1 IS

	PORT (
		i_S : IN STD_LOGIC;
		i_D0 : IN STD_LOGIC;
		i_D1 : IN STD_LOGIC;
		o_O : OUT STD_LOGIC);

END mux2t1;

ARCHITECTURE dataflow OF mux2t1 IS

BEGIN

	o_O <= (i_D0 AND NOT i_S) OR (i_D1 AND i_S);

END dataflow;