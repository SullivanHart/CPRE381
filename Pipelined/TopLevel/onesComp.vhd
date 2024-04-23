-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- onesComp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide ones compliment
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY onesComp IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END onesComp;

ARCHITECTURE structural OF onesComp IS
  COMPONENT invg IS
    PORT (
      i_A : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

BEGIN

  -- Instantiate N invg instances.
  G_NBit_INVG : FOR i IN 0 TO N - 1 GENERATE
    INVGI : invg PORT MAP(
      i_A => i_D(i), -- ith instance's input hooked up to the ith input.
      o_F => o_O(i)); -- ith instance's output hooked up to the ith output.
  END GENERATE G_NBit_INVG;

END structural;