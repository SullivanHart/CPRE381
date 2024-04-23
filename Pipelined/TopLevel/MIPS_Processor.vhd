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
	SIGNAL s_DMemWr : STD_LOGIC; -- final active high data memory write enable signal
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

	-------------------- Fetch -------------------------
	--IMem
	SIGNAL s_IF_NextInstAddr : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_IF_Inst : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Jump
	SIGNAL s_IF_PCPlusFour : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_IF_nextPC : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

	-------------------- Decode ------------------------
	--Controls
	SIGNAL s_ID_controls : control_t;
	--IMem
	SIGNAL s_ID_Inst : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Execeptions
	SIGNAL s_ID_Halt : STD_LOGIC;
	--Extender
	SIGNAL s_ID_extended : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--ALU
	SIGNAL s_ID_readOne : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_ID_readTwo : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Jump
	SIGNAL s_ID_PCPlusFour : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_ID_PCPlusBranch : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_ID_nonJumpPC : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_ID_jumpPC : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	-- branch signals
	SIGNAL s_ID_Zero : STD_LOGIC := '0';
	SIGNAL s_ID_PCSrcSel : STD_LOGIC := '0';

	-------------------- Execute -----------------------
	--Controls
	SIGNAL s_EX_controls : control_t;
	--IMem
	SIGNAL s_EX_Inst : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Execeptions
	SIGNAL s_EX_Halt : STD_LOGIC;
	SIGNAL s_EX_Ovfl : STD_LOGIC;
	--Extender
	SIGNAL s_EX_extended : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--ALU
	SIGNAL s_EX_readOne : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_EX_readTwo : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_EX_ALUInput : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_EX_ALUOut : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Jump
	SIGNAL s_EX_PCPlusFour : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

	-------------------- Memory ------------------------
	--Controls
	SIGNAL s_DMEM_controls : control_t;
	--DMem
	SIGNAL s_DMEM_DMemOut : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--IMem
	SIGNAL s_DMEM_Inst : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Execeptions
	SIGNAL s_DMEM_Halt : STD_LOGIC;
	SIGNAL s_DMEM_Ovfl : STD_LOGIC;
	--ALU
	SIGNAL s_DMEM_readTwo : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL s_DMEM_ALUOut : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Jump
	SIGNAL s_DMEM_PCPlusFour : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

	-------------------- Write Back --------------------
	--Controls
	SIGNAL s_WB_controls : control_t;
	--DMem
	SIGNAL s_WB_DMemOut : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Reg
	SIGNAL s_WB_RegWrAddr : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL s_WB_RegWrData : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--IMem
	SIGNAL s_WB_Inst : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Execeptions
	SIGNAL s_WB_Halt : STD_LOGIC;
	SIGNAL s_WB_Ovfl : STD_LOGIC;
	--ALU
	SIGNAL s_WB_ALUOut : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	--Jump
	SIGNAL s_WB_PCPlusFour : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

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
			o_overflow : OUT STD_LOGIC);
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

	-- extends 16 to 32
	COMPONENT extender
		PORT (
			input : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			i_signed : IN STD_LOGIC; -- 0 for unsigned, 1 for signed
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	-- choose what to send to register
	COMPONENT writeDataSel
		PORT (
			i_memOut : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_ALUOut : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_Inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_lui : STD_LOGIC;
			i_link : STD_LOGIC;
			i_memToReg : STD_LOGIC;
			i_PCPlusFour : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_signedMemExtender : STD_LOGIC;
			i_partialWord : IN STD_LOGIC;
			i_byteOrHalf : IN STD_LOGIC;
			o_writeData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
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

	-- 32 bit and gate
	COMPONENT andg32
		PORT (
			i_A : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_F : OUT STD_LOGIC);
	END COMPONENT;

	-- registers 
	COMPONENT regIFtoID
		PORT (
			i_CLK : IN STD_LOGIC;
			i_WE : IN STD_LOGIC;
			i_RST : IN STD_LOGIC;
			i_IF_Inst : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_IF_PCPlusFour : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_ID_Inst : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_ID_PCPlusFour : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;

	COMPONENT regIDtoEX
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
	END COMPONENT;

	COMPONENT regEXtoDMEM
		PORT (
			i_CLK : IN STD_LOGIC;
			i_WE : IN STD_LOGIC;
			i_RST : IN STD_LOGIC;
			i_EX_controls : IN control_t;
			i_EX_Inst : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_EX_Halt : IN STD_LOGIC;
			i_EX_Ovfl : IN STD_LOGIC;
			i_EX_readTwo : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_EX_ALUOut : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_EX_PCPlusFour : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_DMEM_controls : OUT control_t;
			o_DMEM_Inst : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_DMEM_Halt : OUT STD_LOGIC;
			o_DMEM_Ovfl : OUT STD_LOGIC;
			o_DMEM_readTwo : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_DMEM_ALUOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_DMEM_PCPlusFour : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;

	COMPONENT regDMEMtoWB
		PORT (
			i_CLK : IN STD_LOGIC;
			i_WE : IN STD_LOGIC;
			i_RST : IN STD_LOGIC;
			i_DMEM_controls : IN control_t;
			i_DMEM_DMEMOut : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_DMEM_Inst : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_DMEM_Halt : IN STD_LOGIC;
			i_DMEM_Ovfl : IN STD_LOGIC;
			i_DMEM_ALUOut : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			i_DMEM_PCPlusFour : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_WB_controls : OUT control_t;
			o_WB_DMEMOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_WB_Inst : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_WB_Halt : OUT STD_LOGIC;
			o_WB_Ovfl : OUT STD_LOGIC;
			o_WB_ALUOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			o_WB_PCPlusFour : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
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
		q => s_IF_Inst);

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
		q => s_DMEM_DMemOut);

	-- TODO: Implement the rest of your processor below this comment! 

	--------------------------------- FETCH  ---------------------------------

	--choose next PC or immediate (PC +4 or branch)
	g_PCOrImmed : mux2t1_N
	PORT MAP(
		i_S => s_ID_PCSrcSel,
		i_D0 => s_IF_PCPlusFour,
		i_D1 => s_ID_PCPlusBranch,
		o_O => s_ID_nonJumpPC);

	--choose jump from reg or jump from immed (jr or j)
	g_regOrImmedJump : mux2t1_N
	PORT MAP(
		i_S => s_ID_controls.jumpImmed,
		i_D0 => s_ID_readOne,
		i_D1 => s_ID_PCPlusFour(31 DOWNTO 28) & s_ID_Inst(25 DOWNTO 0) & "00", --join 4 MSB of PC+4 and shifted instruction
		o_O => s_ID_jumpPC);

	--choose not jump (pc + 4 / branch) or jump
	g_notJumpOrJump : mux2t1_N
	PORT MAP(
		i_S => s_ID_controls.jump,
		i_D0 => s_ID_nonJumpPC,
		i_D1 => s_ID_jumpPC,
		o_O => s_IF_nextPC);

	--PC
	g_PC : pcModule
	PORT MAP(
		i_RST => iRST,
		i_WE => '1',
		i_D => s_IF_nextPC,
		i_CLK => iCLK,
		o_Q => s_IF_NextInstAddr);

	--add pc + 4
	g_addPCPlusFour : adder_N
	PORT MAP(
		i_carry => '0',
		i_num0 => s_IF_NextInstAddr,
		i_num1 => x"00000004",
		o_O => s_IF_PCPlusFour);

	--------------------------------- DECODE  ---------------------------------

	-- control unit
	g_control : controlUnit
	PORT MAP(
		i_opcode => s_ID_Inst (31 DOWNTO 26), -- 6 MSBs of instruction
		i_funct => s_ID_Inst (5 DOWNTO 0), -- 6 LSBs of instruction
		o_halt => s_ID_Halt,
		o_controls => s_ID_controls);

	--register file
	g_registerFile : registerFile
	PORT MAP(
		i_CLK => NOT iCLK,
		i_RST => iRST,
		i_WE => s_WB_controls.regWrite,
		i_Read1 => s_ID_Inst(25 DOWNTO 21),
		i_Read2 => s_ID_Inst(20 DOWNTO 16),
		i_Write => s_WB_RegWrAddr,
		i_Data => s_WB_RegWrData,
		o_Read1 => s_ID_readOne,
		o_Read2 => s_ID_readTwo);

	-- extend immediate (16 bits) to N bits
	g_extend : extender
	PORT MAP(
		input => s_ID_Inst(15 DOWNTO 0),
		i_signed => s_ID_controls.signedImmedExtender,
		output => s_ID_extended);

	--add pc + branch amount
	g_addPCPlusImmed : adder_N
	PORT MAP(
		i_carry => '0',
		i_num0 => s_ID_PCPlusFour,
		i_num1 => s_ID_extended(29 DOWNTO 0) & "00", -- shift immediate left 2
		o_O => s_ID_PCPlusBranch);


	-- branch logic
	WITH (s_ID_readOne XNOR s_ID_readTwo) SELECT s_ID_Zero <=
	'1' WHEN x"FFFFFFFF",
	'0' WHEN OTHERS;

	s_ID_PCSrcSel <= s_ID_controls.branch AND (s_ID_controls.beq XNOR s_ID_Zero);

	--------------------------------- EXECUTE  ---------------------------------
	-- Select register file or immediate to be passed into ALU
	g_registerOrImmed : mux2t1_N
	PORT MAP(
		i_S => s_EX_controls.ALUSrc,
		i_D0 => s_EX_readTwo,
		i_D1 => s_EX_extended,
		o_O => s_EX_ALUInput);

	--ALU
	g_ALU : alu
	PORT MAP(
		i_ctrl => s_EX_controls.ALUOp,
		i_A => s_EX_readOne,
		i_B => s_EX_ALUInput,
		i_shamt => s_EX_Inst (10 DOWNTO 6),
		o_overflow => s_EX_Ovfl,
		o_F => s_EX_ALUOut);

	--------------------------------- D.MEM ---------------------------------
	
	-- see DMEM above (required module)

	--------------------------------- WRITE BACK ---------------------------------

	--choose dest
	g_registerDestination : mux4t1_N
	GENERIC MAP(N => 5)
	PORT MAP(
		i_S0 => s_WB_controls.link,
		i_S1 => s_WB_controls.regDst,
		i_D0 => s_WB_Inst(20 DOWNTO 16),
		i_D1 => s_WB_Inst(15 DOWNTO 11),
		i_D2 => "11111",
		i_D3 => "11111",
		o_O => s_WB_RegWrAddr);

	--choose correct byte/halfword/word
	g_writeData : writeDataSel
	PORT MAP(
		i_memOut => s_WB_DMemOut,
		i_ALUOut => s_WB_ALUOut,
		i_Inst => s_WB_Inst,
		i_lui => s_WB_controls.lui,
		i_link => s_WB_controls.link,
		i_memToReg => s_WB_controls.memToReg,
		i_signedMemExtender => s_WB_controls.signedMemExtender,
		i_partialWord => s_WB_controls.partialWord,
		i_byteOrHalf => s_WB_controls.byteOrHalf,
		i_PCPlusFour => s_WB_PCPlusFour,
		o_writeData => s_WB_RegWrData);
	--------------------------------- REGISTERS ---------------------------------

	fetchToDecode : regIFtoID
	PORT MAP(
		i_CLK => iCLK,
		i_WE => '1',
		i_RST => iRST,
		i_IF_Inst => s_IF_Inst,
		i_IF_PCPlusFour => s_IF_PCPlusFour,
		o_ID_Inst => s_ID_Inst,
		o_ID_PCPlusFour => s_ID_PCPlusFour);

	decodeToExecute : regIDtoEX
	PORT MAP(
		i_CLK => iCLK,
		i_WE => '1',
		i_RST => iRST,
		i_ID_controls => s_ID_controls,
		i_ID_Inst => s_ID_Inst,
		i_ID_Halt => s_ID_Halt,
		i_ID_extended => s_ID_extended,
		i_ID_readOne => s_ID_readOne,
		i_ID_readTwo => s_ID_readTwo,
		i_ID_PCPlusFour => s_ID_PCPlusFour,
		o_EX_controls => s_EX_controls,
		o_EX_Inst => s_EX_Inst,
		o_EX_Halt => s_EX_Halt,
		o_EX_extended => s_EX_extended,
		o_EX_readOne => s_EX_readOne,
		o_EX_readTwo => s_EX_readTwo,
		o_EX_PCPlusFour => s_EX_PCPlusFour);

	executeToMemory : regEXtoDMEM
	PORT MAP(
		i_CLK => iCLK,
		i_WE => '1',
		i_RST => iRST,
		i_EX_controls => s_EX_controls,
		i_EX_Inst => s_EX_Inst,
		i_EX_Halt => s_EX_Halt,
		i_EX_Ovfl => s_EX_Ovfl,
		i_EX_readTwo => s_EX_readTwo,
		i_EX_ALUOut => s_EX_ALUOut,
		i_EX_PCPlusFour => s_EX_PCPlusFour,
		o_DMEM_controls => s_DMEM_controls,
		o_DMEM_Inst => s_DMEM_Inst,
		o_DMEM_Halt => s_DMEM_Halt,
		o_DMEM_Ovfl => s_DMEM_Ovfl,
		o_DMEM_readTwo => s_DMEM_readTwo,
		o_DMEM_ALUOut => s_DMEM_ALUOut,
		o_DMEM_PCPlusFour => s_DMEM_PCPlusFour);

	memoryToWriteBack : regDMEMtoWB
	PORT MAP(
		i_CLK => iCLK,
		i_WE => '1',
		i_RST => iRST,
		i_DMEM_controls => s_DMEM_controls,
		i_DMEM_DMEMOut => s_DMEM_DMEMOut,
		i_DMEM_Inst => s_DMEM_Inst,
		i_DMEM_Halt => s_DMEM_Halt,
		i_DMEM_Ovfl => s_DMEM_Ovfl,
		i_DMEM_ALUOut => s_DMEM_ALUOut,
		i_DMEM_PCPlusFour => s_DMEM_PCPlusFour,
		o_WB_controls => s_WB_controls,
		o_WB_DMEMOut => s_WB_DMEMOut,
		o_WB_Inst => s_WB_Inst,
		o_WB_Halt => s_WB_Halt,
		o_WB_Ovfl => s_WB_Ovfl,
		o_WB_ALUOut => s_WB_ALUOut,
		o_WB_PCPlusFour => s_WB_PCPlusFour);

	--------------------------------- MISC. CONNECTIONS  ---------------------------------

	-- connect signals 
	oALUout <= s_EX_ALUOut;

	-- connect controls
	s_DMemWr <= s_DMEM_controls.memWrite;
	s_RegWr <= s_WB_controls.regWrite;

	-- connect required signals 
	--DMem
	s_DMemAddr <= s_DMEM_ALUOut;
	s_DMemData <= s_DMEM_readTwo;
	s_DMemOut <= s_DMEM_DMemOut;
	--Reg
	s_RegWrAddr <= s_WB_RegWrAddr;
	s_RegWrData <= s_WB_RegWrData;
	--IMem
	s_NextInstAddr <= s_IF_NextInstAddr;
	s_Inst <= s_IF_Inst;

	--Execeptions
	s_Halt <= s_WB_Halt;
	s_Ovfl <= s_WB_Ovfl;

END structure;