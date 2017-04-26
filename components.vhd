library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux2a1 is
    port(   i0, i1, s   : in    std_logic;
            o           : out   std_logic
    );
end mux2a1;

architecture flow of mux2a1 is
begin
    o <= i0 when s='0' else i1;
end flow;

-- 2 to 1 mux with XLEN number of inputs and outputs.
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity muxXLEN2a1 is
    port(   i0, i1  : in    std_logic_vector(XLEN -1 downto 0);
            s       : in    std_logic;
            o       : out   std_logic_vector(XLEN -1 downto 0)
    );
end muxXLEN2a1;

architecture flow of muxXLEN2a1 is
begin
    o <= i0 when s='0' else i1;
end flow; 
