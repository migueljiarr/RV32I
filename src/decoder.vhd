library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity decoder is
    Port(
        I_clock: 	in std_logic;
        I_enable: 	in std_logic;
        I_instruction: 	in std_logic_vector(XLEN-1 downto 0);
        O_regsel1: 	out std_logic_vector(4 downto 0);
        O_regsel2: 	out std_logic_vector(4 downto 0);
        O_regdest: 	out std_logic_vector(4 downto 0);
        O_immediate: 	out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
        O_opcode: 	out std_logic_vector(4 downto 0);
        O_funct3: 	out std_logic_vector(2 downto 0);
        O_funct7: 	out std_logic_vector(6 downto 0)
    );
end decoder;

architecture funcional of decoder is
    signal instruction: std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
begin

    process(I_clock)
    begin
        if NOT I_clock'STABLE and I_clock = '1' and I_enable = '1' then
            instruction <= I_instruction;
        end if;
    end process;

    process(instruction)
       	variable opcode: std_logic_vector(4 downto 0);
       	variable funct3: std_logic_vector(2 downto 0);
       	variable funct7: std_logic_vector(6 downto 0);

    begin
    	-- Tamaño 5 puesto que según la especificación 
    	-- los últimos 2 bits de la instrucción son siempre '00'.
       	opcode :=  instruction(6 downto 2);
       	funct3 :=  instruction(14 downto 12);
       	funct7 :=  instruction(XLEN-1 downto 25);

        O_regsel1 <= instruction(19 downto 15);
        O_regsel2 <= instruction(24 downto 20);
        O_regdest <= instruction(11 downto 7);
            
        O_opcode <= opcode;
        O_funct3 <= funct3;
        O_funct7 <= funct7;

        case opcode is
            when OP_STORE =>
            -- Resize completa hasta los XLEN bits según sea con o sin signo.
            -- http://stackoverflow.com/questions/17451492/how-to-convert-8-bits-to-16-bits-in-vhdl
                O_immediate <= std_logic_vector(resize(signed(instruction(31 downto 25) & instruction(11 downto 7)), O_immediate'length)); -- OJO 8 <= 7
            
            when OP_BRANCH =>
                -- SB-type
                O_immediate <= std_logic_vector(resize(signed(instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0'), O_immediate'length));
            
            when OP_LUI | OP_AUIPC =>
                -- U-type
                O_immediate <= std_logic_vector(instruction(31 downto 12) & X"000");
                    
            when OP_JAL =>
                -- UJ-type
            -- 21 en lugar de 25????????????????
                O_immediate <= std_logic_vector(resize(signed(instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 25) & instruction(24 downto 21) & '0'), O_immediate'length));

            when others =>
                -- I-type and R-type
                -- immediate carries no actual meaning for R-type instructions
                O_immediate <= std_logic_vector(resize(signed(instruction(31 downto 20)), O_immediate'length));
        end case;

    end process;

end funcional;
