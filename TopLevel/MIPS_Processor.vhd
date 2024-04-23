-------------------------------------------------------------------------
-- Sullivan Hart & Marcus Barker
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a MIPS_Processor  
-- implementation.
-------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.MIPS_types.ALL;

ENTITY MIPS_Processor IS
	GENERIC (N : INTEGER := DATA_WIDTH);
	PORT (
		iCLK : IN STD_LOGIC;
		iRST : IN STD_LOGIC;
		iInstLd : IN STD_LOGIC;
		iInstAddr : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		iInstExt : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END MIPS_Processor;
ARCHITECTURE structure OF MIPS_Processor IS

	------------------------------------------------------------------------
	-- Required signals
	------------------------------------------------------------------------

	-- Required data memory signals
	SIGNAL s_DMemWr : STD_LOGIC; -- Tfinal active high data memory write enable signal
	SIGNAL s_DMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- final data memory address input
	SIGNAL s_DMemData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- final data memory data input
	SIGNAL s_DMemOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- data memory output

	-- Required register file signals 
	SIGNAL s_RegWr : STD_LOGIC; -- final active high write enable input to the register file
	SIGNAL s_RegWrAddr : STD_LOGIC_VECTOR(4 DOWNTO 0); -- final destination register address input
	SIGNAL s_RegWrData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- final data memory data input

	-- Required instruction memory signals
	SIGNAL s_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Do not assign this signal, assign to s_NextInstAddr instead
	SIGNAL s_NextInstAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- final instruction memory address input.
	SIGNAL s_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- instruction signal 

	-- Required halt signal -- for simulation
	SIGNAL s_Halt : STD_LOGIC; -- indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

	-- Required overflow signal -- for overflow exception detection
	SIGNAL s_Ovfl : STD_LOGIC; -- indicates an overflow exception would have been initiated

	------------------------------------------------------------------------
	-- Added signals
	------------------------------------------------------------------------
	--immediate val extended to 32
	SIGNAL s_extended : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

	--alu info
	SIGNAL s_readOne : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_readTwo : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_ALUInput : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_aluOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_Zero : STD_LOGIC;

	--jump info
	SIGNAL s_PCSrcSel : STD_LOGIC;
	SIGNAL s_PCPlusFour : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_PCPlusBranch : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_nonJumpPC : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_jumpPC : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_nextPC : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

	--control signals
	SIGNAL s_controls : control_t;

	--memory select
	SIGNAL s_chosenByte : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL s_chosenHalfword : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL s_extendedByte : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_extendedHalfword : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_chosenMemory : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_chosenWrite : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

	------------------------------------------------------------------------
	-- Component declorations
	------------------------------------------------------------------------

	-- memory module
	COMPONENT mem IS
		GENERIC (
			ADDR_WIDTH : INTEGER;
			DATA_WIDTH : INTEGER);
		PORT (
			clk : IN STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
			data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
			we : IN STD_LOGIC := '1';
			q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
	END COMPONENT;

	-- control unit
	COMPONENT controlUnit
		PORT (
			i_opcode : IN STD_LOGIC_VECTOR (5 DOWNTO 0); -- 6 MSBs of instruction
			i_funct : IN STD_LOGIC_VECTOR (5 DOWNTO 0); -- 6 LSBs of instruction
			o_halt : OUT STD_LOGIC;
			o_controls : OUT control_t);
	END COMPONENT;

	-- register file
	COMPONENT registerFile
		PORT (
			i_CLK : IN STD_LOGIC;
			i_WE : IN STD_LOGIC;
			i_RST : IN STD_LOGIC;
			i_Read1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_Read2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_Write : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_Read1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_Read2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	-- alu
	COMPONENT alu
		GENERIC (N : INTEGER := 32);
		PORT (
			i_ctrl : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_overflow : OUT STD_LOGIC;
			o_zero : OUT STD_LOGIC);
	END COMPONENT;

	-- adder of N bits
	COMPONENT adder_N
		GENERIC (N : INTEGER := 32);
		PORT (
			i_carry : IN STD_LOGIC := '0';
			i_num0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_num1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_carry : OUT STD_LOGIC;
			o_overflow : OUT STD_LOGIC;
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

	END COMPONENT;

	-- register of N bits, resets to 0x00400000
	COMPONENT pcModule
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_CLK : IN STD_LOGIC;
			o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	-- extender (16 to 32 bits)
	COMPONENT extender
		PORT (
			input : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			i_signed : IN STD_LOGIC; -- 0 for unsigned, 1 for signed
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	-- extender (8 to 32 bits)
	COMPONENT extender8t32
		PORT (
			input : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- input
			i_signed : IN STD_LOGIC; -- 0 for unsigned, 1 for signed
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output
	END COMPONENT;

	-- 2 to 1 mux of N bits
	COMPONENT mux2t1_N
		GENERIC (N : INTEGER := 32);
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	-- 4 to 1 mux of N bits
	COMPONENT mux4t1_N
		GENERIC (N : INTEGER := 32);
		PORT (
			i_S0 : IN STD_LOGIC;
			i_S1 : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

BEGIN

	------------------------------------------------------------------------
	-- Architecture
	------------------------------------------------------------------------

	-- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
	WITH iInstLd SELECT
		s_IMemAddr <= s_NextInstAddr WHEN '0',
		iInstAddr WHEN OTHERS;

	-- Instruction memory
	IMem : mem
	GENERIC MAP(
		ADDR_WIDTH => ADDR_WIDTH,
		DATA_WIDTH => N)
	PORT MAP(
		clk => iCLK,
		addr => s_IMemAddr(11 DOWNTO 2),
		data => iInstExt,
		we => iInstLd,
		q => s_Inst);

	-- Data memory
	DMem : mem
	GENERIC MAP(
		ADDR_WIDTH => ADDR_WIDTH,
		DATA_WIDTH => N)
	PORT MAP(
		clk => iCLK,
		addr => s_DMemAddr(11 DOWNTO 2),
		data => s_DMemData,
		we => s_DMemWr,
		q => s_DMemOut);

	-- TODO: Implement the rest of your processor below this comment! 

	-- modules
	--PC
	g_PC : pcModule
	PORT MAP(
		i_RST => iRST,
		i_WE => '1',
		i_D => s_nextPC,
		i_CLK => iCLK,
		o_Q => s_NextInstAddr);
	-- control unit
	g_control : controlUnit
	PORT MAP(
		i_opcode => s_Inst (31 DOWNTO 26), -- 6 MSBs of instruction
		i_funct => s_Inst (5 DOWNTO 0), -- 6 LSBs of instruction
		o_halt => s_Halt,
		o_controls => s_controls);

	--register file
	g_registerFile : registerFile
	PORT MAP(
		i_CLK => iCLK,
		i_RST => iRST,
		i_WE => s_RegWr,
		i_Read1 => s_Inst(25 DOWNTO 21),
		i_Read2 => s_Inst(20 DOWNTO 16),
		i_Write => s_RegWrAddr,
		i_Data => s_RegWrData,
		o_Read1 => s_readOne,
		o_Read2 => s_readTwo);

	-- extend immediate (16 bits) to N bits
	g_extend : extender
	PORT MAP(
		input => s_Inst(15 DOWNTO 0),
		i_signed => s_controls.signedImmedExtender,
		output => s_extended);

	--ALU
	g_ALU : alu
	PORT MAP(
		i_ctrl => s_controls.ALUOp,
		i_A => s_readOne,
		i_B => s_ALUInput,
		i_shamt => s_Inst (10 DOWNTO 6),
		o_zero => s_Zero,
		o_overflow => s_Ovfl,
		o_F => s_aluOut);

	--add pc + 4
	g_addPCPlusFour : adder_N
	PORT MAP(
		i_carry => '0',
		i_num0 => s_NextInstAddr,
		i_num1 => x"00000004",
		o_O => s_PCPlusFour);

	--add pc + branch amount
	g_addPCPlusImmed : adder_N
	PORT MAP(
		i_carry => '0',
		i_num0 => s_PCPlusFour,
		i_num1 => s_extended(29 DOWNTO 0) & "00", -- shift immediate left 2
		o_O => s_PCPlusBranch);

	-- muxes

	--choose dest
	g_registerDestination : mux4t1_N
	GENERIC MAP(N => 5)
	PORT MAP(
		i_S0 => s_controls.link,
		i_S1 => s_controls.regDst,
		i_D0 => s_Inst(20 DOWNTO 16),
		i_D1 => s_Inst(15 DOWNTO 11),
		i_D2 => "11111",
		i_D3 => "11111",
		o_O => s_RegWrAddr);

	-- Select register file or immediate to be passed into ALU
	g_registerOrImmed : mux2t1_N
	PORT MAP(
		i_S => s_controls.ALUSrc,
		i_D0 => s_readTwo,
		i_D1 => s_extended,
		o_O => s_ALUInput);

	-- Select alu, memory, or immed to be passed to register file
	g_ALUOrMemory : mux4t1_N
	PORT MAP(
		i_S0 => s_controls.lui,
		i_S1 => s_controls.memToReg,
		i_D0 => s_aluOut,
		i_D1 => s_chosenMemory,
		i_D2 => s_Inst(15 DOWNTO 0) & x"0000",
		i_D3 => s_Inst(15 DOWNTO 0) & x"0000",
		o_O => s_chosenWrite);

	--fetch logic

	--choose prev chosen address or pc plus four (for jal)
	g_linkSel : mux2t1_N
	PORT MAP(
		i_S => s_controls.link,
		i_D0 => s_chosenWrite,
		i_D1 => s_PCPlusFour,
		o_O => s_RegWrData);

	--choose next PC or immediate (PC +4 or branch)
	g_PCOrImmed : mux2t1_N
	PORT MAP(
		i_S => s_PCSrcSel,
		i_D0 => s_PCPlusFour,
		i_D1 => s_PCPlusBranch,
		o_O => s_nonJumpPC);

	--choose jump from reg or jump from immed (jr or j)
	g_regOrImmedJump : mux2t1_N
	PORT MAP(
		i_S => s_controls.jumpImmed,
		i_D0 => s_readOne,
		i_D1 => s_PCPlusFour(31 DOWNTO 28) & s_Inst(25 DOWNTO 0) & "00", --join 4 MSB of PC+4 and shifted instruction
		o_O => s_jumpPC);

	--choose not jump (pc + 4 / branch) or jump
	g_notJumpOrJump : mux2t1_N
	PORT MAP(
		i_S => s_controls.jump,
		i_D0 => s_nonJumpPC,
		i_D1 => s_jumpPC,
		o_O => s_nextPC);
	--choose correct byte/halfword/word

	g_byteSelect : mux4t1_N
	GENERIC MAP(N => 8)
	PORT MAP(
		i_S0 => s_DMemAddr(1),
		i_S1 => s_DMemAddr(0),
		i_D0 => s_DMemOut(7 DOWNTO 0),
		i_D1 => s_DMemOut(15 DOWNTO 8),
		i_D2 => s_DMemOut(23 DOWNTO 16),
		i_D3 => s_DMemOut(31 DOWNTO 24),
		o_O => s_chosenByte);

	g_byteExtend : extender8t32
	PORT MAP(
		input => s_chosenByte,
		i_signed => s_controls.signedMemExtender,
		output => s_extendedByte);

	g_halfwordSelect : mux2t1_N
	GENERIC MAP(N => 16)
	PORT MAP(
		i_S => s_DMemAddr(1),
		i_D0 => s_DMemOut(15 DOWNTO 0),
		i_D1 => s_DMemOut(31 DOWNTO 16),
		o_O => s_chosenHalfword);

	g_halfwordExtend : extender
	PORT MAP(
		input => s_chosenHalfword,
		i_signed => s_controls.signedMemExtender,
		output => s_extendedHalfword);

	g_sizeSelect : mux4t1_N
	GENERIC MAP(N => 32)
	PORT MAP(
		i_S0 => s_controls.partialWord,
		i_S1 => s_controls.byteOrHalf,
		i_D0 => s_DMemOut,
		i_D1 => s_DMemOut,
		i_D2 => s_extendedByte,
		i_D3 => s_extendedHalfword,
		o_O => s_chosenMemory);

	-- branch logic
	s_PCSrcSel <= s_controls.branch AND (s_controls.beq XNOR s_zero);

	-- connect signals 
	s_DMemData <= s_readTwo;
	s_DmemAddr <= oALUOut;
	oALUout <= s_aluOut;

	-- connect controls
	s_DMemWr <= s_controls.memWrite;
	s_RegWr <= s_controls.regWrite;
END structure;