-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- adder_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide adder
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port( i_carry      : in std_logic := '0';
	i_num0       : in std_logic_vector(N-1 downto 0);
	i_num1       : in std_logic_vector(N-1 downto 0);
	o_carry      : out std_logic;
	o_O          : out std_logic_vector(N-1 downto 0));

end adder_N;

architecture structural of adder_N is
  component fullAdder is
    port(i_A			    : in std_logic;
	 i_B 	                    : in std_logic;
    	 i_C		       	    : in std_logic;
	 o_S			    : out std_logic;
	 o_C 		            : out std_logic);
  end component;
  signal carryOut: std_logic_vector(N-1 downto 0);
begin
  -- Create first fullAdder to use i_C as carry input
  g_firstAdder: fullAdder port map(
	  i_A      => i_num0(0),   -- ith FA's first bit to be summed hooked up to the ith bit of the first number to be summed.
	  i_B      => i_num1(0),   -- ith FA's second bit to be summed hooked up to the ith bit of the second number to be summed.
	  i_C      => i_carry,	   -- use the FA's carry input for first fullAdder
	  o_C      => carryOut(0),
          o_S      => o_O(0));     -- ith FA's sum hooked up to the ith bit of the output.

  -- Instantiate N invg instances.
  G_NBit_fullAdder: for i in 1 to N-1 generate
    fullAdderI: fullAdder port map(
              i_A      => i_num0(i),   -- ith FA's first bit to be summed hooked up to the ith bit of the first number to be summed.
	      i_B      => i_num1(i),   -- ith FA's second bit to be summed hooked up to the ith bit of the second number to be summed.
	      i_C      => carryOut(i-1),
	      o_C      => carryOut(i),
              o_S      => o_O(i));     -- ith FA's sum hooked up to the ith bit of the output.
  end generate G_NBit_fullAdder;

  o_carry <= carryOut(N-1);
  
end structural;
