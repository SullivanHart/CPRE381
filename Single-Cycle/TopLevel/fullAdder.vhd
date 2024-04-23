-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: A 2 to 1 multiplexer
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY fullAdder IS

  PORT (
    i_A : IN STD_LOGIC;
    i_B : IN STD_LOGIC;
    i_C : IN STD_LOGIC;
    o_S : OUT STD_LOGIC;
    o_C : OUT STD_LOGIC);

END fullAdder;

ARCHITECTURE structure OF fullAdder IS
  -- Describe the component entities as defined in invg.vhd, andg2.vhd, org2.vhd (not strictly necessary).
  COMPONENT invg
    PORT (
      i_A : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT andg2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT org2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT xorg2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT xnorg2
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;
  -- Signal to carry inverted A
  SIGNAL s_notA : STD_LOGIC;
  -- Signal to carry iB and iC xored
  SIGNAL s_XOR : STD_LOGIC;
  -- Signal to carry iB and iC xnored
  SIGNAL s_XNOR : STD_LOGIC;
  -- Signal to carry iB and iC anded
  SIGNAL s_BandC : STD_LOGIC;
  -- Signal to carry iA and xor anded
  SIGNAL s_AandXOR : STD_LOGIC;
  -- Signal to carry notA anded with XOR
  SIGNAL s_notAandXOR : STD_LOGIC;
  -- Signal to carry A anded with XNOR
  SIGNAL s_XNORandA : STD_LOGIC;

BEGIN

  ---------------------------------------------------------------------------
  -- Level 0: Invert A, XNOR B and C, & XOR B and C
  ---------------------------------------------------------------------------

  g_not : invg
  PORT MAP(
    i_A => i_A,
    o_F => s_notA);

  g_xor : xorg2
  PORT MAP(
    i_A => i_B,
    i_B => i_C,
    o_F => s_XOR);

  g_xnor : xnorg2
  PORT MAP(
    i_A => i_B,
    i_B => i_C,
    o_F => s_XNOR);
  ---------------------------------------------------------------------------
  -- Level 1: And various components
  ---------------------------------------------------------------------------
  g_and0 : andg2
  PORT MAP(
    i_A => i_B,
    i_B => i_C,
    o_F => s_BandC);

  g_and1 : andg2
  PORT MAP(
    i_A => i_A,
    i_B => s_XOR,
    o_F => s_AandXOR);

  g_and2 : andg2
  PORT MAP(
    i_A => s_XOR,
    i_B => s_notA,
    o_F => s_notAandXOR);

  g_and3 : andg2
  PORT MAP(
    i_A => i_A,
    i_B => s_XNOR,
    o_F => s_XNORandA);

  ---------------------------------------------------------------------------
  -- Level 2: Or the And gates
  ---------------------------------------------------------------------------
  g_or0 : org2
  PORT MAP(
    i_A => s_BandC,
    i_B => s_AandXOR,
    o_F => o_C);

  g_or1 : org2
  PORT MAP(
    i_A => s_notAandXOR,
    i_B => s_XNORandA,
    o_F => o_S);
END structure;