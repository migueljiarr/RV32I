library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity alu_tb is
end alu_tb;

architecture Funcional of alu_tb is

	signal enable: std_logic := '0';
	signal op1: std_logic_vector(XLEN-1 downto 0) := X"00000000";
	signal op2: std_logic_vector(XLEN-1 downto 0) := X"00000000";
	signal funcion: std_logic_vector(3 downto 0);
	signal resultado: std_logic_vector(XLEN-1 downto 0);

begin

	-- instantiate unit under test
	uut: entity work.alu port map(
		funcion => funcion,
		op1 => op1,
		op2 => op2,
		enable => enable,
		resultado => resultado
	);
	
	begin
	
		-- test sub/add
	
		wait until falling_edge(I_clk);
		enable <= '1';
		op1 <= X"0000000F";
		op2 <= X"00000001";
		funcion <= ALU_SUB;
		wait until falling_edge(I_clk);
		assert resultado = X"0000000E" report "wrong output value" severity failure;
		funcion <= ALU_ADD;
		wait until falling_edge(I_clk);
		assert resultado = X"00000010" report "wrong output value" severity failure;
		
		-- test xor
	
		wait until falling_edge(I_clk);
		enable <= '1';
		op1 <= X"00000055";
		op2 <= X"000000FF";
		funcion <= ALU_XOR;
		wait until falling_edge(I_clk);
		assert resultado = X"000000AA" report "wrong output value" severity failure;


		-- test shift operations

		wait until falling_edge(I_clk);		
		op1 <= X"0000000F";
		op2 <= X"00000004";
		funcion <= ALU_SLL;
		wait until falling_edge(O_busy);
		assert resultado = X"000000F0" report "wrong output value" severity failure;


		wait until falling_edge(I_clk);		
		op1 <= X"0000000F";
		op2 <= X"00000008";
		funcion <= ALU_SLL;
		wait until falling_edge(O_busy);
		assert resultado = X"00000F00" report "wrong output value" severity failure;
		
		
		wait until falling_edge(I_clk);		
		op1 <= X"0000000F";
		op2 <= X"00000000"; -- test shift by zero, should output original value
		funcion <= ALU_SLL;
		wait until falling_edge(O_busy);
		assert resultado = X"0000000F" report "wrong output value" severity failure;
		

		wait until falling_edge(I_clk);
		op1 <= X"F0000000";
		op2 <= X"00000004";
		funcion <= ALU_SRA;
		wait until falling_edge(O_busy);
		assert resultado = X"FF000000" report "wrong output value" severity failure;
		funcion <= ALU_SRL;
		wait until falling_edge(O_busy);
		assert resultado = X"0F000000" report "wrong output value" severity failure;
		
		
		-- test flags
		
		wait until falling_edge(I_clk);
		op1 <= X"F0000000";
		op2 <= X"0000000F";
		funcion <= ALU_SUB;
		wait until falling_edge(I_clk);
		assert resultado = X"EFFFFFF1" report "wrong output value" severity failure;
		

		wait until falling_edge(I_clk);
		op1 <= X"F0000000";
		op2 <= X"F0000000";
		funcion <= ALU_SUB;
		wait until falling_edge(I_clk);
		assert resultado = X"00000000" report "wrong output value" severity failure;
		

		wait until falling_edge(I_clk);
		op1 <= X"00000001";
		op2 <= X"00000002";
		funcion <= ALU_SUB;
		wait until falling_edge(I_clk);
		assert resultado = X"FFFFFFFF" report "wrong output value" severity failure;
		
		wait for I_clk_period;		
		assert false report "end of simulation" severity failure;
	
	end process;

end architecture;