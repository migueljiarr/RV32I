library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

ENTITY decoder_tb is 
end decoder_tb;

ARCHITECTURE test of decoder_tb is 

COMPONENT decoder
PORT (	E_reloj: 	in std_logic;
        E_act:	 	in std_logic;
        E_instruccion: 	in std_logic_vector(XLEN-1 downto 0);
        S_reg_sel1: 	out std_logic_vector(4 downto 0);
        S_reg_sel2: 	out std_logic_vector(4 downto 0);
        S_reg_dest: 	out std_logic_vector(4 downto 0);
        S_inmediato: 	out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
        S_codigoOp: 	out std_logic_vector(4 downto 0);
        S_fun3: 	out std_logic_vector(2 downto 0);
        S_fun7: 	out std_logic_vector(6 downto 0));
END component;

CONSTANT E_reloj_periodo: time := 10 ns;
SIGNAL E_reloj: std_logic := '0';
SIGNAL E_act: std_logic := '1';
SIGNAL E_instruccion, S_inmediato: std_logic_vector(XLEN-1 downto 0);
SIGNAL S_reg_sel1, S_reg_sel2, S_reg_dest, S_codigoOp: std_logic_vector(4 downto 0);
SIGNAL S_fun3: std_logic_vector(2 downto 0);
SIGNAL S_fun7: std_logic_vector(6 downto 0);

BEGIN 

I1: decoder PORT MAP (E_reloj,E_act,E_instruccion,S_reg_sel1,S_reg_sel2,S_reg_dest,S_inmediato,S_codigoOp,S_fun3,S_fun7);

proc_clock: process
	begin
		E_reloj <= '0';
		wait for E_reloj_periodo/2;
		E_reloj <= '1';
		wait for E_reloj_periodo/2;
	end process;
	
	proc_stimuli: process
	begin
	
		wait until falling_edge(E_reloj);

		E_instruccion <= X"00f00313"; -- addi t1,x0,15
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = R0 report "wrong rs1 decoded" severity failure;
		assert S_reg_dest = T1 report "wrong rd decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = 15 report "wrong immediate decoded" severity failure;
	
		
		E_instruccion <= X"006282b3"; -- add t0,t0,t1
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = T0 report "wrong rs1 decoded" severity failure;
		assert S_reg_sel2 = T1 report "wrong rs2 decoded" severity failure;
		assert S_reg_dest = T0 report "wrong rd decoded" severity failure;
		
		
		E_instruccion <= X"00502e23"; -- sw t0,28(x0)
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = R0 report "wrong rs1 decoded" severity failure;
		assert S_reg_sel2 = T0 report "wrong rs2 decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = 28 report "wrong immediate decoded" severity failure;

		
		E_instruccion <= X"e0502023"; -- sw t0,-512(x0)
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = R0 report "wrong rs1 decoded" severity failure;
		assert S_reg_sel2 = T0 report "wrong rs2 decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = -512 report "wrong immediate decoded" severity failure;
	

		E_instruccion <= X"01c02283"; -- lw t0,28(x0)
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = R0 report "wrong rs1 decoded" severity failure;
		assert S_reg_dest = T0 report "wrong rd decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = 28 report "wrong immediate decoded" severity failure;


		E_instruccion <= X"ff1ff3ef"; -- jal x7,4 (from 0x14)
		wait until falling_edge(E_reloj);
		assert S_reg_dest = R7 report "wrong rd decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = -16 report "wrong immediate decoded" severity failure;
		
		
		E_instruccion <= X"fec003e7"; -- jalr x7,x0,-20
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = R0 report "wrong rs1 decoded" severity failure;
		assert S_reg_dest = R7 report "wrong rd decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = -20 report "wrong immediate decoded" severity failure;

		
		E_instruccion <= X"f0f0f2b7"; -- lui t0,0xf0f0f
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = R1 report "wrong rs1 decoded" severity failure;
		assert S_reg_dest = T0 report "wrong rd decoded" severity failure;
		assert S_inmediato = X"f0f0f000" report "wrong immediate decoded" severity failure;

		
		E_instruccion <= X"fe7316e3"; -- bne t1,t2,4 (from 0x18)
		wait until falling_edge(E_reloj);
		assert S_reg_sel1 = T1 report "wrong rs1 decoded" severity failure;
		assert S_reg_sel2 = T2 report "wrong rs2 decoded" severity failure;
		assert to_integer(signed(S_inmediato)) = -20 report "wrong immediate decoded" severity failure;

		
		wait for E_reloj_periodo;		
		assert false report "end of simulation" severity failure;
	
	end process;

end test;

