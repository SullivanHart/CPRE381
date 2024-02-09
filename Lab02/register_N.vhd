-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- register_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide register
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity register_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port( i_RST      	: in std_logic := '0';
	i_WE		: in std_logic;
	i_D		: in std_logic_vector(N-1 downto 0);
	i_CLK		: in std_logic;
	o_Q		: out std_logic_vector(N-1 downto 0));

end register_N;

architecture structural of register_N is
  component dffg is
    port(i_CLK        : in std_logic;     -- Clock input
       	 i_RST        : in std_logic;     -- Reset input
       	 i_WE         : in std_logic;     -- Write enable input
      	 i_D          : in std_logic;     -- Data value input
      	 o_Q          : out std_logic);   -- Data value output
  end component;
begin
  -- Instantiate N dffg instances.
  G_NBit_dffg: for i in 0 to N-1 generate
    dffgI: dffg port map(
		i_RST      	=> i_RST,
		i_WE      	=> i_WE, 
	      	i_D      	=> i_D(i),
	      	i_CLK      	=> i_CLK,	
              	o_Q      	=> o_Q(i));    
  end generate G_NBit_dffg;
  
end structural;
