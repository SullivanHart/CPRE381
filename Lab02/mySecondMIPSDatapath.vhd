-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- mySecondMIPSDatapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a unit that implements a MIPS datapath
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.my_package.all;

entity mySecondMIPSDatapath is

  port(	i_CLK                   	: in std_logic;
       	i_WE		            	: in std_logic;
	i_StoreEn			: in std_logic;
       	i_RST 		            	: in std_logic;
	i_selSigned			: in std_logic;
        i_selAddSub            	  	: in std_logic;
       	i_selALUSrc 	            	: in std_logic;
	i_selDataType			: in std_logic;
       	i_Rs		            	: in std_logic_vector(4 downto 0);
       	i_Rt		            	: in std_logic_vector(4 downto 0);
	i_Rd 				: in std_logic_vector(4 downto 0);
       	i_Immed		            	: in std_logic_vector(15 downto 0);
	o_Rs				: out std_logic_vector(31 downto 0);
       	o_Rt	 		        : out std_logic_vector(31 downto 0));

end mySecondMIPSDatapath;

architecture structure of mySecondMIPSDatapath is
  
  component registerFile
  port(	i_CLK                   	: in std_logic;
        i_WE		            	: in std_logic;
        i_RST 		            	: in std_logic;
        i_Read1		            	: in std_logic_vector(4 downto 0);
        i_Read2		            	: in std_logic_vector(4 downto 0);
	i_Write				: in std_logic_vector(4 downto 0);
        i_Data		            	: in std_logic_vector(31 downto 0);
        o_Read1				: out std_logic_vector(31 downto 0);
        o_Read2 		        : out std_logic_vector(31 downto 0));
  end component;

  component addSub_N
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(	nAdd_Sub			: in std_logic;
        i_A           			: in std_logic_vector(N-1 downto 0);
        i_B 		      		: in std_logic_vector(N-1 downto 0);
        o_Carry				: out std_logic;
        o_F 			    	: out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N
	  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	  port(i_S          : in std_logic;
	       i_D0         : in std_logic_vector(N-1 downto 0);
	       i_D1         : in std_logic_vector(N-1 downto 0);
	       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component dmem
	generic (DATA_WIDTH : natural := 32; ADDR_WIDTH : natural := 10);

	port (	clk		: in std_logic;
		addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		data	        : in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0));

  end component;

  component extender

  	port(	input        	: in std_logic_vector(15 downto 0);     -- input
		i_signed	: in std_logic;				-- 0 for unsigned, 1 for signed
       		output       	: out std_logic_vector(31 downto 0));   -- output
	end component;


  -- Signal to connect output of MUX to input B of ALU
  signal s_B           	: std_logic_vector(31 downto 0);
  --Signal to hold output of ALU
  signal s_ALU 	      	: std_logic_vector(31 downto 0);
  --Signal to hold output of memory
  signal s_Memory 	: std_logic_vector(31 downto 0);
  --Signal to hold selected data to be put in register file
  signal s_Data 	: std_logic_vector(31 downto 0);
  --Signal to carry extended immediate
  signal extended	: std_logic_vector(31 downto 0);

begin

  ---------------------------------------------------------------------------
  -- Level 0: Extened
  ---------------------------------------------------------------------------
 
  g_extend: extender
  port MAP( input                   		=> i_Immed,
            i_signed		            	=> i_selSigned,
            output 		            	=> extended);

  ---------------------------------------------------------------------------
  -- Level 1: Register File
  ---------------------------------------------------------------------------

  g_register: registerFile
  port MAP( i_CLK                   		=> i_CLK,
            i_WE		            	=> i_WE,
            i_RST 		            	=> i_RST,
            i_Read1		            	=> i_Rs,
            i_Read2		            	=> i_Rt,
            i_Write				=> i_Rd,
            i_Data		            	=> s_Data,
            o_Read1				=> o_Rs,
            o_Read2 		        	=> o_Rt);

  ---------------------------------------------------------------------------
  -- Level 2: Select immediate or Rt
  ---------------------------------------------------------------------------
  g_immediateOrRt: mux2t1_N
    port MAP(i_S          => i_selALUSrc,
       	     i_D0         => o_Rt,
       	     i_D1         => extended,
       	     o_O          => s_B);
    
  ---------------------------------------------------------------------------
  -- Level 3: Add or subtract 
  ---------------------------------------------------------------------------
  g_add: addSub_N
  port MAP(   nAdd_Sub     	=> i_selAddSub,
              i_A       	=> o_Rs,
              i_B          	=> s_B,
              o_F          	=> s_ALU);

  ---------------------------------------------------------------------------
  -- Level 4: select data type
  --------------------------------------------------------------------------
  g_dataType: mux2t1_N
    port MAP(i_S          => i_selDataType,
       	     i_D0         => s_ALU,
       	     i_D1         => s_Memory,
       	     o_O          => s_Data);

  ---------------------------------------------------------------------------
  -- Level 5: memory module
  ---------------------------------------------------------------------------
  g_memory: dmem
  port map(clk 	=> i_clk, 
           addr => s_ALU(11 downto 2),
           data	=> o_Rt,
           we  	=> i_StoreEn,
           q   	=> s_Memory);


  end structure;
