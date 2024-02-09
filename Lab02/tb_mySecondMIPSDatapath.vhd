-------------------------------------------------------------------------
-- Sullivan Hart
-------------------------------------------------------------------------


-- tb_mySecondMIPSDatapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for a
-- MIPS datapath.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mySecondMIPSDatapath is
  generic(gCLK_HPER   : time := 50 ns);
end tb_mySecondMIPSDatapath;

architecture behavior of tb_mySecondMIPSDatapath is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

  component mySecondMIPSDatapath

  port(	i_CLK                   	: in std_logic;
       	i_WE		            	: in std_logic;
	i_StoreEn			: in std_logic;
       	i_RST 		            	: in std_logic;
	i_selSigned			: in std_logic;		-- 0 = unsigned; 1 = signed
        i_selAddSub            	  	: in std_logic;		-- 0 = Add; 1 = Sub
       	i_selALUSrc 	            	: in std_logic;		-- 0 = Rt; 1 = Immediate
	i_selDataType			: in std_logic;		-- 0 = register; 1 = memory
       	i_Rs		            	: in std_logic_vector(4 downto 0);
       	i_Rt		            	: in std_logic_vector(4 downto 0);
	i_Rd 				: in std_logic_vector(4 downto 0);
       	i_Immed		            	: in std_logic_vector(15 downto 0);
	o_Rs				: out std_logic_vector(31 downto 0);
       	o_Rt	 		        : out std_logic_vector(31 downto 0));
  end component;


  -- Temporary signals to connect to the dff component.
  signal si_CLK, si_RST, si_WE, si_StoreEn, si_selAddSub, si_selALUSrc, si_selDataType, si_selSigned   	: std_logic;
  signal si_Rs, si_Rt, si_Rd 	: std_logic_vector(4 downto 0);
  signal so_Rs, so_Rt   : std_logic_vector(31 downto 0);
  signal si_Immed	: std_logic_vector(15 downto 0);

begin

  DUT: mySecondMIPSDatapath 
  port map(i_CLK 	    	=> si_CLK, 
           i_WE  	    	=> si_WE,
	   i_StoreEn		=> si_StoreEn,
           i_RST 	    	=> si_RST,
	   i_selSigned		=> si_selSigned,
           i_selAddSub 		=> si_selAddSub,
           i_selALUSrc 		=> si_selALUSrc,
	   i_selDataType	=> si_selDataType,
           i_Rs   		=> si_Rs,
           i_Rt   		=> si_Rt,
           i_Rd   	  	=> si_Rd,
           i_Immed   		=> si_Immed,
           o_Rs   		=> so_Rs,
           o_Rt   		=> so_Rt);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    si_CLK <= '0';
    wait for gCLK_HPER;
    si_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    -- Reset
    si_RST <= '1';
    wait for cCLK_PER;

    -- Load &A into $25
    si_Rs   		<= "00000";
    si_Rt   		<= "00001";
    si_Rd    		<= "11001";
    si_Immed  		<= x"0000";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '0';
    si_selSigned 	<= '1';
    si_RST		<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Load &B into $26
    si_Rs   		<= "00000";
    si_Rt   		<= "00001";
    si_Rd    		<= "11010";
    si_Immed  		<= x"0100";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Load A[0] into $1
    si_Rs   		<= "11001";
    si_Rd		<= "00001";
    si_Immed  		<= x"0000";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Load A[1] into $2
    si_Rs   		<= "11001";
    si_Rd		<= "00010";
    si_Immed  		<= x"0004";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- $1 = $1 + $2
    si_Rs   		<= "00001";
    si_Rt		<= "00010";
    si_Rd		<= "00001";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '0';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Store $1 into B[0]
    si_Rs   		<= "11010";
    si_Rt		<= "00001";
    si_Immed  		<= x"0000";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_WE  		<= '0';
    si_StoreEn		<= '1';
    wait for cCLK_PER;

    -- Load A[2] into $2
    si_Rs   		<= "11001";
    si_Rd		<= "00010";
    si_Immed  		<= x"0008";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- $1 = $1 + $2
    si_Rs   		<= "00001";
    si_Rt		<= "00010";
    si_Rd		<= "00001";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '0';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Store $1 into B[1]
    si_Rs   		<= "11010";
    si_Rt		<= "00001";
    si_Immed  		<= x"0004";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_WE  		<= '0';
    si_StoreEn		<= '1';
    wait for cCLK_PER;

    -- Load A[3] into $2
    si_Rs   		<= "11001";
    si_Rd		<= "00010";
    si_Immed  		<= x"000C";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- $1 = $1 + $2
    si_Rs   		<= "00001";
    si_Rt		<= "00010";
    si_Rd		<= "00001";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '0';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Store $1 into B[2]
    si_Rs   		<= "11010";
    si_Rt		<= "00001";
    si_Immed  		<= x"0008";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_WE  		<= '0';
    si_StoreEn		<= '1';
    wait for cCLK_PER;

    -- Load A[4] into $2
    si_Rs   		<= "11001";
    si_Rd		<= "00010";
    si_Immed  		<= x"0010";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- $1 = $1 + $2
    si_Rs   		<= "00001";
    si_Rt		<= "00010";
    si_Rd		<= "00001";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '0';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Store $1 into B[3]
    si_Rs   		<= "11010";
    si_Rt		<= "00001";
    si_Immed  		<= x"000C";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_WE  		<= '0';
    si_StoreEn		<= '1';
    wait for cCLK_PER;

    -- Load A[5] into $2
    si_Rs   		<= "11001";
    si_Rd		<= "00010";
    si_Immed  		<= x"0014";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- $1 = $1 + $2
    si_Rs   		<= "00001";
    si_Rt		<= "00010";
    si_Rd		<= "00001";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '0';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Store $1 into B[4]
    si_Rs   		<= "11010";
    si_Rt		<= "00001";
    si_Immed  		<= x"0010";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_WE  		<= '0';
    si_StoreEn		<= '1';
    wait for cCLK_PER;

    -- Load A[6] into $2
    si_Rs   		<= "11001";
    si_Rd		<= "00010";
    si_Immed  		<= x"0018";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '1';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- $1 = $1 + $2
    si_Rs   		<= "00001";
    si_Rt		<= "00010";
    si_Rd		<= "00001";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '0';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Load &B[64] into $27
    si_Rs   		<= "00000";
    si_Rt   		<= "00001";
    si_Rd    		<= "11011";
    si_Immed  		<= x"0200";
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_selDataType	<= '0';
    si_WE  		<= '1';
    si_StoreEn		<= '0';
    wait for cCLK_PER;

    -- Store $1 into B[63]
    si_Rs   		<= "11011";
    si_Rt		<= "00001";
    si_Immed  		<= x"FFFC";
    si_selSigned	<= '1';
    si_selAddSub 	<= '0';
    si_selALUSrc 	<= '1';
    si_WE  		<= '0';
    si_StoreEn		<= '1';
    wait for cCLK_PER;

    

    wait;
  end process;
  
end behavior;
