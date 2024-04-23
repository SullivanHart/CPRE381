-------------------------------------------------------------------------
-- Author: Sullivan Hart
-------------------------------------------------------------------------
-- Description: This file is the first to compile in the 381 toolflow. 
-- It contains varius descriptions of constants, types, records, and packets. 
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE MIPS_types IS

  -- Example Constants. Declare more as needed
  CONSTANT DATA_WIDTH : INTEGER := 32;
  CONSTANT ADDR_WIDTH : INTEGER := 10;

  -- declare 32 x 32 for data
  TYPE t_bus_32x32 IS ARRAY (31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- declare 16 x 32 for 16t1 mux
  TYPE t_bus_16x32 IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- Control
  TYPE control_t IS RECORD
    ALUSrc : STD_LOGIC;
    signedImmedExtender : STD_LOGIC;
    lui : STD_LOGIC;
    jump : STD_LOGIC;
    jumpImmed : STD_LOGIC;
    link : STD_LOGIC;
    branch : STD_LOGIC;
    beq : STD_LOGIC;
    regDst : STD_LOGIC;
    memToReg : STD_LOGIC;
    partialWord : STD_LOGIC;
    byteOrHalf : STD_LOGIC;
    signedMemExtender : STD_LOGIC;
    memWrite : STD_LOGIC;
    regWrite : STD_LOGIC;
    ALUOp : STD_LOGIC_VECTOR(4 DOWNTO 0);
  END RECORD control_t;

  CONSTANT default_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '0',
    ALUOp => "00000"
  );

  CONSTANT add_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "10000"
  );

  CONSTANT addi_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "10000"
  );

  CONSTANT addiu_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT addu_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT and_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00010"
  );

  CONSTANT andi_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00010"
  );

  CONSTANT lui_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '1',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT lw_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '1',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT nor_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00101"
  );

  CONSTANT xor_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00110"
  );

  CONSTANT xori_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00110"
  );

  CONSTANT or_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00100"
  );

  CONSTANT ori_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00100"
  );

  CONSTANT slt_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00011"
  );

  CONSTANT slti_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00011"
  );

  CONSTANT sll_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "01000"
  );

  CONSTANT srl_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "01001"
  );

  CONSTANT sra_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "01011"
  );

  CONSTANT sw_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '1',
    regWrite => '0',
    ALUOp => "00000"
  );

  CONSTANT sub_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "10001"
  );

  CONSTANT subu_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00001"
  );

  CONSTANT beq_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '1',
    beq => '1',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '0',
    ALUOp => "00001"
  );

  CONSTANT bne_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '1',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '0',
    ALUOp => "00001"
  );

  CONSTANT j_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '1',
    jumpImmed => '1',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '0',
    ALUOp => "00000"
  );

  CONSTANT jal_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '1',
    jumpImmed => '1',
    link => '1',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT jr_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '1',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '0',
    ALUOp => "00000"
  );

  CONSTANT lb_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '1',
    partialWord => '1',
    byteOrHalf => '0',
    signedMemExtender => '1',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT lh_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '1',
    partialWord => '1',
    byteOrHalf => '1',
    signedMemExtender => '1',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT lbu_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '1',
    partialWord => '1',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT lhu_packet : control_t := (
    ALUSrc => '1',
    signedImmedExtender => '1',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '0',
    memToReg => '1',
    partialWord => '1',
    byteOrHalf => '1',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "00000"
  );

  CONSTANT sllv_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "01100"
  );

  CONSTANT srlv_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "01101"
  );

  CONSTANT srav_packet : control_t := (
    ALUSrc => '0',
    signedImmedExtender => '0',
    lui => '0',
    jump => '0',
    jumpImmed => '0',
    link => '0',
    branch => '0',
    beq => '0',
    regDst => '1',
    memToReg => '0',
    partialWord => '0',
    byteOrHalf => '0',
    signedMemExtender => '0',
    memWrite => '0',
    regWrite => '1',
    ALUOp => "01111"
  );
END PACKAGE MIPS_types;

PACKAGE BODY MIPS_types IS
  -- Probably won't need anything here... function bodies, etc.
END PACKAGE BODY MIPS_types;
