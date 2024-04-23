-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- register_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide register
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY register_N IS
	GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
	PORT (
		i_RST : IN STD_LOGIC := '0';
		i_WE : IN STD_LOGIC;
		i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_CLK : IN STD_LOGIC;
		o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END register_N;

ARCHITECTURE structural OF register_N IS
	COMPONENT dffg IS
		PORT (
			i_CLK : IN STD_LOGIC; -- Clock input
			i_RST : IN STD_LOGIC; -- Reset input
			i_WE : IN STD_LOGIC; -- Write enable input
			i_D : IN STD_LOGIC; -- Data value input
			o_Q : OUT STD_LOGIC); -- Data value output
	END COMPONENT;
BEGIN
	-- Instantiate N dffg instances.
	G_NBit_dffg : FOR i IN 0 TO N - 1 GENERATE
		dffgI : dffg PORT MAP(
			i_RST => i_RST,
			i_WE => i_WE,
			i_D => i_D(i),
			i_CLK => i_CLK,
			o_Q => o_Q(i));
	END GENERATE G_NBit_dffg;

END structural;