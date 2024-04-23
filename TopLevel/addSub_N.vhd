-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- addSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a unit that either adds or subtracts two N-bit wide numbers
-------------------------------------------------------------------------
-- Edited 3/3/2024 by Marcus Barker:
-- added overflow logic
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY addSub_N IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    nAdd_Sub : IN STD_LOGIC;
    i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_Carry : OUT STD_LOGIC;
    o_overflow : OUT STD_LOGIC;
    o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END addSub_N;

ARCHITECTURE structure OF addSub_N IS

  -- Describe the component entities as defined in adder_N.vhd, onesComp.vhd,
  -- mux2t1_N (not strictly necessary).
  COMPONENT adder_N
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_carry : IN STD_LOGIC := '0';
      i_num0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_num1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_carry : OUT STD_LOGIC;
      o_overflow : OUT STD_LOGIC;
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT onesComp
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT mux2t1_N
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_S : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  -- Signal to carry inverted A
  SIGNAL notB : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  -- Signals to carry either negative or positive B
  SIGNAL muxedB : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN

  ---------------------------------------------------------------------------
  -- Level 0: Invert B
  ---------------------------------------------------------------------------

  g_invert : onesComp
  PORT MAP(
    i_D => i_B,
    o_O => notB);

  ---------------------------------------------------------------------------
  -- Level 1: Select add or subtract 
  ---------------------------------------------------------------------------
  g_mux : mux2t1_N
  PORT MAP(
    i_S => nAdd_Sub,
    i_D0 => i_B,
    i_D1 => notB,
    o_O => muxedB);

  ---------------------------------------------------------------------------
  -- Level 2: Add
  ---------------------------------------------------------------------------
  g_add : adder_N
  PORT MAP(
    i_carry => nAdd_Sub,
    i_num0 => i_A,
    i_num1 => muxedB,
    o_carry => o_Carry,
    o_overflow => o_overflow,
    o_O => o_F);

END structure;