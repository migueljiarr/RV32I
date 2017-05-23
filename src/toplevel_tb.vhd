library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity toplevel_tb is 
end toplevel_tb;

architecture test of toplevel_tb is 

component toplevel
    port(
        E_reloj:    in std_logic := '0'
    );
end component;

constant E_reloj_periodo: time := 10 ns;
signal E_reloj: std_logic := '0';

begin 

i1: toplevel PORT MAP (E_reloj);

proc_clock: process
begin
    E_reloj <= '0';
    wait for E_reloj_periodo/2;
    E_reloj <= '1';
    wait for E_reloj_periodo/2;
end process;

end test;
