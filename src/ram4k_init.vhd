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

-- a la espera de las instrucciones que tiene que cargar de base la ram

-- LOAD: 00000, offset: 0, rs1: 0, funct3: 010 = LW, rd: 1:
-- 0000 0000 0000 0000 0010 0000 1000 0000
-- OPIMM: 00100, offset: 10, rs1: 0, funct3: 000 = ADDI, rd: 2:
-- 0000 0000 1010 0000 0000 0001 0001 0000
-- Tras estas dos instrucciones tendriamos 0 en R1 y 10 en R2.
X"00002080" ,X"00A00110",

X"FFFFFFFF" ,X"FFFFFFFF",

others => X"00000000"
);


end package ram4k_init;

