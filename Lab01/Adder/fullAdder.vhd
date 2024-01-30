-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: A 2 to 1 multiplexer
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity fullAdder is

  port( i_A			    : in std_logic;
	i_B 	                    : in std_logic;
    	i_C		       	    : in std_logic;
	o_S			    : out std_logic;
	o_C 		            : out std_logic);

end fullAdder;

architecture structure of fullAdder is
  -- Describe the component entities as defined in invg.vhd, andg2.vhd, org2.vhd (not strictly necessary).
  component invg
    port(i_A            : in std_logic;
         o_F            : out std_logic);
  end component;

  component andg2
    port(i_A            : in std_logic;
         i_B            : in std_logic;
         o_F            : out std_logic);
  end component;

  component org2
    port(i_A            : in std_logic;
         i_B            : in std_logic;
         o_F            : out std_logic);
  end component;

  component xorg2
    port(i_A            : in std_logic;
         i_B            : in std_logic;
         o_F            : out std_logic);
  end component;

  component xnorg2
    port(i_A            : in std_logic;
         i_B            : in std_logic;
         o_F            : out std_logic);
  end component;


  -- Signal to carry inverted A
  signal s_notA      : std_logic;
  -- Signal to carry iB and iC xored
  signal s_XOR	     : std_logic;
  -- Signal to carry iB and iC xnored
  signal s_XNOR	     : std_logic;
  -- Signal to carry iB and iC anded
  signal s_BandC     : std_logic;
  -- Signal to carry iA and xor anded
  signal s_AandXOR   : std_logic;
  -- Signal to carry notA anded with XOR
  signal s_notAandXOR: std_logic;
  -- Signal to carry A anded with XNOR
  signal s_XNORandA: std_logic;

begin

  ---------------------------------------------------------------------------
  -- Level 0: Invert A, XNOR B and C, & XOR B and C
  ---------------------------------------------------------------------------
 
  g_not: invg
    port MAP( i_A	      => i_A,
	      o_F             => s_notA);

  g_xor: xorg2
    port MAP( i_A	       => i_B,
	      i_B	       => i_C,
	      o_F              => s_XOR);

  g_xnor: xnorg2
    port MAP( i_A	       => i_B,
	      i_B	       => i_C,
	      o_F              => s_XNOR);


  ---------------------------------------------------------------------------
  -- Level 1: And various components
  ---------------------------------------------------------------------------
  g_and0: andg2
    port MAP(i_A              => i_B,
             i_B              => i_C,
             o_F              => s_BandC);
  
  g_and1: andg2
    port MAP(i_A              => i_A,
             i_B              => s_XOR,
             o_F              => s_AandXOR);

  g_and2: andg2
    port MAP(i_A              => s_XOR,
             i_B              => s_notA,
             o_F              => s_notAandXOR);

  g_and3: andg2
    port MAP(i_A              => i_A,
             i_B              => s_XNOR,
             o_F              => s_XNORandA);


    
  ---------------------------------------------------------------------------
  -- Level 2: Or the And gates
  ---------------------------------------------------------------------------
  g_or0: org2
    port MAP(i_A              => s_BandC,
             i_B              => s_AandXOR,
             o_F              => o_C);

  g_or1: org2
    port MAP(i_A              => s_notAandXOR,
             i_B              => s_XNORandA,
             o_F              => o_S);


  end structure;
