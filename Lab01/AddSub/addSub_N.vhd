-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- addSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a unit that either adds or subtracts two N-bit wide numbers
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity addSub_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(	nAdd_Sub			: in std_logic;
	i_A                          	: in std_logic_vector(N-1 downto 0);
	i_B 		            	: in std_logic_vector(N-1 downto 0);
	o_Carry				: out std_logic;
	o_F 			        : out std_logic_vector(N-1 downto 0));

end addSub_N;

architecture structure of addSub_N is
  
  -- Describe the component entities as defined in adder_N.vhd, onesComp.vhd,
  -- mux2t1_N (not strictly necessary).
  component adder_N
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(   i_carry      : in std_logic := '0';
		i_num0       : in std_logic_vector(N-1 downto 0);
		i_num1       : in std_logic_vector(N-1 downto 0);
		o_carry      : out std_logic;
		o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component onesComp
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(   i_D          : in std_logic_vector(N-1 downto 0);
		o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N
	  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	  port(i_S          : in std_logic;
	       i_D0         : in std_logic_vector(N-1 downto 0);
	       i_D1         : in std_logic_vector(N-1 downto 0);
	       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  -- Signal to carry inverted A
  signal notB         : std_logic_vector(N-1 downto 0);
  -- Signals to carry either negative or positive B
  signal muxedB       : std_logic_vector(N-1 downto 0);

begin

  ---------------------------------------------------------------------------
  -- Level 0: Invert B
  ---------------------------------------------------------------------------
 
  g_invert: onesComp
    port MAP(i_D              => i_B,
             o_O              => notB);

  ---------------------------------------------------------------------------
  -- Level 1: Select add or subtract 
  ---------------------------------------------------------------------------
  g_mux: mux2t1_N
    port MAP(i_S          => nAdd_Sub,
       	     i_D0         => i_B,
       	     i_D1         => notB,
       	     o_O          => muxedB);
    
  ---------------------------------------------------------------------------
  -- Level 2: Add
  ---------------------------------------------------------------------------
  g_add: adder_N
    port MAP( 	i_carry     	=> nAdd_Sub,
		i_num0       	=> i_A,
		i_num1       	=> muxedB,
		o_carry		=> o_Carry,
		o_O          	=> o_F);

  end structure;
