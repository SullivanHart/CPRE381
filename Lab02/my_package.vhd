-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- my_package.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package my_package is
	type t_bus_32x32 is array (31 downto 0) of std_logic_vector(31 downto 0);
end package my_package;
