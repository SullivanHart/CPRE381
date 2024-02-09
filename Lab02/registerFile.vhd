-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- registerFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register file
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.my_package.all;

entity registerFile is

  port(	i_CLK                        	: in std_logic;
       	i_WE		            	: in std_logic;
       	i_RST 		            	: in std_logic;
       	i_Read1		            	: in std_logic_vector(4 downto 0);
       	i_Read2		            	: in std_logic_vector(4 downto 0);
	i_Write				: in std_logic_vector(4 downto 0);
       	i_Data		            	: in std_logic_vector(31 downto 0);
	o_Read1				: out std_logic_vector(31 downto 0);
       	o_Read2 		        : out std_logic_vector(31 downto 0));

end registerFile;

architecture structural of registerFile is
  
  component decoder5bit
     port(	i_In          	: in std_logic_vector(4 downto 0);
		i_En		: in std_logic;   
       		o_Out          	: out std_logic_vector(31 downto 0));
  end component;

  component register_N
    port( 	i_RST      	: in std_logic := '0';
		i_WE		: in std_logic;
		i_D		: in std_logic_vector(31 downto 0);
		i_CLK		: in std_logic;
		o_Q		: out std_logic_vector(31 downto 0));
  end component;

  component mux32t1
    port( 	i_Data	: in t_bus_32x32;
		i_Sel 	: in std_logic_vector(4 downto 0);
		o_Out 	: out std_logic_vector(31 downto 0));
  end component;

  signal decoderToRegister	: std_logic_vector(31 downto 0);
  signal registerToMux		: t_bus_32x32;

begin

  g_decoder: decoder5bit
	port MAP(i_In	=> i_Write,	
		 i_En	=> i_WE,
		 o_Out	=> decoderToRegister);
    

  register0: register_N 
	port MAP (
		i_RST      	=> '1',
		i_WE		=> decoderToRegister(0),
		i_D		=> i_Data,
		i_CLK		=> i_CLK,
		o_Q		=> registerToMux(0));

  G_32bit_register: for i in 1 to 31 generate
	registerI: register_N 
	port MAP (
		i_RST      	=> i_RST,
		i_WE		=> decoderToRegister(i),
		i_D		=> i_Data,
		i_CLK		=> i_CLK,
		o_Q		=> registerToMux(i));
  end generate G_32bit_register;

  g_mux1: mux32t1
	port Map (
		i_Data	=> registerToMux,
		i_Sel 	=> i_Read1,
		o_Out 	=> o_Read1);

  g_mux2: mux32t1
	port Map (
		i_Data	=> registerToMux,
		i_Sel 	=> i_Read2,
		o_Out 	=> o_Read2);

  end structural;
