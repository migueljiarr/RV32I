library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity cu is
    Port(
        E_reloj:    in std_logic;
        E_busDat:   in std_logic_vector(31 downto 0);
        E_act:	    in std_logic;
        E_ocupado:  in std_logic;
        E_codigoOp: in std_logic_vector(4 downto 0);
        E_fun3:	    in std_logic_vector(2 downto 0);
        E_fun7:	    in std_logic_vector(6 downto 0);
        -- enable signals for components
        S_alu_act:	out std_logic;
        S_fetcher_act:	out std_logic;
        S_instruccion:	out std_logic_vector(31 downto 0);
        O_pcuen:	out std_logic;
        O_regen:	out std_logic;
        -- op selection for devices
        S_alu_op:	out aluops_t;
        O_pcuop:	out pcuops_t;
        O_regop:	out regops_t;
        -- muxer selection signals
        O_mux_alu_dat1_sel: out integer range 0 to MUX_ALU_DAT1_PORTS-1;
        O_mux_alu_dat2_sel: out integer range 0 to MUX_ALU_DAT2_PORTS-1;
        O_mux_bus_addr_sel: out integer range 0 to MUX_BUS_ADDR_PORTS-1;
        O_mux_reg_data_sel: out integer range 0 to MUX_REG_DATA_PORTS-1;
	-- Para la RAM.
        S_busDir:	out std_logic_vector(31 downto 0);
        S_busDat:	out std_logic_vector(31 downto 0);
    );
end cu;

architecture funcional of cu is
    type estados_t is (FETCH, DECODE, REGREAD, JAL, JAL2, JALR, JALR2, LUI, AUIPC, OP, OPIMM, STORE, STORE2, LOAD, LOAD2, BRANCH, BRANCH2, REGWRITEBUS, REGWRITEALU, PCNEXT, PCREGIMM, PCIMM, PCUPDATE_FETCH);
begin
    
    process(E_reloj, E_act, E_ocupado, E_codigoOp, E_fun3, E_fun7)
        variable estadoSig,estado: estados_t := FETCH;
        variable pc: signed := 0;
    begin
    
	-- OJO CON ESTO:
        -- run on falling edge to ensure that all control signals arrive in time
        -- for the controlled units, which run on the rising edge
	    if NOT E_reloj'STABLE and E_reloj = '1' and E_act = '1' then
        
            S_alu_act <= '0';
            S_fetcher_act <= '0';
            O_pcuen <= '0';
            O_regen <= '0';

        
            S_alu_op <= ALU_ADD;
            O_pcuop <= PCU_SETPC;
            O_regop <= REGOP_READ;
            
            
            O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
            O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_S2;
            O_mux_bus_addr_sel <= MUX_BUS_ADDR_PORT_ALU; -- address by default from ALU
            O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU; -- data by default from ALU
            
            -- only forward state machine if every component is finished
            if E_ocupado = '0' then
                estado := estadoSig;
            end if;
            
        
            case estado is

                when FETCH =>
                    -- fetch next instruction, use the address the program counter unit (PCU) emits
		    S_busDir <= pc;
                    estadoSig := DECODE;

		when DECODE =>
                    S_instruccion <= E_busDat;
                    S_fetcher_act <= '1';
                    estadoSig := REGREAD;

                when REGREAD =>
                    O_regen <= '1';
                    O_regop <= REGOP_READ;
                    case E_codigoOp is
                        when OP_OP =>             estadoSig := OP;
                        when OP_OPIMM =>         estadoSig := OPIMM;
                        when OP_LOAD =>        estadoSig := LOAD;
                        when OP_STORE =>        estadoSig := STORE;
                        when OP_JAL =>            estadoSig := JAL;
                        when OP_JALR =>         estadoSig := JALR;
                        when OP_BRANCH =>        estadoSig := BRANCH;
                        when OP_LUI =>            estadoSig := LUI;
                        when OP_AUIPC =>        estadoSig := AUIPC;
			-- Si desconocemos la instrucción, cojemos la siguiente.
                        when others =>         estadoSig := PCNEXT;
                    end case;
                
                when OP =>
                    S_alu_act <= '1';
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_S2;
                    case E_fun3 is
                        when FUNC_ADD_SUB =>
                            if E_fun7(5) = '0' then
                                S_alu_op <= ALU_ADD;
                            else
                                S_alu_op <= ALU_SUB;
                            end if;
                        when FUNC_SLL =>             S_alu_op <= ALU_SLL;
                        when FUNC_SLT =>             S_alu_op <= ALU_SLT;
                        when FUNC_SLTU =>         S_alu_op <= ALU_SLTU;
                        when FUNC_XOR    =>         S_alu_op <= ALU_XOR;
                        when FUNC_SRL_SRA =>
                            if E_fun7(5) = '0' then
                                S_alu_op <= ALU_SRL;
                            else
                                S_alu_op <= ALU_SRA;
                            end if;
                        when FUNC_OR =>             S_alu_op <= ALU_OR;
                        when FUNC_AND =>             S_alu_op <= ALU_AND;
                        when others => null;
                    end case;
                    estadoSig := REGWRITEALU;
                
                when OPIMM =>
                    S_alu_act <= '1';
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_IMM;
                    case E_fun3 is
                        when FUNC_ADDI =>            S_alu_op <= ALU_ADD;
                        when FUNC_SLLI =>            S_alu_op <= ALU_SLL;
                        when FUNC_SLTI =>            S_alu_op <= ALU_SLT;
                        when FUNC_SLTIU =>        S_alu_op <= ALU_SLTU;
                        when FUNC_XORI =>            S_alu_op <= ALU_XOR;
                        when FUNC_SRLI_SRAI =>
                            if E_fun7(5) = '0' then
                                S_alu_op <= ALU_SRL;
                            else
                                S_alu_op <= ALU_SRA;
                            end if;
                        when FUNC_ORI =>            S_alu_op <= ALU_OR;
                        when FUNC_ANDI =>            S_alu_op <= ALU_AND;
                        when others => null;
                    end case;
                    estadoSig := REGWRITEALU;
                
                when LOAD =>
                    -- compute load address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_IMM;
                    estadoSig := LOAD2;
                
                when LOAD2 =>
                    O_mux_bus_addr_sel <= MUX_BUS_ADDR_PORT_ALU;
		    --Comentado para que compile.
                    --case E_fun3 is
                        --when FUNC_LB =>        O_busop <= BUS_READB;
                        --when FUNC_LH =>        O_busop <= BUS_READH;
                        --when FUNC_LW =>        O_busop <= BUS_READW;
                        --when FUNC_LBU =>        O_busop <= BUS_READBU;
                        --when FUNC_LHU =>        O_busop <= BUS_READHU;
                        --when others => null;
                    --end case;
                    estadoSig := REGWRITEBUS;
                    
                
                when STORE =>
                    -- compute store address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_IMM;
                    estadoSig := STORE2;
                
                when STORE2 =>
                    O_mux_bus_addr_sel <= MUX_BUS_ADDR_PORT_ALU;
		    --Comentado para que compile.
                    --case E_fun3 is
                        --when FUNC_SB =>        O_busop <= BUS_WRITEB;
                        --when FUNC_SH =>        O_busop <= BUS_WRITEH;
                        --when FUNC_SW =>        O_busop <= BUS_WRITEW;
                        --when others => null;
                    --end case;
                    estadoSig := PCNEXT;
                
                when JAL =>
                    -- compute return address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_PC;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_INSTLEN;
                    estadoSig := JAL2;
                
                when JAL2 =>
                    -- write computed return address to register file
                    O_regen <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU;
                    estadoSig := PCIMM;
                
                when JALR =>
                    -- compute return address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_PC;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_INSTLEN;
                    estadoSig := JALR2;
                
                when JALR2 =>
                    -- write computed return address to register file
                    O_regen <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU;
                    estadoSig := PCREGIMM;
                
                when BRANCH =>
                    -- use ALU to compute flags
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD; -- doesn't really matter for flag computation
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_S2;
                    estadoSig := BRANCH2;
                    
                when BRANCH2 =>
                    -- make branch decision by looking at flags
                    estadoSig := PCNEXT; -- by default, don't branch
		    -- Comentado para que compile.
                    --case E_fun3 is
                        --when FUNC_BEQ =>
                            --if I_eq then
                                --estadoSig := PCIMM;
                            --end if;
                        
                        --when FUNC_BNE =>
                            --if not I_eq then
                                --estadoSig := PCIMM;
                            --end if;
                            
                        --when FUNC_BLT =>
                            --if I_lt then
                                --estadoSig := PCIMM;
                            --end if;
                        
                        --when FUNC_BGE =>
                            --if not I_lt then
                                --estadoSig := PCIMM;
                            --end if;

                        --when FUNC_BLTU =>
                            --if I_ltu then
                                --estadoSig := PCIMM;
                            --end if;
                        
                        --when FUNC_BGEU =>
                            --if not I_ltu then
                                --estadoSig := PCIMM;
                            --end if;
                        
                        --when others => null;
                    --end case;
                
                when LUI =>
                    O_regen <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_IMM;
                    estadoSig := PCNEXT;
                
                when AUIPC =>
                    -- compute PC + IMM on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_PC;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_IMM;
                    estadoSig := REGWRITEALU;
                    
                when REGWRITEBUS =>
                    O_regen <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_BUS;
                    estadoSig := PCNEXT;
                
                when REGWRITEALU =>
                    O_regen <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU;
                    estadoSig := PCNEXT;
                
		-- Es necesario utilizar la ALU para esto??
		-- Yo diria que lo haga directamente, es un circuito facil.
                when PCNEXT =>
                    -- compute new value for PC: PC + INST_LEN
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= pc;
                    O_mux_alu_dat2_sel <= '4';
                    estadoSig := PCUPDATE_FETCH;
                
                when PCREGIMM =>
                    -- compute new value for PC: S1 + IMM;
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= MUX_ALU_DAT1_PORT_S1;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_IMM;
                    estadoSig := PCUPDATE_FETCH;
                
                when PCIMM =>
                    -- compute new value for PC: PC + IMM;
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    O_mux_alu_dat1_sel <= pc;
                    O_mux_alu_dat2_sel <= MUX_ALU_DAT2_PORT_IMM;
                    estadoSig := PCUPDATE_FETCH;
                
                when PCUPDATE_FETCH =>
		    -- Hasta el siguiente comentario en español deberia de sobrar todo.
                    -- load new PC value into program counter unit
                    O_pcuen <= '1';
                    O_pcuop <= PCU_SETPC;
                    
                    -- given that right now the ALU outputs the address for the next
                    -- instruction, we can also start instruction fetch
                    O_mux_bus_addr_sel <= MUX_BUS_ADDR_PORT_ALU;
                    --estadoSig := DECODE;
		    -- Como cojemos el proximo PC de la ALU????
		    -- La unica manera que se me ocurre es tomar el PC como un registro normal... :(
		    -- O_busDir <= ???
                    estadoSig := DECODE;
                    
            end case;

        end if;
    end process;

    
end funcional;
