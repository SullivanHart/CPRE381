-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- regIDtoEX.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register file
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY regIDtoEX IS

	PORT (
		i_CLK : IN STD_LOGIC;
		i_WE : IN STD_LOGIC;
		i_RST : IN STD_LOGIC;
		i_ID_controls : IN control_t;
		i_ID_Inst : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		i_ID_Halt : IN STD_LOGIC;
		i_ID_extended : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		i_ID_readOne : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		i_ID_readTwo : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		i_ID_PCPlusFour : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_EX_controls : OUT control_t;
		o_EX_Inst : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_EX_Halt : OUT STD_LOGIC;
		o_EX_extended : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_EX_readOne : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_EX_readTwo : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		o_EX_PCPlusFour : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));

END regIDtoEX;

ARCHITECTURE structural OF regIDtoEX IS

	COMPONENT regControls
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_CLK : IN STD_LOGIC;
			i_D : IN control_t;
			o_Q : OUT control_t);
	END COMPONENT;

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

	controls : regControls
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_controls,
		o_Q => o_EX_controls);

	Inst : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_Inst,
		o_Q => o_EX_Inst);

	Halt : dffg
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_Halt,
		o_Q => o_EX_Halt);

	extended : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_extended,
		o_Q => o_EX_extended);

	readOne : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_readOne,
		o_Q => o_EX_readOne);

	readTwo : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_readTwo,
		o_Q => o_EX_readTwo);

	PCPlusFour : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_ID_PCPlusFour,
		o_Q => o_EX_PCPlusFour);
END structural;