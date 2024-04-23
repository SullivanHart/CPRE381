-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- pcModule.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide register
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pcModule IS
	GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
	PORT (
		i_RST : IN STD_LOGIC := '0';
		i_WE : IN STD_LOGIC;
		i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_CLK : IN STD_LOGIC;
		o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END pcModule;

ARCHITECTURE structural OF pcModule IS

	COMPONENT register_N
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_CLK : IN STD_LOGIC;
			o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	SIGNAL s_muxOutput : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL enableOrReset : STD_LOGIC;

BEGIN
	reg : register_N
	PORT MAP(
		i_RST => '0',
		i_WE => enableOrReset,
		i_D => s_muxoutput,
		i_CLK => i_CLK,
		o_Q => o_Q);

	s_muxoutput <= x"00400000" WHEN i_RST = '1'
		ELSE
		i_D;

	enableOrReset <= i_RST OR i_WE;

END structural;