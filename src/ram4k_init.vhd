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


package ram4k_init is


-- exp de la memoria 2^12
constant ADDRLEN : integer := 12;
-- array de vectores de longitud XLEN definido en constantes
type store_t is array(0 to (2**ADDRLEN)-1) of std_logic_vector(XLEN-1 downto 0);

constant RAM_INIT : store_t := (
	X"b7",X"04",X"00",X"10",X"37",X"09",X"00",X"30",X"b7",X"19",X"00",X"30",X"93",X"89",X"09",X"80",X"37",X"0a",X"00",X"20",X"23",X"28",X"09",X"04",X"83",X"02",X"1a",X"00",X"63",X"8c",X"02",X"00",X"03",X"03",X"0a",X"00",X"23",X"08",X"69",X"0e",X"83",X"02",X"2a",X"00",X"e3",X"8e",X"02",X"fe",X"23",X"00",X"6a",X"00",X"83",X"22",X"09",X"05",X"93",X"82",X"12",X"00",X"23",X"28",X"59",X"04",X"23",X"1c",X"59",X"06",X"23",X"00",X"59",X"0a",X"93",X"d2",X"02",X"01",X"23",X"a0",X"54",X"00",X"83",X"c2",X"04",X"00",X"03",X"c3",X"09",X"00",X"e3",X"80",X"62",X"fc",X"13",X"03",X"00",X"00",X"93",X"03",X"80",X"02",X"33",X"0e",X"33",X"01",X"23",X"00",X"5e",X"00",X"93",X"82",X"12",X"00",X"13",X"03",X"13",X"00",X"e3",X"18",X"73",X"fe",X"6f",X"f0",X"1f",X"fa",
others => X"00"
);


end package ram_4k_init;

