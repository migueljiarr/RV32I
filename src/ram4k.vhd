----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:42:10 05/17/2017 
-- Design Name: 
-- Module Name:    ram4k - Behavioral 
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
use work.ram4k_init.all;

-- Entradas: reloj, enable, escritura/lectura, direccion, datos
-- Salidas: datos, ram_ocupada (para la UC)
entity ram4k is
	port (
		I_CLK, I_Enable, I_WR: in std_logic;
		I_Address, I_Data: in std_logic_vector(XLEN-1 downto 0);
		O_Data: out std_logic_vector(XLEN-1 downto 0)--;
		--O_Busy: out std_logic
	);
end ram4k;


architecture Behavioral of ram4k is
	signal ram: store_t := RAM_INIT;
begin

	process (I_CLK, I_Enable)
		--variable busy: std_logic := '0';
	begin
		-- Si es flanco de subida y se le permite actuar, pone su bit de ocupado a 1, sino a 0
		if rising_edge(I_CLK) then
			if (I_Enable = '1') then
				--busy := '1';
				--En caso de poder actuar, si es escritura/lectura a 1, escribe en la ram, sino, saca un dato en la dirección proporcionada
				if (I_WR = ESCRIBIR) then
					ram(to_integer(unsigned(I_Address(ADDRLEN-1 downto 0)))) <= I_Data;
				else
					O_Data <= ram(to_integer(unsigned(I_Address(ADDRLEN-1 downto 0))));
				end if;
				--busy := '0';
			end if;
		end if;
		--O_Busy <= busy;
	end process;

end Behavioral;

