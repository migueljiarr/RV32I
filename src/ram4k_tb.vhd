--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:47:22 05/20/2017
-- Design Name:   
-- Module Name:   C:/Xilinx/proyectos/ramytb/ram4k_tb.vhd
-- Project Name:  ramytb
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ram4k
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY ram4k_tb IS
END ram4k_tb;
 
ARCHITECTURE behavior OF ram4k_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram4k
    PORT(
         I_CLK : IN  std_logic;
         I_Enable : IN  std_logic;
         I_WR : IN  std_logic;
         I_Address : IN  std_logic_vector(31 downto 0);
         I_Data : IN  std_logic_vector(31 downto 0);
         --O_Busy : OUT  std_logic;
         O_Data : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal I_CLK : std_logic := '0';
   signal I_Enable : std_logic := '0';
   signal I_WR : std_logic := '0';
   signal I_Address : std_logic_vector(31 downto 0) := (others => '0');
   signal I_Data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal O_Data : std_logic_vector(31 downto 0);
   --signal O_Busy : std_logic;

   -- Clock period definitions
   constant I_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram4k PORT MAP (
          I_CLK => I_CLK,
          I_Enable => I_Enable,
          I_WR => I_WR,
          I_Address => I_Address,
          I_Data => I_Data,
          --O_Busy => O_Busy,
          O_Data => O_Data
        );

	I_CLK	    <=	NOT I_CLK after 5 ns when now<110 ns else I_CLK;
	I_Enable    <=	'0' after 15 ns, '1' after 30 ns;
	I_WR	    <=	'1' after 10 ns, '0' after 30 ns,
			'1' after 50 ns, '0' after 70 ns;
	I_Address   <=	X"00000001" after 10 ns, X"00000002" after 20 ns, X"00000001" after 30 ns,
			X"00000002" after 40 ns, X"00000001" after 50 ns, X"00000002" after 60 ns,
			X"00000001" after 70 ns, X"00000002" after 80 ns, X"00000000" after 90 ns,
			X"00000003" after 100 ns;
	I_Data	    <=	X"FFFF0000" after 10 ns, X"00005555" after 20 ns,
			X"FFFF0000" after 30 ns, X"00005555" after 40 ns,
			X"FFFF0000" after 50 ns, X"00005555" after 60 ns,
			X"FFFF0000" after 70 ns, X"00005555" after 80 ns; 

END;
