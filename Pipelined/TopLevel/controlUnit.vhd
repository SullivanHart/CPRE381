-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- controlUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a control unit for a single-cycle 
-- processor
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY controlUnit IS

	PORT (
		i_opcode : IN STD_LOGIC_VECTOR (5 DOWNTO 0); -- 6 MSBs of instruction
		i_funct : IN STD_LOGIC_VECTOR (5 DOWNTO 0); -- 6 LSBs of instruction
		o_halt : OUT STD_LOGIC;
		o_controls : OUT control_t);
END controlUnit;

ARCHITECTURE mixed OF controlUnit IS
	SIGNAL s_rInst : control_t;

BEGIN

	WITH i_funct SELECT s_rInst <=
		add_packet WHEN "100000", -- add
		addu_packet WHEN "100001", -- addu
		and_packet WHEN "100100", -- and
		nor_packet WHEN "100111", -- nor
		xor_packet WHEN "100110", -- xor
		or_packet WHEN "100101", -- or
		slt_packet WHEN "101010", -- slt
		sll_packet WHEN "000000", -- sll
		srl_packet WHEN "000010", -- srl
		sra_packet WHEN "000011", -- sra
		sub_packet WHEN "100010", -- sub
		subu_packet WHEN "100011", -- subu
		jr_packet WHEN "001000", -- jr
		sllv_packet WHEN "000100", -- sllv
		srlv_packet WHEN "000110", -- srlv
		srav_packet WHEN "000111", -- srav
		default_packet WHEN OTHERS;

	WITH i_opcode SELECT o_controls <=
		addi_packet WHEN "001000", -- addi
		addiu_packet WHEN "001001", -- addiu
		andi_packet WHEN "001100", -- andi
		lui_packet WHEN "001111", -- lui
		lw_packet WHEN "100011", -- lw
		xori_packet WHEN "001110", -- xori
		ori_packet WHEN "001101", -- ori
		slti_packet WHEN "001010", -- slti
		sw_packet WHEN "101011", -- sw
		beq_packet WHEN "000100", -- beq
		bne_packet WHEN "000101", -- bne
		j_packet WHEN "000010", -- j
		jal_packet WHEN "000011", -- jal
		lb_packet WHEN "100000", -- lb
		lh_packet WHEN "100001", -- lh
		lbu_packet WHEN "100100", -- lbu
		lhu_packet WHEN "100101", -- lhu
		s_rInst WHEN "000000", --select inst determined by funct when o (r type) 
		default_packet WHEN OTHERS;

	WITH i_opcode SELECT o_halt <=
		'1' WHEN "010100",
		'0' WHEN OTHERS;
END mixed;