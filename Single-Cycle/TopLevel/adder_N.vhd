-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- adder_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide adder
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------
-- Edited 3/3/2024 by Marcus Barker:
-- added overflow logic
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY adder_N IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_carry : IN STD_LOGIC := '0';
    i_num0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_num1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_carry : OUT STD_LOGIC;
    o_overflow : OUT STD_LOGIC;
    o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END adder_N;

ARCHITECTURE structural OF adder_N IS

  COMPONENT fullAdder IS
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      i_C : IN STD_LOGIC;
      o_S : OUT STD_LOGIC;
      o_C : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL carryOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN

  -- Create first fullAdder to use i_C as carry input
  g_firstAdder : fullAdder PORT MAP(
    i_A => i_num0(0), -- ith FA's first bit to be summed hooked up to the ith bit of the first number to be summed.
    i_B => i_num1(0), -- ith FA's second bit to be summed hooked up to the ith bit of the second number to be summed.
    i_C => i_carry, -- use the FA's carry input for first fullAdder
    o_C => carryOut(0),
    o_S => o_O(0)); -- ith FA's sum hooked up to the ith bit of the output.

  -- Instantiate N invg instances.
  G_NBit_fullAdder : FOR i IN 1 TO N - 1 GENERATE
    fullAdderI : fullAdder PORT MAP(
      i_A => i_num0(i), -- ith FA's first bit to be summed hooked up to the ith bit of the first number to be summed.
      i_B => i_num1(i), -- ith FA's second bit to be summed hooked up to the ith bit of the second number to be summed.
      i_C => carryOut(i - 1),
      o_C => carryOut(i),
      o_S => o_O(i)); -- ith FA's sum hooked up to the ith bit of the output.
  END GENERATE G_NBit_fullAdder;

  o_carry <= carryOut(N - 1);
  o_overflow <= carryOut(N - 1) XOR carryOut(N - 2);

END structural;