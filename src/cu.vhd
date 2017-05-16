library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity cu is
    Port(
	-- Entradas generales.
        E_reloj:	in std_logic;
        E_act:		in std_logic;
        E_ocupado:	in std_logic;

	-- Entradas desde la ALU.
        E_resultado:	in std_logic_vector(XLEN-1 downto 0);

	-- Entradas desde la RAM.
        E_busDat:	in std_logic_vector(XLEN-1 downto 0);

	-- Entradas desde la RAM.
        E_reg_x1:	in std_logic_vector(XLEN-1 downto 0);

	-- Entradas desde el decoder.
        E_codigoOp:	in std_logic_vector(4 downto 0);
        E_fun3:		in std_logic_vector(2 downto 0);
        E_fun7:		in std_logic_vector(6 downto 0);
	E_reg_sel1:      in std_logic_vector(4 downto 0);
        E_reg_sel2:      in std_logic_vector(4 downto 0);
        E_reg_dest:      in std_logic_vector(4 downto 0);
        E_immediato:	in std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;

        -- enable signals for components
        S_alu_act:	out std_logic;
        S_decoder_act:	out std_logic;
        S_instruccion:	out std_logic_vector(XLEN-1 downto 0);
        O_pcuen:	out std_logic;

        -- op selection for devices
        S_alu_op:	out aluops_t;
        O_pcuop:	out pcuops_t;
        O_regop:	out regops_t;

        -- muxer selection signals
        S_alu_sel1: out integer range 0 to MUX_ALU_DAT1_PORTS-1;
        S_alu_sel2: out integer range 0 to MUX_ALU_DAT2_PORTS-1;
        O_mux_bus_addr_sel: out integer range 0 to MUX_BUS_ADDR_PORTS-1;
        O_mux_reg_data_sel: out integer range 0 to MUX_REG_DATA_PORTS-1;

	-- Salidas hacia la RAM.
        S_busDir:	out std_logic_vector(XLEN-1 downto 0);
        S_busDat:	out std_logic_vector(XLEN-1 downto 0);

	-- Salidas hacia el fichero de registros.
        S_reg_act:	out std_logic;
        S_reg_op:	out std_logic;
        S_reg_sel1:	out std_logic_vector(4 downto 0);
        S_reg_sel2:	out std_logic_vector(4 downto 0);
        S_reg_selD:	out std_logic_vector(4 downto 0);
        S_reg_dato:	out std_logic_vector(4 downto 0)
    );
end cu;

architecture funcional of cu is
    type estados_t is (FETCH, DECODE, LEER_CODOP, JAL, JAL2, JALR, JALR2, LUI, AUIPC, OP, OPIMM, STORE, STORE2, LOAD, LOAD2, BRANCH, BRANCH2, REGWRITEBUS, REGWRITEALU, PC_NEXT, PC_REG_INMEDIATO, PC_INMEDIATO, PC_LEER_X1);
    signal pc: unsigned(XLEN-1 downto 0) := unsigned(XLEN_CERO);

begin
    process(E_reloj, E_act, E_ocupado, E_codigoOp, E_fun3, E_fun7)
        variable estadoSig,estado: estados_t := FETCH;
    begin
    
	-- OJO CON ESTO:
        -- run on falling edge to ensure that all control signals arrive in time
        -- for the controlled units, which run on the rising edge.
	    if NOT E_reloj'STABLE and E_reloj = '0' and E_act = '1' then
        
            S_alu_act <= '0';
            S_decoder_act <= '0';
            O_pcuen <= '0';
            S_reg_act <= '0';

        
            S_alu_op <= ALU_ADD;
            O_pcuop <= PCU_SETPC;
            O_regop <= REGOP_READ;
            
            
            S_alu_sel1 <= MUX_ALU_DAT1_PORT_S1;
            S_alu_sel2 <= MUX_ALU_DAT2_PORT_S2;
            O_mux_bus_addr_sel <= MUX_BUS_ADDR_PORT_ALU; -- address by default from ALU
            O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU; -- data by default from ALU
            
            -- Avanzamos al siguiente estado si ninguno de 
	    -- los componentes nos dice que está ocupado.
            if E_ocupado = '0' then
                estado := estadoSig;
            end if;
            
        
            case estado is

		-- Estado necesario??
                when FETCH =>
                    -- Pide a la RAM una nueva instrucción en la dirección
		    -- indicada por el PC.
		    S_busDir <= std_logic_vector(pc);
                    estadoSig := DECODE;

		when DECODE =>
		    -- Recogemos la instrucción del bus de datos y la enviamos al decoder.
                    S_instruccion <= E_busDat;
                    S_decoder_act <= '1';
                    estadoSig := LEER_CODOP;

                when LEER_CODOP =>
                    case E_codigoOp is
                        when OP_OP	=>  estadoSig := OP;
                        when OP_OPIMM	=>  estadoSig := OPIMM;
                        when OP_LOAD	=>  estadoSig := LOAD;
                        when OP_STORE	=>  estadoSig := STORE;
                        when OP_JAL	=>  estadoSig := JAL;
                        when OP_JALR	=>  estadoSig := JALR;
                        when OP_BRANCH	=>  estadoSig := BRANCH;
                        when OP_LUI	=>  estadoSig := LUI;
                        when OP_AUIPC	=>  estadoSig := AUIPC;

			-- Si desconocemos la instrucción, cojemos la siguiente.
                        when others	=>  estadoSig := PC_NEXT;
                    end case;
                
                when OP =>
                    S_alu_act <= '1';
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_S1;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_S2;
                    case E_fun3 is
                        when FUNC_ADD_SUB =>
                            if E_fun7(5) = '0' then
						    S_alu_op <= ALU_ADD;
                            else
						    S_alu_op <= ALU_SUB;
                            end if;
                        when FUNC_SLL	    =>      S_alu_op <= ALU_SLL;
                        when FUNC_SLT	    =>      S_alu_op <= ALU_SLT;
                        when FUNC_SLTU	    =>	    S_alu_op <= ALU_SLTU;
                        when FUNC_XOR	    =>	    S_alu_op <= ALU_XOR;
                        when FUNC_SRL_SRA   =>
                            if E_fun7(5) = '0' then
						    S_alu_op <= ALU_SRL;
                            else
						    S_alu_op <= ALU_SRA;
                            end if;
                        when FUNC_OR	    =>	    S_alu_op <= ALU_OR;
                        when FUNC_AND	    =>	    S_alu_op <= ALU_AND;
                        when others	    =>	    null;
                    end case;
                    estadoSig := REGWRITEALU;
                
                when OPIMM =>
                    S_alu_act <= '1';
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_S1;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_IMM;
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
                    -- Activamos los registros y la ALU de manera que en el siguiente
		    -- semiciclo los primeros cedan los datos a la segunda, realizando
		    -- esta el calculo y devolviendolo a la UC en E_resuldato.
		    -- Mux???
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    S_reg_act <= '1';
                    S_reg_op <= '1';		-- Escribir. Hace falta crear una constante.
                    S_reg_sel1 <= E_reg_sel1;
                    S_reg_sel2 <= E_reg_sel2;
                    estadoSig := LOAD2;
                
                when LOAD2 =>
                    -- Activamos el fichero de registros y le mandamos leer el dato 
		    -- calculado por la ALU y devuelto a E_resultado, según el 
		    -- tamaño indicado en la instrucción.
                    S_reg_act	<= '1';
                    S_reg_op	<= '0';		-- Leer. Hace falta crear una constante.
                    S_reg_selD	<= E_reg_dest;
                    case E_fun3 is
                        when FUNC_LB	=>  S_reg_dato <= std_logic_vector(resize(signed(E_resultado(7 downto 0)), XLEN));
                        when FUNC_LH	=>  S_reg_dato <= std_logic_vector(resize(signed(E_resultado(15 downto 0)), XLEN));
                        when FUNC_LW	=>  S_reg_dato <= std_logic_vector(resize(signed(E_resultado(31 downto 0)), XLEN));
                        when FUNC_LBU	=>  S_reg_dato <= std_logic_vector(resize(unsigned(E_resultado(7 downto 0)), XLEN));
                        when FUNC_LHU	=>  S_reg_dato <= std_logic_vector(resize(unsigned(E_resultado(15 downto 0)), XLEN));
                        when others	=>  null;
                    end case;
                    estadoSig := PC_NEXT;
                    
                
                when STORE =>
                    -- compute store address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_S1;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_IMM;
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
                    estadoSig := PC_NEXT;
                
                when JAL =>
                    -- compute return address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_PC;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_INSTLEN;
                    estadoSig := JAL2;
                
                when JAL2 =>
                    -- write computed return address to register file
                    S_reg_act <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU;
                    estadoSig := PC_INMEDIATO;
                
                when JALR =>
                    -- compute return address on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_PC;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_INSTLEN;
                    estadoSig := JALR2;
                
		-- Utilizamos el registro x1 como "registro de retorno"
		-- tal y como se indica en la especificación de RV32I (pág. 15).
                when JALR2 =>
                    -- write computed return address to register file
                    S_reg_act <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU;
                    estadoSig := PC_REG_INMEDIATO;
                
                when BRANCH =>
                    -- use ALU to compute flags
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD; -- doesn't really matter for flag computation
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_S1;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_S2;
                    estadoSig := BRANCH2;
                    
                when BRANCH2 =>
                    -- make branch decision by looking at flags
                    estadoSig := PC_NEXT; -- by default, don't branch
		    -- Comentado para que compile.
                    --case E_fun3 is
                        --when FUNC_BEQ =>
                            --if I_eq then
                                --estadoSig := PC_INMEDIATO;
                            --end if;
                        
                        --when FUNC_BNE =>
                            --if not I_eq then
                                --estadoSig := PC_INMEDIATO;
                            --end if;
                            
                        --when FUNC_BLT =>
                            --if I_lt then
                                --estadoSig := PC_INMEDIATO;
                            --end if;
                        
                        --when FUNC_BGE =>
                            --if not I_lt then
                                --estadoSig := PC_INMEDIATO;
                            --end if;

                        --when FUNC_BLTU =>
                            --if I_ltu then
                                --estadoSig := PC_INMEDIATO;
                            --end if;
                        
                        --when FUNC_BGEU =>
                            --if not I_ltu then
                                --estadoSig := PC_INMEDIATO;
                            --end if;
                        
                        --when others => null;
                    --end case;
                
                when LUI =>
                    S_reg_act <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_IMM;
                    estadoSig := PC_NEXT;
                
                when AUIPC =>
                    -- compute PC + IMM on ALU
                    S_alu_act <= '1';
                    S_alu_op <= ALU_ADD;
                    S_alu_sel1 <= MUX_ALU_DAT1_PORT_PC;
                    S_alu_sel2 <= MUX_ALU_DAT2_PORT_IMM;
                    estadoSig := REGWRITEALU;
                    
                when REGWRITEBUS =>
                    S_reg_act <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_BUS;
                    estadoSig := PC_NEXT;
                
                when REGWRITEALU =>
                    S_reg_act <= '1';
                    O_regop <= REGOP_WRITE;
                    O_mux_reg_data_sel <= MUX_REG_DATA_PORT_ALU;
                    estadoSig := PC_NEXT;
                
                when PC_NEXT =>
                    -- Calculamos el nuevo valor del PC en un caso 
		    -- normal, es decir el cuarto byte siguiente.
		    pc <= pc + "100";
                    estadoSig := FETCH;
                
                when PC_REG_INMEDIATO =>
                    -- Pedimos al fichero de registros que nos envíe el la suma del registro y
		    -- el inmediato que habrá que sumarle al PC en el siguiente ciclo.
                    S_reg_act <= '1';
                    S_reg_op <= '0';	    -- Leer. Hace falta crear una constante.
                    S_reg_sel1 <= "00001";  -- Leemos X1, siguiendo la convención software.
                    estadoSig := PC_LEER_X1;
                
                when PC_INMEDIATO =>
                    -- Pedimos al fichero de registros que nos envíe el inmediato
		    -- que habrá que sumarle al PC en el siguiente ciclo.
                    S_reg_act <= '1';
                    S_reg_op <= '0';	    -- Leer. Hace falta crear una constante.
                    S_reg_sel1 <= "00001";  -- Leemos X1, siguiendo la convención software.
                    estadoSig := PC_LEER_X1;

                when PC_LEER_X1 =>
		    pc	<= pc + unsigned(E_reg_x1);
                    estadoSig := FETCH;
		    
                    
            end case;

        end if;
    end process;

    
end funcional;
