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

-- Saltar a la intruccion en la posicion 8.
-- 0=0x0: JAL: 11011, offset: 8, rd: 0:
-- 0000 0000 1000 0000 0000 0000 0110 1100 => 0080006C

-- Cargar el dato de la posicion 0+64 (255) al registro X1.
-- 8=0x8: LOAD: 00000, offset: 64, rs1: 0, funct3: 010 = LW, rd: 1:
-- 0000 0100 0000 0000 0010 0000 1000 0000 => 04002080

-- Sumar a X0 (0) 4 y cargarlo en el registro 2. X2(0x4)
-- 9=0x9: OPIMM: 00100, offset: 4, rs1: 0, funct3: 000 = ADDI, rd: 2:
-- 0000 0000 0100 0000 0000 0001 0001 0000 => 00400110

-- XOR de 0xFF con 0x33 y cargarlo en el registro 3. X3 (0xCC)
-- 10=0xA: OPIMM: 00100, offset: 0x33, rs1: 1, funct3: 100 = XORI, rd: 3:
-- 0000 0011 0011 0000 1100 0001 1001 0000 => 0330C190

-- AND de 0xFF con 0x33 y cargarlo en el registro 3. X3 (0x33)
-- 11=0xB: OPIMM: 00100, offset: 0x33, rs1: 1, funct3: 111 = ANDI, rd: 3:
-- 0000 0011 0011 0000 1111 0001 1001 0000 => 0330F190

-- OR de 0xFF con 0xF33 y cargarlo en el registro 3. X3 (0xFFFFFFFF) Se expanden los 12 bits por el signo.
-- 12=0xC: OPIMM: 00100, offset: 0xF33, rs1: 1, funct3: 110 = ORI, rd: 3:
-- 1111 0011 0011 0000 1110 0001 1001 0000 => F330E190

-- Desplazar a la izquierda a 255 cuatro lugares y cargarlo en el registro 3. X3 (0xFF0)
-- 13=0xD: OPIMM: 00100, offset: 4, rs1: 1, funct3: 001 = SLLI, rd: 3:
-- 0000 0000 0100 0000 1001 0001 1001 0000 => 00409190

-- Desplazar a la derecha a 255 cuatro lugares y cargarlo en el registro 3. X3 (0xF)
-- 14=0xE: OPIMM: 00100, offset: 4, rs1: 1, funct3: 101 = SRL_SRA, rd: 3:
-- 0000 0000 0100 0000 1101 0001 1001 0000 => 0040D190

-- Desplazar aritmeticamente a la derecha a 255 cuatro lugares y cargarlo en el registro 3. X3 (0xF)
-- 15=0xF: OPIMM: 00100, offset: 4, rs1: 1, funct3: 101 = SRL_SRA, rd: 3:
-- 0100 0000 0100 0000 1101 0001 1001 0000 => 4040D190

-- Sumar X1 (255) a X2(4) y almacenarlo en el registro X3 (0x103).
-- 16=0x10: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 000 = ADD, rd: 3:
-- 0000 0000 0010 0000 1000 0001 1011 0000 => 002081B0

-- Restar X1 (255) a X2(4) y almacenarlo en el registro X3 (0xFB).
-- 17=0x11: OP: 01100, funct7: 0x20, rs2: 2, rs1: 1, funct3: 000 = ADD, rd: 3:
-- 0100 0000 0010 0000 1000 0001 1011 0000 => 402081B0

-- OR de X1 (255) a X2(4) y almacenarlo en el registro X3 (0xFF).
-- 18=0x12: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 110 = OR, rd: 3:
-- 0000 0000 0010 0000 1110 0001 1011 0000 => 0020E1B0

-- XOR de X1 (255) a X2(4) y almacenarlo en el registro X3 (0xFB).
-- 19=0x13: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 100 = XOR, rd: 3:
-- 0000 0000 0010 0000 1100 0001 1011 0000 => 0020C1B0

-- AND de X1 (255) a X2(4) y almacenarlo en el registro X3 (0x4).
-- 20=0x14: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 111 = AND, rd: 3:
-- 0000 0000 0010 0000 1111 0001 1011 0000 => 0020F1B0

-- Desplazar a la izquierda a X1 (255) X2 (4) lugares y cargarlo en el registro X3 (0xFF0).
-- 21=0x15: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 001 = SLL, rd: 3:
-- 0000 0000 0010 0000 1001 0001 1011 0000 => 002091B0

-- Desplazar a la derecha a X1 (255) X2 (4) lugares y cargarlo en el registro X3 (0xF).
-- 22=0x16: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 101 = SRL_SRA, rd: 3:
-- 0000 0000 0010 0000 1101 0001 1011 0000 => 0020D1B0

-- Desplazar aritmeticamente a la derecha a X1 (255) X2 (4) lugares y cargarlo en el registro X3 (0xF).
-- 23=0x17: OP: 01100, funct7: 0x20, rs2: 2, rs1: 1, funct3: 101 = SRL_SRA, rd: 3:
-- 0100 0000 0010 0000 1111 0001 1011 0000 => 4020D1B0


-- SLTI(U)
-- Teniendo en cuenta el signo, se setea X3 a 0x0 pues X1 (0x0FF) es mayor que 0x800.
-- 24=0x18: OPIMM: 00100, offset: 0x800, rs1: 1, funct3: 010 = SLTI, rd: 3:
-- 1000 0000 0000 0000 1010 0001 1001 0000 => 8000A190

-- Teniendo en cuenta el signo, se setea X3 a 0x1 pues X2 (0x004) es menor que 0x0FE.
-- 25=0x19: OPIMM: 00100, offset: 0x0FE, rs1: 2, funct3: 010 = SLTI, rd: 3:
-- 0000 1111 1110 0001 0010 0001 1001 0000 => 0FE12190

-- Sin tener en cuenta el signo, se setea X3 a 0x1 pues X1 (0x0FF) es menor que 0x800.
-- 26=0x1A: OPIMM: 00100, offset: 0x800, rs1: 1, funct3: 011 = SLTIU, rd: 3:
-- 1000 0000 0000 0000 1011 0001 1001 0000 => 8000B190

-- Sin tener en cuenta el signo, se setea X3 a 0x0 pues X1 (0x0FF) es mayor que 0x0FE.
-- 27=0x1B: OPIMM: 00100, offset: 0x0FE, rs1: 1, funct3: 011 = SLTIU, rd: 3:
-- 0000 1111 1110 0000 1011 0001 1001 0000 => 0FE0B190


-- SLTU
-- Sin tener en cuenta el signo, se setea X3 a 0x1 pues X2 (0x04) es menor que X1 (0xFF).
-- 28=0x1C: OP: 01100, funct7: 0x00, rs2: 1, rs1: 2, funct3: 011 = SLTU, rd: 3:
-- 0000 0000 0001 0001 0011 0001 1011 0000 => 001131B0

-- Sin tener en cuenta el signo, se setea X3 a 0x0 pues X1 (0xFF) es mayor que X2 (0x04).
-- 29=0x1D: OP: 01100, funct7: 0x00, rs2: 2, rs1: 1, funct3: 011 = SLTU, rd: 3:
-- 0000 0000 0010 0000 1011 0001 1011 0000 => 0020B1B0001131B0


-- LUI
-- Sumar a la parte alta de X0 (0) 0x80004 y cargarlo en el registro 4.
-- 30=0x1E: LUI: 01011, offset: 0x80004, rd: 4:
-- 1000 0000 0000 0000 0100 0010 0011 0100 => 80004234

-- Sumar a la parte alta de X0 (0) 0x80003 y cargarlo en el registro 5.
-- 31=0x1F: LUI: 01011, offset: 0x80003, rd: 5:
-- 1000 0000 0000 0000 0011 0010 1011 0100 => 800032B4

-- Sumar a la parte alta de X0 (0) 4 y cargarlo en el registro 6.
-- 32=0x20: LUI: 01011, offset: 0x00004, rd: 6:
-- 0000 0000 0000 0000 0100 0011 0011 0100 => 00004334

-- Sumar a la parte alta de X0 (0) 3 y cargarlo en el registro 7.
-- 33=0x21: LUI: 01011, offset: 0x00003, rd: 7:
-- 0000 0000 0000 0000 0011 0011 1011 0100 => 000033B4

-- SLT
-- Teniendo en cuenta el signo, se setea X3 a 0x0 pues X4 (0x80004000) es mayor que X5 (0x80003000).
-- 34=0x22: OP: 01100, funct7: 0x00, rs2: 5, rs1: 4, funct3: 010 = SLT, rd: 3:
-- 0000 0000 0101 0010 0010 0001 1011 0000 => 005221B0

-- Teniendo en cuenta el signo, se setea X3 a 0x1 pues X5 (0x80003000) es menor que X4 (0x80004000).
-- 35=0x23: OP: 01100, funct7: 0x00, rs2: 4, rs1: 5, funct3: 010 = SLT, rd: 3:
-- 0000 0000 0100 0010 1010 0001 1011 0000 => 0042A1B0

-- Teniendo en cuenta el signo, se setea X3 a 0x0 pues X6 (0x00004000) es mayor que X7 (0x00003000).
-- 36=0x24: OP: 01100, funct7: 0x00, rs2: 7, rs1: 6, funct3: 010 = SLT, rd: 3:
-- 0000 0000 0111 0011 0010 0001 1011 0000 => 007321B0

-- Teniendo en cuenta el signo, se setea X3 a 0x1 pues X7 (0x00003000) es menor que X6 (0x00004000).
-- 37=0x25: OP: 01100, funct7: 0x00, rs2: 6, rs1: 7, funct3: 010 = SLT, rd: 3:
-- 0000 0000 0110 0011 1010 0001 1011 0000 => 0063A1B0


-- STORE
-- Guardar el dato del registro X3 (1) en la posicion 0+65 (256) de la memoria RAM.
-- 38=0x26: STORE: 01000, offset: 65, rs2: 3, rs1: 0, funct3: 010 = SW:
-- 0000 0100 0011 0000 0010 0000 1010 0000 => 043020A0


-- AUIPC

-- JALR?

-- BRANCH --> 6?


X"0080006C", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"04002080", X"00400110", X"0330C190", X"0330F190", X"F330E190", X"00409190", X"0040D190", X"4040D190", 
X"002081B0", X"402081B0", X"0020E1B0", X"0020C1B0", X"0020F1B0", X"002091B0", X"0020D1B0", X"4020D1B0", 
X"8000A190", X"0FE12190", X"8000B190", X"0FE0B190", X"001131B0", X"0020B1B0", X"80004234", X"800032B4", 
X"00004334", X"000033B4", X"005221B0", X"0042A1B0", X"007321B0", X"0063A1B0", X"043020A0", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 
X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", X"00000001", 

-- Datos:
X"000000FF", X"FFFFFFFF",

others => X"00000000"
);

end package ram4k_init;

