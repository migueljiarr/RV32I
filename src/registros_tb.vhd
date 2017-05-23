LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY registros_tb IS
END registros_tb;
 
ARCHITECTURE behavior OF registros_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT registros
    PORT(
         E_Reloj : IN  std_logic;
         E_Enable : IN  std_logic;
         E_CodOP : IN  std_logic;
         E_Sel1 : IN  std_logic_vector(4 downto 0);
         E_Sel2 : IN  std_logic_vector(4 downto 0);
         E_Dato : IN  std_logic_vector(31 downto 0);
         S_Registro1 : OUT  std_logic_vector(31 downto 0);
         S_Registro2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal E_Reloj : std_logic := '0';
   signal E_Enable : std_logic := '0';
   signal E_CodOP : std_logic := '0';
   signal E_Sel1 : std_logic_vector(4 downto 0) := (others => '0');
   signal E_Sel2 : std_logic_vector(4 downto 0) := (others => '0');
   signal E_Dato : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal S_Registro1 : std_logic_vector(31 downto 0);
   signal S_Registro2 : std_logic_vector(31 downto 0);
   signal S_OCUPADO : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: registros PORT MAP (
          E_Reloj => E_Reloj,
          E_Enable => E_Enable,
          E_CodOP => E_CodOP,
          E_Sel1 => E_Sel1,
          E_Sel2 => E_Sel2,
          E_Dato => E_Dato,
          S_Registro1 => S_Registro1,
          S_Registro2 => S_Registro2
			 );

   -- Clock process definitions
   E_Reloj_process :process
   begin
		WAIT FOR 5 NS; E_Reloj <= '1';
		WAIT FOR 5 NS; E_Reloj <= '0';
   end process;
 
	E_Enable <= '0','1' AFTER 10 NS;
	E_CodOP <= '1','0' AFTER 30 NS;
	E_Sel1 <= "00001","00010" AFTER 30 NS;
	E_Sel2 <= "01000","00001" AFTER 30 NS;
	E_Dato <= "00000000000000000001000000000001","00000000000000000000000000000000" after 30 NS;
	
END;
