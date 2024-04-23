-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- regEXtoDMEM.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register file
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY regEXtoDMEM IS

	PORT (
		i_CLK : IN STD_LOGIC;
		i_WE : IN STD_LOGIC;
		i_RST : IN STD_LOGIC;
		i_EX_controls : IN control_t;
		i_EX_Inst : IN STD_LOGIC_VECTOR (31 downto 0);
		i_EX_Halt : IN STD_LOGIC;
		i_EX_Ovfl : IN STD_LOGIC;
		i_EX_readTwo : IN STD_LOGIC_VECTOR (31 downto 0);
		i_EX_ALUOut : IN STD_LOGIC_VECTOR (31 downto 0);
		i_EX_PCPlusFour : IN STD_LOGIC_VECTOR (31 downto 0);
		o_DMEM_controls : OUT control_t;
		o_DMEM_Inst : OUT STD_LOGIC_VECTOR (31 downto 0);
		o_DMEM_Halt : OUT STD_LOGIC;
		o_DMEM_Ovfl : OUT STD_LOGIC;
		o_DMEM_readTwo : OUT STD_LOGIC_VECTOR (31 downto 0);
		o_DMEM_ALUOut : OUT STD_LOGIC_VECTOR (31 downto 0);
		o_DMEM_PCPlusFour : OUT STD_LOGIC_VECTOR (31 downto 0));

END regEXtoDMEM;

ARCHITECTURE structural OF regEXtoDMEM IS

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
	i_D => i_EX_controls,
	o_Q => o_DMEM_controls);

Inst : register_N
GENERIC MAP(N => 32)
PORT MAP(
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => i_WE,
	i_D => i_EX_Inst,
	o_Q => o_DMEM_Inst);

Halt : dffg
PORT MAP(
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => i_WE,
	i_D => i_EX_Halt,
	o_Q => o_DMEM_Halt);

Ovfl : dffg
PORT MAP(
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => i_WE,
	i_D => i_EX_Ovfl,
	o_Q => o_DMEM_Ovfl);

readTwo : register_N
GENERIC MAP(N => 32)
PORT MAP(
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => i_WE,
	i_D => i_EX_readTwo,
	o_Q => o_DMEM_readTwo);

ALUOut : register_N
GENERIC MAP(N => 32)
PORT MAP(
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => i_WE,
	i_D => i_EX_ALUOut,
	o_Q => o_DMEM_ALUOut);

PCPlusFour : register_N
GENERIC MAP(N => 32)
PORT MAP(
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => i_WE,
	i_D => i_EX_PCPlusFour,
	o_Q => o_DMEM_PCPlusFour);

END structural;