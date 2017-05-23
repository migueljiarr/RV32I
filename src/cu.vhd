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
        --E_ocupado:	in std_logic;

	-- Entradas desde la ALU.
        E_resultado:	in std_logic_vector(XLEN-1 downto 0);

	-- Entradas desde la RAM.
        E_ram_bDat:	in std_logic_vector(XLEN-1 downto 0);

	-- Entradas desde el decoder.
        E_codigoOp:	in std_logic_vector(4 downto 0);
        E_fun3:		in std_logic_vector(2 downto 0);
        E_fun7:		in std_logic_vector(6 downto 0);
	E_reg_sel1:     in std_logic_vector(log2XLEN-1 downto 0);
        E_reg_sel2:     in std_logic_vector(log2XLEN-1 downto 0);
        E_reg_dest:     in std_logic_vector(log2XLEN-1 downto 0);
        E_inmediato:	in std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;

	-- Salidas hacia la ALU.
        S_alu_act:	out std_logic;
        S_alu_op:	out std_logic_vector(3 downto 0);

	-- Salidas hacia la decoder.
        S_decoder_act:	out std_logic;
        S_instruccion:	out std_logic_vector(XLEN-1 downto 0);

	-- Salidas hacia los multiplexores de entrada a la ALU.
        S_mux_immOReg1:	out std_logic;
        S_mux_immOReg2:	out std_logic;
        S_mux_datImm1:	out std_logic_vector(XLEN-1 downto 0);
        S_mux_datImm2:	out std_logic_vector(XLEN-1 downto 0);

	-- Salidas hacia la RAM.
        S_ram_op:	out std_logic;
        S_ram_act:	out std_logic;
        S_ram_bDir:	out std_logic_vector(XLEN-1 downto 0);
        S_ram_bDat:	out std_logic_vector(XLEN-1 downto 0);

	-- Salidas hacia el fichero de registros.
        S_reg_act:	out std_logic;
        S_reg_op:	out std_logic;
        S_reg_sel1:	out std_logic_vector(log2XLEN-1 downto 0);
        S_reg_sel2:	out std_logic_vector(log2XLEN-1 downto 0);
        S_reg_dato:	out std_logic_vector(XLEN-1 downto 0)
    );
end cu;

architecture funcional of cu is
    type estados_t is (FETCH, DECODE, LEER_CODOP, JAL, JAL2, JALR, JALR2, LUI, AUIPC, OP, OPIMM, STORE, STORE2, STORE3, LOAD, LOAD2, LOAD3, BRANCH, BRANCH2, WRITE_REG, PC_NEXT, PC_REG_INMEDIATO, PC_INMEDIATO, PC_ACTUALIZAR);
    signal pc: unsigned(XLEN-1 downto 0) := unsigned(XLEN_CERO);

begin
    --process(E_reloj, E_act, E_ocupado, E_codigoOp, E_fun3, E_fun7)
    process(E_reloj, E_act, E_codigoOp, E_fun3, E_fun7)
        variable estadoSig,estado: estados_t := FETCH;
        variable aux: std_logic_vector(XLEN-1 downto 0);
    begin
    
	-- OJO CON ESTO:
        -- run on falling edge to ensure that all control signals arrive in time
        -- for the controlled units, which run on the rising edge.
	    if NOT E_reloj'STABLE and E_reloj = '0' and E_act = '1' then
        
            S_alu_act <= '0';
            S_decoder_act <= '0';
            S_reg_act <= '0';
            S_alu_op <= ALU_ADD;
            
            -- Avanzamos al siguiente estado si ninguno de 
	    -- los componentes nos dice que está ocupado.
            --if E_ocupado = '0' then
                --estado := estadoSig;
            --end if;
            
        
            case estado is

                when FETCH =>
                    -- Pide a la RAM una nueva instrucción en la dirección
		    -- indicada por el PC.
		    S_ram_bDir <= std_logic_vector(pc);
		    S_ram_op <= LEER;
                    estadoSig := DECODE;

		when DECODE =>
		    -- Recogemos la instrucción del bus de datos y la enviamos al decoder.
                    S_instruccion <= E_ram_bDat;
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
                    S_alu_act	<= '1';
                    S_reg_act	    <= '1';
                    S_reg_op	    <= LEER;		-- Leer. Hace falta crear una constante.
                    S_mux_immOReg1  <= REGISTRO;		-- Registro. Hace falta una constante.
                    S_mux_immOReg2  <= REGISTRO;		-- Registro. Hace falta una constante.
                    S_reg_sel1	    <= E_reg_sel1;
                    S_reg_sel2	    <= E_reg_sel2;
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
                    estadoSig := WRITE_REG;
                
                when OPIMM =>
                    S_alu_act	    <= '1';
                    S_reg_act	    <= '1';
                    S_reg_op	    <= LEER;		-- Leer. Hace falta crear una constante.
                    S_mux_immOReg1  <= REGISTRO;		-- Registro. Hace falta una constante.
                    S_reg_sel1	    <= E_reg_sel1;
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm2    <= E_inmediato;
                    case E_fun3 is
                        when FUNC_ADDI	    =>		S_alu_op <= ALU_ADD;
                        when FUNC_SLLI	    =>		S_alu_op <= ALU_SLL;
                        when FUNC_SLTI	    =>		S_alu_op <= ALU_SLT;
                        when FUNC_SLTIU	    =>		S_alu_op <= ALU_SLTU;
                        when FUNC_XORI	    =>		S_alu_op <= ALU_XOR;
                        when FUNC_SRLI_SRAI =>
                            if E_fun7(5) = '0' then
							S_alu_op <= ALU_SRL;
                            else
							S_alu_op <= ALU_SRA;
                            end if;
                        when FUNC_ORI	    =>		S_alu_op <= ALU_OR;
                        when FUNC_ANDI	    =>		S_alu_op <= ALU_AND;
                        when others	    =>		null;
                    end case;
                    estadoSig := WRITE_REG;
                
                when LOAD =>
                    -- Activamos los registros y la ALU de manera que en el siguiente
		    -- semiciclo los primeros cedan los datos a la segunda, realizando
		    -- esta el calculo y devolviendolo a la UC en E_resuldato.
                    S_alu_act	    <= '1';
                    S_alu_op	    <= ALU_ADD;
                    S_reg_act	    <= '1';
                    S_reg_op	    <= ESCRIBIR;		-- Escribir. Hace falta crear una constante.
                    S_mux_immOReg1  <= REGISTRO;		-- Registro. Hace falta una constante.
                    S_reg_sel1	    <= E_reg_sel1;
                    S_mux_datImm2   <= E_inmediato;
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    estadoSig	    := LOAD2;
                
                when LOAD2 =>
		    -- Vamos a la RAM a recoger el dato de la dirección 
		    -- calculada en el ciclo anterior.
		    S_ram_bDir	<= E_resultado;
		    S_ram_op	<= LEER;			-- Leer. Hace falta una constante.
		    S_ram_act	<= '1';			-- Leer. Hace falta una constante.
                    estadoSig	:= LOAD3;

                when LOAD3 =>
                    -- Activamos el fichero de registros y le mandamos almacenar el
		    -- dato obtenido de memoria en el ciclo anterior, según el
		    -- tamaño indicado en la instrucción.
                    S_reg_act	<= '1';
                    S_reg_op	<= LEER;		-- Leer. Hace falta crear una constante.
                    S_reg_sel1	<= E_reg_dest;
                    case E_fun3 is
                        when FUNC_LB	=>  S_reg_dato <= std_logic_vector(resize(signed(E_ram_bDat(7 downto 0)), XLEN));
                        when FUNC_LH	=>  S_reg_dato <= std_logic_vector(resize(signed(E_ram_bDat(15 downto 0)), XLEN));
                        when FUNC_LW	=>  S_reg_dato <= std_logic_vector(resize(signed(E_ram_bDat(31 downto 0)), XLEN));
                        when FUNC_LBU	=>  S_reg_dato <= std_logic_vector(resize(unsigned(E_ram_bDat(7 downto 0)), XLEN));
                        when FUNC_LHU	=>  S_reg_dato <= std_logic_vector(resize(unsigned(E_ram_bDat(15 downto 0)), XLEN));
                        when others	=>  null;
                    end case;
                    estadoSig	:= PC_NEXT;
                    
                when STORE =>
		    -- Similar que LOAD.
                    S_alu_act	    <= '1';
                    S_alu_op	    <= ALU_ADD;
                    S_reg_act	    <= '1';
                    S_reg_op	    <= ESCRIBIR;		-- Escribir. Hace falta crear una constante.
                    S_reg_sel1	    <= E_reg_sel1;
                    S_mux_datImm2   <= E_inmediato;
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    estadoSig := STORE2;

                when STORE2 =>
		    -- Guardamos en aux la dirección donde almacenar el dato.
		    -- Para obtener el valor a almacenar, activamos la ALU y el
		    -- fichero de registros con el registro indicado, sumandole
		    -- al valor ahí guardado 0, de forma que en el siguiente ciclo
		    -- dicho valor nos aparezca en E_resultado.
		    aux		    := E_resultado;
                    S_alu_act	    <= '1';
                    S_alu_op	    <= ALU_ADD;
                    S_reg_act	    <= '1';
                    S_reg_op	    <= LEER;			-- Leer. Hace falta crear una constante.
                    S_reg_sel2	    <= E_reg_sel2;
                    S_mux_immOReg2  <= REGISTRO;			-- Registro. Hace falta una constante.
                    S_mux_immOReg1  <= INMEDIATO;			-- Immediato. Hace falta una constante.
                    S_mux_datImm1    <= XLEN_CERO;
                
                when STORE3 =>
		    -- Similar que LOAD3.
                    S_ram_op	    <= ESCRIBIR;			-- Escribir. Hace falta una constante.
                    S_ram_act	    <= '1';
                    S_ram_bDir	    <= aux;
                    case E_fun3 is
                        when FUNC_LB	=>  S_ram_bDat <= std_logic_vector(resize(signed(E_resultado(7 downto 0)), XLEN));
                        when FUNC_LH	=>  S_ram_bDat <= std_logic_vector(resize(signed(E_resultado(15 downto 0)), XLEN));
                        when FUNC_LW	=>  S_ram_bDat <= std_logic_vector(resize(signed(E_resultado(31 downto 0)), XLEN));
                        when FUNC_LBU	=>  S_ram_bDat <= std_logic_vector(resize(unsigned(E_resultado(7 downto 0)), XLEN));
                        when FUNC_LHU	=>  S_ram_bDat <= std_logic_vector(resize(unsigned(E_resultado(15 downto 0)), XLEN));
                        when others	=>  null;
                    end case;
                    estadoSig := PC_NEXT;
                
                when JAL =>
                    -- Calculamos la dirección de retorno.
                    S_alu_act	<= '1';
                    S_alu_op	<= ALU_ADD;
                    --S_reg_act	<= '1';
                    S_mux_immOReg1  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm1   <= std_logic_vector(resize(unsigned'("100"),XLEN));
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm2   <= std_logic_vector(pc);
                    estadoSig := JAL2;
                
                when JAL2 =>
                    -- Escribimos la dirección de retorno en el fichero de registros.
                    S_reg_act	<= '1';
                    S_reg_op    <= ESCRIBIR;         -- Escribir. Hace falta crear una constante.
                    S_reg_sel1  <= E_reg_dest;
                    S_reg_dato  <= E_resultado;
                    estadoSig := PC_INMEDIATO;
                
                when JALR =>
                    -- Equivalente a JAL.
                    S_alu_act	<= '1';
                    S_alu_op	<= ALU_ADD;
                    --S_reg_act	<= '1';
                    S_mux_immOReg1  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm1   <= std_logic_vector(resize(unsigned'("100"),XLEN));
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm2   <= std_logic_vector(pc);
                    estadoSig := JALR2;
                
                when JALR2 =>
                    -- Equivalente a JAL2.
                    S_reg_act	<= '1';
                    S_reg_op    <= ESCRIBIR;         -- Escribir. Hace falta crear una constante.
                    S_reg_sel1  <= E_reg_dest;
                    S_reg_dato  <= E_resultado;
                    estadoSig := PC_REG_INMEDIATO;
                
                when BRANCH =>
                    -- Usamos la ALu para comparar los registros.
                    S_alu_act	    <= '1';
		    S_reg_act	    <= '1';
                    S_reg_op	    <= LEER;
		    S_mux_immOReg1  <= REGISTRO;
		    S_mux_immOReg2  <= REGISTRO;

                    case E_fun3 is
                        when FUNC_BEQ =>
			    S_alu_op	    <= ALU_SUB;
			    S_reg_sel1	    <= E_reg_sel1;
			    S_reg_sel2	    <= E_reg_sel2;
                        when FUNC_BNE =>
			    S_alu_op	    <= ALU_SUB;
			    S_reg_sel1	    <= E_reg_sel1;
			    S_reg_sel2	    <= E_reg_sel2;
                        when FUNC_BLT =>
			    S_alu_op	    <= ALU_SLT;
			    S_reg_sel1	    <= E_reg_sel1;
			    S_reg_sel2	    <= E_reg_sel2;
                        when FUNC_BGE =>
			    S_alu_op	    <= ALU_SLT;
			    S_reg_sel1	    <= E_reg_sel2;
			    S_reg_sel2	    <= E_reg_sel1;
                        when FUNC_BLTU =>
			    S_alu_op	    <= ALU_SLTU;
			    S_reg_sel1	    <= E_reg_sel1;
			    S_reg_sel2	    <= E_reg_sel2;
                        when FUNC_BGEU =>
			    S_alu_op	    <= ALU_SLTU;
			    S_reg_sel1	    <= E_reg_sel2;
			    S_reg_sel2	    <= E_reg_sel1;
			when others => null;
                    end case;
                    estadoSig	    := BRANCH2;
                    
                when BRANCH2 =>
                    -- Hacemos la decisión según el resultado.
		    estadoSig := PC_NEXT;  -- Situación por defecto.
                    case E_fun3 is
                        when FUNC_BEQ =>
                            if E_resultado=XLEN_CERO then
                                estadoSig := PC_INMEDIATO;
                            end if;
                        
                        when FUNC_BNE =>
                            if E_resultado/=XLEN_CERO then
                                estadoSig := PC_INMEDIATO;
                            end if;
                            
                        when FUNC_BLT =>
                            if E_resultado=XLEN_UNO then
                                estadoSig := PC_INMEDIATO;
                            end if;
                        
                        when FUNC_BGE =>
                            if E_resultado=XLEN_UNO  then
                                estadoSig := PC_INMEDIATO;
                            end if;

                        when FUNC_BLTU =>
                            if E_resultado=XLEN_UNO then
                                estadoSig := PC_INMEDIATO;
                            end if;
                        
                        when FUNC_BGEU =>
                            if E_resultado=XLEN_UNO then
                                estadoSig := PC_INMEDIATO;
                            end if;
                        
                        when others =>
				estadoSig := PC_NEXT;
                    end case;
                
                when LUI =>
                    S_reg_act	<= '1';
                    S_reg_op	<= ESCRIBIR;		-- Escribir. Hace falta crear una constante.
                    S_reg_sel1	<= E_reg_dest;
                    S_reg_dato	<= E_inmediato;
                    estadoSig	:= PC_NEXT;
                
                when AUIPC =>
                    S_alu_act	<= '1';
                    S_alu_op	<= ALU_ADD;
                    S_reg_act	<= '1';
                    S_mux_immOReg1  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm1   <= E_inmediato;
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm2   <= std_logic_vector(pc);
                    estadoSig	:= WRITE_REG;
                    
                when WRITE_REG =>
                    S_reg_act	<= '1';
                    S_reg_op	<= ESCRIBIR;		-- Escribir. Hace falta crear una constante.
                    S_reg_sel1	<= E_reg_dest;
                    S_reg_dato	<= E_resultado;
                    estadoSig	:= PC_NEXT;
                
                when PC_NEXT =>
                    -- Calculamos el nuevo valor del PC en un caso 
		    -- normal, es decir el cuarto byte siguiente.
		    pc <= pc + "100";
                    estadoSig := FETCH;
                
                when PC_REG_INMEDIATO =>
		    -- Pedimos a la ALU que calcule la dirección de salto.
                    S_alu_act	    <= '1';
                    S_alu_op	    <= ALU_ADD;
                    S_reg_act	    <= '1';
                    S_reg_op	    <= LEER;		-- Leer. Hace falta crear una constante.
                    S_mux_immOReg1  <= REGISTRO;		-- Registro. Hace falta una constante.
                    S_reg_sel1	    <= E_reg_sel1;
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm2   <= E_inmediato;
                    estadoSig	    := PC_ACTUALIZAR;
                
                when PC_INMEDIATO =>
		    -- Pedimos a la ALU que calcule la dirección de salto.
                    S_alu_act	    <= '1';
                    S_alu_op	    <= ALU_ADD;
                    --S_reg_act	    <= '1';
                    --S_reg_op	    <= '0';		-- Leer. Hace falta crear una constante.
                    S_mux_immOReg1  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm1   <= std_logic_vector(pc);
                    S_mux_immOReg2  <= INMEDIATO;		-- Immediato. Hace falta una constante.
                    S_mux_datImm2   <= E_inmediato;
                    estadoSig	    := PC_ACTUALIZAR;

                when PC_ACTUALIZAR =>
		    pc	<= unsigned(E_resultado);
                    estadoSig := FETCH;
                    
            end case;

        end if;
    end process;

    
end funcional;
