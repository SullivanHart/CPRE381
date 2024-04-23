-------------------------------------------------------------------------
-- Marcus Barker
-- 3/4/2024
-------------------------------------------------------------------------
-- zeroFlag.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the implementation of the zero flag
-- output logic for the ALU.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity zeroFlag is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port( 
    i_F           : in std_logic_vector(N-1 downto 0);
	  o_zeroFlag    : out std_logic);
end zeroFlag;

architecture structural of zeroFlag is
  
  -- OR gate
  component org2 is
    port(
      i_A          : in std_logic;
      i_B          : in std_logic;
      o_F          : out std_logic);
  end component;

  -- NOT gate
  component invg is
    port(
      i_A          : in std_logic;
      o_F          : out std_logic);
  end component;

  -- carry signals
  signal s_zeroCarry: std_logic_vector(N-1 downto 0);

begin
  
  -- Create first OR gate
  
  m_firstOR: org2 port map(
    i_A     => '0',   
    i_B     => i_F(0),   
    o_F     => s_zeroCarry(0));     

  -- Instantiate N org2 instances.
  G_NBit_ORG2: for i in 1 to N-1 generate
    org2I: org2 port map(
      i_A     => s_zeroCarry(i-1),   
      i_B     => i_F(i),   
      o_F     => s_zeroCarry(i));  
  end generate G_NBit_ORG2;

  m_invg: invg port map(
    i_A     => s_zeroCarry(N-1),   
    o_F     => o_zeroFlag); 
  
end structural;
