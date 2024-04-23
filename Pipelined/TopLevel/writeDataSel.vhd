-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- writeDataSel.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a module to get the right part of a word
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.MIPS_types.ALL;

ENTITY writeDataSel IS
  PORT (
    i_memOut : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_ALUOut : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_Inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_lui : STD_LOGIC;
    i_memToReg : STD_LOGIC;
    i_signedMemExtender : STD_LOGIC;
    i_partialWord : IN STD_LOGIC;
    i_byteOrHalf : IN STD_LOGIC;
    i_link : STD_LOGIC;
    i_PCPlusFour : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_writeData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END writeDataSel;

ARCHITECTURE mixed OF writeDataSel IS

  SIGNAL s_chosenByte : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL s_extendedByte : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_chosenHalfword : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL s_extendedHalfword : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_chosenMemory : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_chosenWrite : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_memAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);

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

  -- connect alu to mem addr
  s_memAddr <= i_ALUOut;

  --choose correct byte/halfword/word
  g_byteSelect : mux4t1_N
  GENERIC MAP(N => 8)
  PORT MAP(
    i_S0 => s_memAddr(1),
    i_S1 => s_memAddr(0),
    i_D0 => i_memOut(7 DOWNTO 0),
    i_D1 => i_memOut(15 DOWNTO 8),
    i_D2 => i_memOut(23 DOWNTO 16),
    i_D3 => i_memOut(31 DOWNTO 24),
    o_O => s_chosenByte);

  g_byteExtend : extender8t32
  PORT MAP(
    input => s_chosenByte,
    i_signed => i_signedMemExtender,
    output => s_extendedByte);

  g_halfwordSelect : mux2t1_N
  GENERIC MAP(N => 16)
  PORT MAP(
    i_S => s_memAddr(1),
    i_D0 => i_memOut(15 DOWNTO 0),
    i_D1 => i_memOut(31 DOWNTO 16),
    o_O => s_chosenHalfword);

  g_halfwordExtend : extender
  PORT MAP(
    input => s_chosenHalfword,
    i_signed => i_signedMemExtender,
    output => s_extendedHalfword);

  g_sizeSelect : mux4t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_S0 => i_partialWord,
    i_S1 => i_byteOrHalf,
    i_D0 => i_memOut,
    i_D1 => i_memOut,
    i_D2 => s_extendedByte,
    i_D3 => s_extendedHalfword,
    o_O => s_chosenMemory);

  -- Select alu, memory, or immed to be passed to register file
  g_regSource : mux4t1_N
  PORT MAP(
    i_S0 => i_lui,
    i_S1 => i_memToReg,
    i_D0 => i_ALUOut,
    i_D1 => s_chosenMemory,
    i_D2 => i_Inst(15 DOWNTO 0) & x"0000",
    i_D3 => i_Inst(15 DOWNTO 0) & x"0000",
    o_O => s_chosenWrite);

  --choose prev chosen address or pc plus four (for jal)
  g_linkSel : mux2t1_N
  PORT MAP(
    i_S => i_link,
    i_D0 => s_chosenWrite,
    i_D1 => i_PCPlusFour,
    o_O => o_writeData);
END mixed;