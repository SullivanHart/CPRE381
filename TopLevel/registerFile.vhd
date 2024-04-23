-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------
-- registerFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register file
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY registerFile IS

	PORT (
		i_CLK : IN STD_LOGIC;
		i_WE : IN STD_LOGIC;
		i_RST : IN STD_LOGIC;
		i_Read1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_Read2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_Write : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		o_Read1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		o_Read2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

END registerFile;

ARCHITECTURE structural OF registerFile IS

	COMPONENT decoder5bit
		PORT (
			i_In : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_En : IN STD_LOGIC;
			o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT register_N
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_CLK : IN STD_LOGIC;
			o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT spRegister
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_CLK : IN STD_LOGIC;
			o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT gpRegister
		PORT (
			i_RST : IN STD_LOGIC := '0';
			i_WE : IN STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_CLK : IN STD_LOGIC;
			o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT mux32t1
		PORT (
			i_Data : IN t_bus_32x32;
			i_Sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	SIGNAL decoderToRegister : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL registerToMux : t_bus_32x32;

BEGIN

	g_decoder : decoder5bit
	PORT MAP(
		i_In => i_Write,
		i_En => i_WE,
		o_Out => decoderToRegister);

	register0 : register_N
	PORT MAP(
		i_RST => '1',
		i_WE => decoderToRegister(0),
		i_D => i_Data,
		i_CLK => i_CLK,
		o_Q => registerToMux(0));

	G_32bit_register1to27 : FOR i IN 1 TO 27 GENERATE
		registerI : register_N
		PORT MAP(
			i_RST => i_RST,
			i_WE => decoderToRegister(i),
			i_D => i_Data,
			i_CLK => i_CLK,
			o_Q => registerToMux(i));
	END GENERATE G_32bit_register1to27;

	registerGP : gpRegister
	PORT MAP(
		i_RST => i_RST,
		i_WE => decoderToRegister(28),
		i_D => i_Data,
		i_CLK => i_CLK,
		o_Q => registerToMux(28));

	registerSP : spRegister
	PORT MAP(
		i_RST => i_RST,
		i_WE => decoderToRegister(29),
		i_D => i_Data,
		i_CLK => i_CLK,
		o_Q => registerToMux(29));

	G_32bit_register30to31 : FOR i IN 30 TO 31 GENERATE
		registerI : register_N
		PORT MAP(
			i_RST => i_RST,
			i_WE => decoderToRegister(i),
			i_D => i_Data,
			i_CLK => i_CLK,
			o_Q => registerToMux(i));
	END GENERATE G_32bit_register30to31;

	g_mux1 : mux32t1
	PORT MAP(
		i_Data => registerToMux,
		i_Sel => i_Read1,
		o_Out => o_Read1);

	g_mux2 : mux32t1
	PORT MAP(
		i_Data => registerToMux,
		i_Sel => i_Read2,
		o_Out => o_Read2);

END structural;