-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- onesComp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide ones compliment
-- using structural VHDL, generics, and generate statements.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity onesComp is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_D          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end onesComp;

architecture structural of onesComp is
  component invg is
    port(i_A                  : in std_logic;
         o_F                  : out std_logic);
  end component;

begin

  -- Instantiate N invg instances.
  G_NBit_INVG: for i in 0 to N-1 generate
    INVGI: invg port map(
              i_A      => i_D(i),   -- ith instance's input hooked up to the ith input.
              o_F      => o_O(i));  -- ith instance's output hooked up to the ith output.
  end generate G_NBit_INVG;
  
end structural;
