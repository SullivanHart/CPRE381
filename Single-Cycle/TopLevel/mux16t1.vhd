-------------------------------------------------------------------------
-- Marcus Barker
-- 03/04/24
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux16t1.vhd
-- DESCRIPTION: This file contains an implementation of a 16 to 1 multiplexer
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_types.all;

entity mux16t1 is
    port(
        D_in : in t_bus_16x32;
        sel : in std_logic_vector(3 downto 0); -- 4 bits to select from 16 options
        D_out : out std_logic_vector(31 downto 0)
    );
end mux16t1;

architecture dataflow of mux16t1 is
begin
    D_out <= D_in(to_integer(unsigned(sel)));
end dataflow;

