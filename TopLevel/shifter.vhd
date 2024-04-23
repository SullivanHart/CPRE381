-------------------------------------------------------------------------
-- Marcus Barker
-- 03/16/24
-------------------------------------------------------------------------
-- shifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the shifter implementation to do MIPS 
-- sra, srl, and sll instructions
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- shifter
ENTITY shifter IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_leftORright : IN STD_LOGIC;
    i_zeroORsign : IN STD_LOGIC;
    i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    o_F : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END shifter;

ARCHITECTURE mixed OF shifter IS

  -- function to simplify repeated concatination
  FUNCTION replicate_bit(BIT : STD_LOGIC; times : INTEGER) RETURN STD_LOGIC_VECTOR IS
    VARIABLE result : STD_LOGIC_VECTOR(times - 1 DOWNTO 0);
  BEGIN
    FOR i IN result'RANGE LOOP
      result(i) := BIT;
    END LOOP;
    RETURN result;
  END FUNCTION;

  -- function to simplify reversal of input
  FUNCTION reverse_vector(input_vector : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
    VARIABLE reversed_vector : STD_LOGIC_VECTOR(input_vector'RANGE);
  BEGIN
    FOR i IN input_vector'RANGE LOOP
      reversed_vector(input_vector'length - 1 - i) := input_vector(i);
    END LOOP;
    RETURN reversed_vector;
  END FUNCTION;

  -- Necessary signals
  SIGNAL s_level0, s_level1, s_level2, s_level3, s_level4, s_level5,
  s_A_flipped, s_level5_unflipped : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN

  -- reversed input A
  s_A_flipped <= reverse_vector(i_A);

  -- 2t1 MUX: level0 is...
  s_level0 <=
    i_A WHEN i_leftORright = '1' ELSE -- 1 : input A when right shift       
    s_A_flipped; -- 0 : input A reversed when left shift
  -- 4t1 MUX: level1 is...
  s_level1 <=
    replicate_bit(s_level0(31), 1) & s_level0(31 DOWNTO 1) WHEN i_shamt(0) = '1' AND i_zeroORsign = '1' ELSE -- 11 : signed extended right shift 1
    replicate_bit('0', 1) & s_level0(31 DOWNTO 1) WHEN i_shamt(0) = '1' AND i_zeroORsign = '0' ELSE -- 10 : zero extended right shift 1
    s_level0; -- 01/00 : no shift

  -- 4t1 MUX: level2 is...
  s_level2 <=
    replicate_bit(s_level1(31), 2) & s_level1(31 DOWNTO 2) WHEN i_shamt(1) = '1' AND i_zeroORsign = '1' ELSE -- 11 : signed extended right shift 2
    replicate_bit('0', 2) & s_level1(31 DOWNTO 2) WHEN i_shamt(1) = '1' AND i_zeroORsign = '0' ELSE -- 10 : zero extended right shift 2
    s_level1; -- 01/00 : no shift

  -- 4t1 MUX: level3 is...
  s_level3 <=
    replicate_bit(s_level2(31), 4) & s_level2(31 DOWNTO 4) WHEN i_shamt(2) = '1' AND i_zeroORsign = '1' ELSE -- 11 : signed extended right shift 4
    replicate_bit('0', 4) & s_level2(31 DOWNTO 4) WHEN i_shamt(2) = '1' AND i_zeroORsign = '0' ELSE -- 10 : zero extended right shift 4
    s_level2; -- 01/00 : no shift

  -- 4t1 MUX: level4 is...
  s_level4 <=
    replicate_bit(s_level3(31), 8) & s_level3(31 DOWNTO 8) WHEN i_shamt(3) = '1' AND i_zeroORsign = '1' ELSE -- 11 : signed extended right shift 8
    replicate_bit('0', 8) & s_level3(31 DOWNTO 8) WHEN i_shamt(3) = '1' AND i_zeroORsign = '0' ELSE -- 10 : zero extended right shift 8
    s_level3; -- 01/00 : no shift

  -- 4t1 MUX: level5 is...
  s_level5 <=
    replicate_bit(s_level4(31), 16) & s_level4(31 DOWNTO 16) WHEN i_shamt(4) = '1' AND i_zeroORsign = '1' ELSE -- 11 : signed extended right shift 16
    replicate_bit('0', 16) & s_level4(31 DOWNTO 16) WHEN i_shamt(4) = '1' AND i_zeroORsign = '0' ELSE -- 10 : zero extended right shift 16
    s_level4; -- 01/00 : no shift
  -- reversed level5
  s_level5_unflipped <= reverse_vector(s_level5);

  -- 2t1 MUX: o_F is...
  o_F <=
    s_level5 WHEN i_leftORright = '1' ELSE -- 1 : output F when right shift       
    s_level5_unflipped; -- 0 : output F when left shift (undo initial flip)

END mixed;