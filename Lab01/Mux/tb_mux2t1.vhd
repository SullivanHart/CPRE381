-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: A testbench for mux2t1.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_mux2t1 is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_mux2t1;

architecture mixed of tb_mux2t1 is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
component mux2t1 is
  port(i_D0 		            : in std_logic;
       i_D1 		            : in std_logic;
       i_S 		            : in std_logic;
       o_O                          : out std_logic);
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

signal si_S    : std_logic := '0';
signal si_D0   : std_logic := '0';
signal si_D1   : std_logic := '0';
signal so_O    : std_logic;

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: mux2t1
  port map( i_S      => si_S,
            i_D0     => si_D0,
            i_D1     => si_D1,
            o_O      => so_O);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  
  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  -- This process resets the sequential components of the design.
  -- It is held to be 1 across both the negative and positive edges of the clock
  -- so it works regardless of whether the design uses synchronous (pos or neg edge)
  -- or asynchronous resets.
  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  
  -- Assign inputs for each test case.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Test case 1:
    si_S    <= '0';
    si_D1   <= '0';
    si_D0   <= '0';
    wait for gCLK_HPER*2;
    -- Expect: o_O = 0

    -- Test case 2:
    si_S    <= '0';
    si_D1   <= '0';
    si_D0   <= '1';
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
    -- Expect: o_O = 1

    -- Test case 3:
    si_S    <= '0';
    si_D1   <= '1';
    si_D0   <= '0';
    wait for gCLK_HPER*2;
    -- Expect: o_O = 0

    -- Test case 4:
    si_S    <= '0';
    si_D1   <= '1';
    si_D0   <= '1';
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
    -- Expect: o_O = 1

    -- Test case 5:
    si_S    <= '1';
    si_D1   <= '0';
    si_D0   <= '0';
    wait for gCLK_HPER*2;
    -- Expect: o_O = 0

    -- Test case 6:
    si_S    <= '1';
    si_D1   <= '0';
    si_D0   <= '1';
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
    -- Expect: o_O = 0

    -- Test case 7:
    si_S    <= '1';
    si_D1   <= '1';
    si_D0   <= '0';
    wait for gCLK_HPER*2;
    -- Expect: o_O = 1

    -- Test case 8:
    si_S    <= '1';
    si_D1   <= '1';
    si_D0   <= '1';
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
    -- Expect: o_O = 1



    wait;
  end process;

end mixed;
