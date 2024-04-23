-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- regDMEMtoWB.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register file
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY regDMEMtoWB IS

	PORT (
		i_CLK : IN STD_LOGIC;
		i_WE : IN STD_LOGIC;
		i_RST : IN STD_LOGIC;
		i_DMEM_controls : IN control_t;
		i_DMEM_DMEMOut : IN STD_LOGIC_VECTOR (31 downto 0);
		i_DMEM_Inst : IN STD_LOGIC_VECTOR (31 downto 0);
		i_DMEM_Halt : IN STD_LOGIC;
		i_DMEM_Ovfl : IN STD_LOGIC;
		i_DMEM_ALUOut : IN STD_LOGIC_VECTOR (31 downto 0);
		i_DMEM_PCPlusFour : IN STD_LOGIC_VECTOR (31 downto 0);
		o_WB_controls : OUT control_t;
		o_WB_DMEMOut : OUT STD_LOGIC_VECTOR (31 downto 0);
		o_WB_Inst : OUT STD_LOGIC_VECTOR (31 downto 0);
		o_WB_Halt : OUT STD_LOGIC;
		o_WB_Ovfl : OUT STD_LOGIC;
		o_WB_ALUOut : OUT STD_LOGIC_VECTOR (31 downto 0);
		o_WB_PCPlusFour : OUT STD_LOGIC_VECTOR (31 downto 0));

END regDMEMtoWB;

ARCHITECTURE structural OF regDMEMtoWB IS

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
		i_D => i_DMEM_controls,
		o_Q => o_WB_controls);

	DMemOut : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_DMEM_DMemOut,
		o_Q => o_WB_DMemOut);
		
	Inst : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_DMEM_Inst,
		o_Q => o_WB_Inst);

	Halt : dffg
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_DMEM_Halt,
		o_Q => o_WB_Halt);

	Ovfl : dffg
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_DMEM_Ovfl,
		o_Q => o_WB_Ovfl);

	ALUOut : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_DMEM_ALUOut,
		o_Q => o_WB_ALUOut);

	PCPlusFour : register_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_DMEM_PCPlusFour,
		o_Q => o_WB_PCPlusFour);

END structural;