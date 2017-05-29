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
use work.left_XLEN_barrel_shifter;
use work.right_XLEN_barrel_shifter;
use work.right_arith_XLEN_barrel_shifter;

entity alu is
-- Se definen como entradas la función que decide que operación hará la ALU,
-- con 4 bits será suficiente, los dos operandos (op1, op2) de 32 bits y como
-- salida el resultado, también de 32 bits.
	port(
			funcion: in std_logic_vector(3 downto 0);
			op1, op2: in std_logic_vector(XLEN-1 downto 0);
			enable: in std_logic;
			resultado: out std_logic_vector(XLEN-1 downto 0):= XLEN_CERO);
end alu;

	
architecture Funcional of alu is

component right_XLEN_barrel_shifter
port(i: in std_logic_vector(XLEN-1 downto 0);
		s: in std_logic_vector(4 downto 0);
		o: out std_logic_vector(XLEN-1 downto 0)
);
end component;

component left_XLEN_barrel_shifter
port(i: in std_logic_vector(XLEN-1 downto 0);
		s: in std_logic_vector(4 downto 0);
		o: out std_logic_vector(XLEN-1 downto 0)
);
end component;

component right_arith_XLEN_barrel_shifter
port(i: in std_logic_vector(XLEN-1 downto 0);
		s: in std_logic_vector(4 downto 0);
		o: out std_logic_vector(XLEN-1 downto 0)
);
end component;

signal result_lsft, result_rlsft, result_rasft: std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;

begin

   int0 : left_XLEN_barrel_shifter port map(op1, op2(4 downto 0), result_lsft);
   int1 : right_XLEN_barrel_shifter port map(op1, op2(4 downto 0), result_rlsft);
   int2 : right_arith_XLEN_barrel_shifter port map(op1, op2(4 downto 0), result_rasft);

   process(enable, op1, op2, funcion, result_lsft, result_rlsft, result_rasft)
	variable add, addu, eor:    std_logic_vector(XLEN-1 downto 0);
	variable sub, subu: 	    std_logic_vector(XLEN downto 0);	-- Bit adicional para detectar underflow

   begin
	
	-- Operaciones de la ALU
		if (enable = '1') Then
			add	:= std_logic_vector(signed(op1) + signed(op2));
			addu	:= std_logic_vector(unsigned(op1) + unsigned(op2));
			sub	:= std_logic_vector(signed('0' & op1) - signed('0' & op2));
			subu	:= std_logic_vector(unsigned('0' & op1) - unsigned('0' & op2));
			eor	:= op1 xor op2;
			
			case funcion is
				when ALU_ADD 	=> resultado <= add(XLEN-1 downto 0);
				when ALU_ADDU	=> resultado <= addu(XLEN-1 downto 0);
				when ALU_SUB	=> resultado <= sub(XLEN-1 downto 0);
				when ALU_SUBU 	=> resultado <= subu(XLEN-1 downto 0);
				when ALU_AND 	=> resultado <= op1 and op2;
				when ALU_OR 	=> resultado <= op1 or op2;
				when ALU_XOR 	=> resultado <= eor;
				when ALU_SLT 	=>
					 IF (sub(XLEN) xor eor(XLEN-1)) = '0' THEN
					resultado <= XLEN_CERO; 
					 ELSE
					resultado <= XLEN_UNO; 
					 END IF;
				when ALU_SLTU 	=>
					 IF subu(XLEN) = '0' THEN
					resultado <= XLEN_CERO; 
					 ELSE
					resultado <= XLEN_UNO; 
					 END IF;
				when ALU_SLL	=> resultado <= result_lsft;
				when ALU_SRL 	=> resultado <= result_rlsft;
				when ALU_SRA 	=> resultado <= result_rasft;
				when others	=> resultado <= X"ffffffff";
			end case;
		else
		resultado <= X"00000000";
		end if;
	end process;
end Funcional;

