-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- xnorg2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input XNOR 
-- gate.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY xnorg2 IS

  PORT (
    i_A : IN STD_LOGIC;
    i_B : IN STD_LOGIC;
    o_F : OUT STD_LOGIC);

END xnorg2;

ARCHITECTURE dataflow OF xnorg2 IS
BEGIN

  o_F <= NOT(i_A XOR i_B);

END dataflow;