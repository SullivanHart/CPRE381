-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an 16 bit to 
-- 16 bit extender
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extender is

  port(	input        	: in std_logic_vector(15 downto 0);     -- input
	i_signed	: in std_logic;				-- 0 for unsigned, 1 for signed
       	output       	: out std_logic_vector(31 downto 0));   -- output

end extender;

architecture mixed of extender is

	component mux2t1_N
  	generic(N : integer := 16); -- Generic of type integer for input/output data width.
	    port( i_S          : in std_logic;
	          i_D0         : in std_logic_vector(N-1 downto 0);
	          i_D1         : in std_logic_vector(N-1 downto 0);
	          o_O          : out std_logic_vector(N-1 downto 0));
	  end component;

	signal signLine	: std_logic_vector(31 downto 0);
	
begin

	sign: mux2t1_N
	generic map(N => 32)
	port Map (
		i_D0	=> ((31 downto 16 => '0') & input),
		i_D1	=> ((31 downto 16 => '1') & input),
		i_S 	=> input(15),
		o_O 	=> signLine);


	signedOrUnsigned : mux2t1_N
	generic map(N => 32)
	port Map (
		i_D0	=> ((31 downto 16 => '0') & input),
		i_D1	=> signLine,
		i_S 	=> i_signed,
		o_O 	=> output);

end mixed;
