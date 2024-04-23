-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- mux4t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 4:1
-- mux using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux4t1_N IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_S0 : IN STD_LOGIC;
    i_S1 : IN STD_LOGIC;
    i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END mux4t1_N;

ARCHITECTURE structural OF mux4t1_N IS

  COMPONENT mux4t1 IS
    PORT (
      i_S0 : IN STD_LOGIC;
      i_S1 : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC;
      i_D1 : IN STD_LOGIC;
      i_D2 : IN STD_LOGIC;
      i_D3 : IN STD_LOGIC;
      o_O : OUT STD_LOGIC);
  END COMPONENT;

BEGIN

  -- Instantiate N mux instances.
  G_NBit_MUX : FOR i IN 0 TO N - 1 GENERATE
    MUXI : mux4t1 PORT MAP(
      i_S0 => i_S0,
      i_S1 => i_S1,
      i_D0 => i_D0(i),
      i_D1 => i_D1(i),
      i_D2 => i_D2(i),
      i_D3 => i_D3(i),
      o_O => o_O(i));
  END GENERATE G_NBit_MUX;

END structural;