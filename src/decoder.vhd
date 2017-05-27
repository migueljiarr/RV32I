library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity decoder is
    Port(
        E_reloj: 	in std_logic;
        E_act:	 	in std_logic;
        E_instruccion: 	in std_logic_vector(XLEN-1 downto 0);
        S_reg_sel1: 	out std_logic_vector(4 downto 0);
        S_reg_sel2: 	out std_logic_vector(4 downto 0);
        S_reg_dest: 	out std_logic_vector(4 downto 0);
        S_inmediato: 	out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
        S_codigoOp: 	out std_logic_vector(4 downto 0);
        S_fun3: 	out std_logic_vector(2 downto 0);
        S_fun7: 	out std_logic_vector(6 downto 0)
    );
end decoder;

architecture funcional of decoder is
    signal instruccion: std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
begin

    process(E_reloj)
    begin
        if E_reloj'EVENT and E_reloj = '1' and E_act = '1' then
            instruccion <= E_instruccion;
        end if;
    end process;

    process(instruccion)
       	variable codigoOp: std_logic_vector(4 downto 0);
       	variable fun3: std_logic_vector(2 downto 0);
       	variable fun7: std_logic_vector(6 downto 0);

    begin
    	-- Tamaño 5 puesto que según la especificación 
    	-- los últimos 2 bits de la instrucción son siempre '00'.
       	codigoOp :=  instruccion(6 downto 2);
       	fun3 :=  instruccion(14 downto 12);
       	fun7 :=  instruccion(XLEN-1 downto 25);

        S_reg_sel1 <= instruccion(19 downto 15);
        S_reg_sel2 <= instruccion(24 downto 20);
        S_reg_dest <= instruccion(11 downto 7);
            
        S_codigoOp <= codigoOp;
        S_fun3 <= fun3;
        S_fun7 <= fun7;

        case codigoOp is
            when OP_STORE =>
            -- Resize completa hasta los XLEN bits segun sea con o sin signo.
            -- http://stackoverflow.com/questions/17451492/how-to-convert-8-bits-to-16-bits-in-vhdl
                S_inmediato <= std_logic_vector(resize(signed(instruccion(31 downto 25) & instruccion(11 downto 7)), S_inmediato'length)); -- OJO 8 <= 7
            
            when OP_BRANCH =>
                S_inmediato <= std_logic_vector(resize(signed(instruccion(31) & instruccion(7) & instruccion(30 downto 25) & instruccion(11 downto 8) & '0'), S_inmediato'length));
            
            when OP_LUI | OP_AUIPC =>
                S_inmediato <= std_logic_vector(instruccion(31 downto 12) & X"000");
                    
            when OP_JAL =>
            -- 21 en lugar de 25????????????????
                S_inmediato <= std_logic_vector(resize(signed(instruccion(31) & instruccion(19 downto 12) & instruccion(20) & instruccion(30 downto 25) & instruccion(24 downto 21) & '0'), S_inmediato'length));

            when others =>
                S_inmediato <= std_logic_vector(resize(signed(instruccion(31 downto 20)), S_inmediato'length));
        end case;

    end process;

end funcional;
