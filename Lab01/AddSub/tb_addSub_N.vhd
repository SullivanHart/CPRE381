-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- tb_addSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: A testbench for addSub_N.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_addSub_N is
  generic(gCLK_HPER   : time := 10 ns; N : integer := 32);   -- Generic for half of the clock cycle period
end tb_addSub_N;

architecture mixed of tb_addSub_N is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
component addSub_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(	nAdd_Sub		: in std_logic;
	i_A			: in std_logic_vector(N-1 downto 0);
	i_B			: in std_logic_vector(N-1 downto 0);
	o_Carry			: out std_logic;
	o_F			: out std_logic_vector(N-1 downto 0));
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

signal snAdd_Sub 	: std_logic;
signal si_A		: std_logic_vector(N-1 downto 0);
signal si_B		: std_logic_vector(N-1 downto 0);
signal so_Carry		: std_logic;
signal so_F		: std_logic_vector(N-1 downto 0);

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: addSub_N
  port map(	nAdd_Sub  	=> snAdd_Sub,
		i_A        	=> si_A,
		i_B         	=> si_B,
		o_Carry		=> so_Carry,
		o_F		=> so_F);

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
    si_A	<= x"00000000";
    si_B	<= x"00000000";
    snAdd_Sub	<= '0';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x00000000


    -- Test case 2:
    si_A	<= x"00000000";
    si_B	<= x"00000000";
    snAdd_Sub	<= '1';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x00000000


    -- Test case 3:
    si_A	<= x"00000001";
    si_B	<= x"00000000";
    snAdd_Sub	<= '0';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x00000001


    -- Test case 4:
    si_A	<= x"00000001";
    si_B	<= x"00000000";
    snAdd_Sub	<= '1';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x00000001


    -- Test case 5:
    si_A	<= x"FFFFFFFF";
    si_B	<= x"00000000";
    snAdd_Sub	<= '1';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xFFFFFFFF


    -- Test case 6:
    si_A	<= x"FFFFFFFF";
    si_B	<= x"11111111";
    snAdd_Sub	<= '1';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xEEEEEEEE


    -- Test case 7:
    si_A	<= x"12345678";
    si_B	<= x"10000000";
    snAdd_Sub	<= '1';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x02345678


    -- Test case 8:
    si_A	<= x"00000000";
    si_B	<= x"00000001";
    snAdd_Sub	<= '1';
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xFFFFFFFF


    wait;
  end process;

end mixed;
