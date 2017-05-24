----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:57:05 05/17/2017 
-- Design Name: 
-- Module Name:    ram4k_init - Behavioral 
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


package ram4k_init is

-- exp de la memoria 2^12
constant ADDRLEN : integer := 12;
-- array de vectores de longitud XLEN definido en constantes
type store_t is array(0 to (2**ADDRLEN)-1) of std_logic_vector(XLEN-1 downto 0);

constant RAM_INIT : store_t := (

-- Instrucciones:

-- Instruccion en la que no se hace nada.
-- NOP: 00100, offset: 0, rs1: 0, funct3: 000 = ADDI, rd: 0:
-- 0000 0000 0000 0000 0000 0000 0001 0000 => 

-- Cargar el dato de la posicion 64 (255) al registro X1.
-- 0: LOAD: 00000, offset: 64, rs1: 0, funct3: 010 = LW, rd: 1:
-- 0000 0100 0000 0000 0010 0000 1000 0000 => 04002080

-- Sumar a cero 4 y cargarlo en el registro 2.
-- 1: OPIMM: 00100, offset: 4, rs1: 0, funct3: 000 = ADDI, rd: 2:
-- 0000 0000 0100 0000 0000 0001 0001 0000 => 00400110

-- XOR de 0xFF con 0x33 y cargarlo en el registro 3.
-- 2: OPIMM: 00100, offset: 0x33, rs1: 1, funct3: 100 = XORI, rd: 3:
-- 0000 0011 0011 0000 1100 0001 1001 0000 => 0330C190

-- AND de 0xFF con 0x33 y cargarlo en el registro 3.
-- 3: OPIMM: 00100, offset: 0x33, rs1: 1, funct3: 111 = ANDI, rd: 3:
-- 0000 0011 0011 0000 1111 0001 1001 0000 => 0330F190

-- OR de 0xFF con 0xF33 y cargarlo en el registro 3.
-- 4: OPIMM: 00100, offset: 0xF33, rs1: 1, funct3: 110 = ORI, rd: 3:
-- 1111 0011 0011 0000 1110 0001 1001 0000 => F330E190

-- Desplazar a la izquierda a 255 cuatro lugares y cargarlo en el registro 3.
-- x: OPIMM: 00100, offset: 4, rs1: 1, funct3: 001 = SLLI, rd: 3:
-- 0000 0000 0100 0000 1001 0001 1001 0000 => 00409190

X"04002080", X"00400110", X"0330C190", X"0330F190", X"F330E190", X"00409190", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 

-- Datos:
X"000000FF",

others => X"00000000"
);


end package ram4k_init;

