library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

ENTITY toplevel_tb is 
end toplevel_tb;

ARCHITECTURE test of toplevel_tb is 

COMPONENT cpu_ram_toplevel
    Port(
        E_reloj: in std_logic := '0'
    );
END component;

CONSTANT E_reloj_periodo: time := 10 ns;
SIGNAL E_reloj: std_logic := '0';

BEGIN 

I1: cpu_ram_toplevel PORT MAP (E_reloj);

proc_clock: process
	begin
		E_reloj <= '0';
		wait for E_reloj_periodo/2;
		E_reloj <= '1';
		wait for E_reloj_periodo/2;
	end process;
	
end test;
