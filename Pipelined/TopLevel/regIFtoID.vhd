-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- regIFtoID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register file
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY regIFtoID IS

	PORT (
		i_CLK : IN STD_LOGIC;
		i_WE : IN STD_LOGIC;
		i_RST : IN STD_LOGIC;
		i_IF_Inst : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		i_IF_PCPlusFour : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_ID_Inst : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_ID_PCPlusFour : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));

END regIFtoID;

ARCHITECTURE structural OF regIFtoID IS

	COMPONENT register_N
		GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_CLK : IN STD_LOGIC;
			o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT dffg IS
		PORT (
			i_CLK : IN STD_LOGIC; -- Clock input
			i_RST : IN STD_LOGIC; -- Reset input
			i_WE : IN STD_LOGIC; -- Write enable input
			i_D : IN STD_LOGIC; -- Data value input
			o_Q : OUT STD_LOGIC); -- Data value output
	END COMPONENT;

BEGIN

	Inst : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_IF_Inst,
		o_Q => o_ID_Inst);

	PCPlusFour : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_IF_PCPlusFour,
		o_Q => o_ID_PCPlusFour);

END structural;