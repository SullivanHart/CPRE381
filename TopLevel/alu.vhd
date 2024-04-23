-------------------------------------------------------------------------
-- Marcus Barker
-- 03/04/24
-------------------------------------------------------------------------
-- alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the alu implementation
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.MIPS_types.ALL;

ENTITY alu IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_ctrl : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_overflow : OUT STD_LOGIC;
    o_zero : OUT STD_LOGIC);
END alu;

ARCHITECTURE mixed OF alu IS

  -- addSub module
  COMPONENT addSub_N
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      nAdd_Sub : IN STD_LOGIC;
      i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_Carry : OUT STD_LOGIC;
      o_overflow : OUT STD_LOGIC;
      o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  -- mux16t1 module
  COMPONENT mux16t1
    PORT (
      D_in : IN t_bus_16x32;
      sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4 bits to select from 16 options
      D_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
  END COMPONENT;

  -- zeroFlag logic module
  COMPONENT zeroFlag
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_F : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_zeroFlag : OUT STD_LOGIC);
  END COMPONENT;

  -- shifter logic module
  COMPONENT shifter
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_leftORright : IN STD_LOGIC;
      i_zeroORsign : IN STD_LOGIC;
      i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  -- Necessary signals
  SIGNAL s_MUX : t_bus_16x32;
  SIGNAL s_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_addSub, s_or, s_shifter, s_F : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL s_overflow : STD_LOGIC;

BEGIN

  -- add/sub module with overflow
  m_addSub_N : addSub_N
  PORT MAP(
    nAdd_Sub => i_ctrl(0),
    i_A => i_A,
    i_B => i_B,
    o_overflow => s_overflow,
    o_F => s_addSub);

  -- set overflow if desired for function
  o_overflow <= i_ctrl(4) AND s_overflow;

  -- MUX 0000: ADD
  s_MUX(0) <= s_addSub;

  -- MUX 0001: SUB
  s_MUX(1) <= s_addSub;

  -- MUX 0010: AND
  s_MUX(2) <= i_A AND i_B;

  -- MUX 0011: SLT
  s_MUX(3) <= (31 DOWNTO 1 => '0') & s_addSub(31);

  -- MUX 0100: OR
  s_or <= i_A OR i_B;
  s_MUX(4) <= s_or;

  -- MUX 0101: NOR
  s_MUX(5) <= NOT s_or;

  -- MUX 0110: XOR
  s_MUX(6) <= i_A XOR i_B;

  -- MUX 0111: N/A
  -- s_MUX(7) <= ???

  -- 2t1 MUX: shifter's shift amount input comes from...
  s_shamt <=
    i_A(4 DOWNTO 0) WHEN i_ctrl(2) = '1' ELSE -- 1 : least significant 5 bits of input i_A (used for sllv, srlv, srav)
    i_shamt; -- 0 : instruction shift amount (used for sll, srl, sra)

  -- Shift module for sra, srl, sll instructions
  m_shifter : shifter
  PORT MAP(
    i_leftORright => i_ctrl(0),
    i_zeroORsign => i_ctrl(1),
    i_A => i_B,
    i_shamt => s_shamt,
    o_F => s_shifter);

  -- MUX 1000: SLL
  s_MUX(8) <= s_shifter;

  -- MUX 1001: SRL
  s_MUX(9) <= s_shifter;

  -- MUX 1010: N/A
  -- s_MUX(10) <= ???

  -- MUX 1011: SRA
  s_MUX(11) <= s_shifter;

  -- MUX 1100: SLL
  s_MUX(12) <= s_shifter;

  -- MUX 1101: SRL
  s_MUX(13) <= s_shifter;

  -- MUX 1110: N/A
  -- s_MUX(14) <= ???

  -- MUX 1111: SRA
  s_MUX(15) <= s_shifter;

  -- 16-to-1 multiplexer to determine output
  m_mux16t1 : mux16t1
  PORT MAP(
    D_in => s_MUX,
    sel => i_ctrl(3 DOWNTO 0), -- This assigns the least significant 4 bits of i_ctrl to sel
    D_out => s_F);

  -- zero output logic module
  m_zeroFlag : zeroFlag
  PORT MAP(
    i_F => s_F,
    o_zeroFlag => o_zero);

  -- set output
  o_F <= s_F;

END mixed;