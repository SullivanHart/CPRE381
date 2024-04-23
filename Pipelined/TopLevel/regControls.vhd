-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- regControls.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide register
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY regControls IS
	PORT (
		i_RST : IN STD_LOGIC := '0';
		i_WE : IN STD_LOGIC;
		i_CLK : IN STD_LOGIC;
		i_D : IN control_t;
		o_Q : OUT control_t);

END regControls;

ARCHITECTURE mixed OF regControls IS
	COMPONENT dffg IS
		PORT (
			i_CLK : IN STD_LOGIC; -- Clock input
			i_RST : IN STD_LOGIC; -- Reset input
			i_WE : IN STD_LOGIC; -- Write enable input
			i_D : IN STD_LOGIC; -- Data value input
			o_Q : OUT STD_LOGIC); -- Data value output
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
BEGIN

	ALUSrc : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.ALUSrc,
		i_CLK => i_CLK,
		o_Q => o_Q.ALUSrc);

	signedImmedExtender : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.signedImmedExtender,
		i_CLK => i_CLK,
		o_Q => o_Q.signedImmedExtender);

	lui : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.lui,
		i_CLK => i_CLK,
		o_Q => o_Q.lui);

	jump : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.jump,
		i_CLK => i_CLK,
		o_Q => o_Q.jump);

	jumpImmed : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.jumpImmed,
		i_CLK => i_CLK,
		o_Q => o_Q.jumpImmed);
	link : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.link,
		i_CLK => i_CLK,
		o_Q => o_Q.link);

	branch : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.branch,
		i_CLK => i_CLK,
		o_Q => o_Q.branch);

	beq : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.beq,
		i_CLK => i_CLK,
		o_Q => o_Q.beq);

	regDst : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.regDst,
		i_CLK => i_CLK,
		o_Q => o_Q.regDst);

	memToReg : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.memToReg,
		i_CLK => i_CLK,
		o_Q => o_Q.memToReg);

	partialWord : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.partialWord,
		i_CLK => i_CLK,
		o_Q => o_Q.partialWord);

	byteOrHalf : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.byteOrHalf,
		i_CLK => i_CLK,
		o_Q => o_Q.byteOrHalf);

	signedMemExtender : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.signedMemExtender,
		i_CLK => i_CLK,
		o_Q => o_Q.signedMemExtender);

	memWrite : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.memWrite,
		i_CLK => i_CLK,
		o_Q => o_Q.memWrite);

	regWrite : dffg
	PORT MAP(
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.regWrite,
		i_CLK => i_CLK,
		o_Q => o_Q.regWrite);
		
	ALUOp : register_N
	GENERIC MAP(N => 5)
	PORT MAP(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE => i_WE,
		i_D => i_D.ALUOp,
		o_Q => o_Q.ALUOp);
END mixed;