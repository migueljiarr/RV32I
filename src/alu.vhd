----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:24:34 04/26/2017 
-- Design Name: 
-- Module Name:    alu - Funcional 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity alu is
-- Se definen como entradas la función que decide que operación hará la ALU,
-- con 4 bits será suficiente, los dos operandos (op1, op2) de 32 bits y como
-- salida el resultado, también de 32 bits.
	port(funcion: in std_logic_vector(3 downto 0);
			op1, op2: in std_logic_vector(XLEN-1 downto 0);
			enable: in std_logic;
			resultado: out std_logic_vector(XLEN-1 downto 0):= XLEN_ZERO);
end alu;

architecture Funcional of alu is

component right_XLEN_barrel_shifter
port(i: in std_logic_vector(XLEN-1 downto 0);
		s: in std_logic_vector(4 downto 0);
		o: out std_logic_vector(XLEN-1 downto 0)
);

component left_XLEN_barrel_shifter
port(i: in std_logic_vector(XLEN-1 downto 0);
		s: in std_logic_vector(4 downto 0);
		o: out std_logic_vector(XLEN-1 downto 0)
);

component right_arith_XLEN_barrel_shifter
port(i: in std_logic_vector(XLEN-1 downto 0);
		s: in std_logic_vector(4 downto 0);
		o: out std_logic_vector(XLEN-1 downto 0)
);

signal result_lsft, result_rlsft, result_rasft: std_logic_vector(XLEN-1 downto 0) := XLEN_ZERO;

begin

   int0 : left_XLEN_barrel_shifter port map(op1, op2(4 downto 0), result_lsft);
   int1 : right_XLEN_barrel_shifter port map(op1, op2(4 downto 0), result_rlsft);
   int2 : right_arith_XLEN_barrel_shifter port map(op1, op2(4 downto 0), result_rasft);

   process(enable, op1, op2, funcion)
	variable add, eor: std_logic_vector(XLEN-1 downto 0);
	variable sub: std_logic_vector(XLEN downto 0);-- Bit adicional para detectar underflow 
	variable shiftcnt: std_logic_vector(4 downto 0);
   begin
	
	-- Operaciones de la ALU
	
		add := std_logic_vector(unsigned(op1) + unsigned(op2));
		sub := std_logic_vector(unsigned('0' & op1) - unsigned('0' & op2));
		
		-- comparación sin signo: bit de underflow
		--ltu := sub(XLEN) = '1';
		
		-- comparación con signo: xor del bit de underflow con los bits de signo (tras xor)
		eor := op1 xor op2;
		--lt := (sub(XLEN) xor eor(XLEN-1)) = '1';
		
	case (funcion) is
		when ALU_ADD => resultado <= add(XLEN-1 downto 0);
		when ALU_ADDU => resultado <= std_logic_vector(unsigned(op1) + unsigned(op2));
		when ALU_SUB => resultado <= std_logic_vector(op1 - op2);
		when ALU_SUBU => resultado <= std_logic_vector(unsigned(op1) - unsigned(op2));
		when ALU_AND => resultado <= op1 and op2;
		when ALU_OR => resultado <= op1 or op2;
		when ALU_XOR => resultado <= eor;
		when ALU_SLT => resultado <= XLEN_ZERO; 
		when ALU_SLTU => resultado <= XLEN_ZERO; 
		when ALU_SLL => resultado <= result_lsft;
		when ALU_SRL => resultado <= result_rlsft;
		when ALU_SRA => resultado <= result_rasft;
	end case;
	
end Funcional;

