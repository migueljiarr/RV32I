library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity alu_tb is
end alu_tb;

architecture Funcional of alu_tb is

	component alu
		PORT(
			funcion: in std_logic_vector(3 downto 0);
			op1, op2: in std_logic_vector(XLEN-1 downto 0);
			enable: in std_logic;
			resultado: out std_logic_vector(XLEN-1 downto 0):= XLEN_CERO
		);
	end component;

	--INPUTS
	
	signal enable: std_logic := '0';
	signal op1: std_logic_vector(XLEN-1 downto 0) := X"00000000";
	signal op2: std_logic_vector(XLEN-1 downto 0) := X"00000000";
	signal funcion: std_logic_vector(3 downto 0);
	
	--OUTPUTS
	
	signal resultado: std_logic_vector(XLEN-1 downto 0);


begin
	-- instantiate unit under test
	uut : alu port map(
		funcion => funcion,
		op1 => op1,
		op2 => op2,
		enable => enable,
		resultado => resultado
	);
	process
	begin
		-- test sub/add
		enable <= '1';
		op1 <= X"0000000F";
		op2 <= X"00000001";
		funcion <= ALU_ADD;
		--Validacion de enable a 0. No hace nada
	wait for 1 ns;
		enable <= '0';
		funcion <= ALU_SUB;	
	wait for 1 ns;
		enable <= '1';
		funcion <= ALU_SUB;
--		assert resultado = X"0000000E" report "wrong output value" severity failure;
	wait for 1 ns;
		funcion <= ALU_ADDU;
	wait for 1 ns;
		funcion <= ALU_SUBU;
	-- test xor
	wait for 1 ns;
		op1 <= X"00000055";
		op2 <= X"000000FF";
		funcion <= ALU_XOR;
--		assert resultado = X"000000AA" report "wrong output value" severity failure;
	wait for 1 ns;
		funcion <= ALU_AND;
	wait for 1 ns;

end process;
end architecture;