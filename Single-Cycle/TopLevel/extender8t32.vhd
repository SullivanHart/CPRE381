-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 16 bit to 
-- 32 bit extender
--
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY extender8t32 IS

	PORT (
		input : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- input
		i_signed : IN STD_LOGIC; -- 0 for unsigned, 1 for signed
		output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output

END extender8t32;

ARCHITECTURE mixed OF extender8t32 IS

	COMPONENT mux2t1_N
		GENERIC (N : INTEGER := 16); -- Generic of type integer for input/output data width.
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	SIGNAL signLine : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	sign : mux2t1_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_D0 => ((31 DOWNTO 8 => '0') & input),
		i_D1 => ((31 DOWNTO 8 => '1') & input),
		i_S => input(7),
		o_O => signLine);
	signedOrUnsigned : mux2t1_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_D0 => ((31 DOWNTO 8 => '0') & input),
		i_D1 => signLine,
		i_S => i_signed,
		o_O => output);

END mixed;