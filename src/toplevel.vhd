library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;
use work.mux_types_pkg.all; --¿Esto donde esta?

entity cpu_toplevel_wb8 is
	Port(
		E_reloj: in std_logic := '0';
	);
end cpu_toplevel_wb8;


architecture Behavioral of cpu_toplevel_wb8 is
	
	-- Falatan todas las señales de la ram.

	signal alu_resultado: std_logic_vector(XLEN-1 downto 0);
	
	signal uc_dec_act: std_logic := '0';
	signal uc_alu_act: std_logic := '0';
	signal uc_reg_act: std_logic := '0';
	-- Esto no sabemos si hace falta, ¿La ram y los registros lo usan?
	signal uc_alu_op: aluops_t;
	signal uc_reg_op: regops_t;
	-- Esto hay que mirarlo para sustituirlo por los dos mux que nos hacen falta
	-- Lo que hay aqui va dentro de la ram y de los registros a excepcion de los data selection de la alu
	-- signal uc_mux_alu_dat1_sel: integer range 0 to MUX_ALU_DAT1_PORTS-1;
	-- signal uc_mux_alu_dat2_sel: integer range 0 to MUX_ALU_DAT2_PORTS-1;
	signal uc_mux_alu_dat1_sel: std_logic;
	signal uc_mux_alu_dat2_sel: std_logic;
	-- signal uc_mux_ram_addr_sel: integer range 0 to MUX_RAM_ADDR_PORTS-1;
	-- signal uc_mux_reg_data_sel: integer range 0 to MUX_REG_DATA_PORTS-1;

	signal dec_reg_sel1: std_logic_vector(4 downto 0);
	signal dec_reg_sel2: std_logic_vector(4 downto 0);
	signal dec_reg_dest: std_logic_vector(4 downto 0);
	signal dec_inmediato: std_logic_vector(XLEN-1 downto 0);
	signal dec_codigoOp: std_logic_vector(4 downto 0);
	signal dec_fun3: std_logic_vector(2 downto 0);
	signal dec_fun7: std_logic_vector(6 downto 0);
	
	signal reg_datoS1: std_logic_vector(XLEN-1 downto 0);	
	signal reg_datoS2: std_logic_vector(XLEN-1 downto 0);
	
	signal act: std_logic := '1';

begin
	-- Todo esto iria fuera
-- 	mux_alu_dat1_input(MUX_ALU_DAT1_PORT_S1) <= reg_dataS1;
--	mux_alu_dat1_input(MUX_ALU_DAT1_PORT_PC) <= pcu_out;
--	
--	mux_alu_dat2_input(MUX_ALU_DAT2_PORT_S2) <= reg_dataS2;
--	mux_alu_dat2_input(MUX_ALU_DAT2_PORT_IMM) <= dec_imm;
--	mux_alu_dat2_input(MUX_ALU_DAT2_PORT_INSTLEN) <= X"00000004";
	
--	mux_bus_addr_input(MUX_BUS_ADDR_PORT_ALU) <= resultado_alu;
--	mux_bus_addr_input(MUX_BUS_ADDR_PORT_PC) <= pcu_out;
	
--	mux_reg_data_input(MUX_REG_DATA_PORT_ALU) <= resultado_alu;
--	mux_reg_data_input(MUX_REG_DATA_PORT_BUS) <= bus_data;
--	mux_reg_data_input(MUX_REG_DATA_PORT_IMM) <= dec_imm;
--	mux_reg_data_input(MUX_REG_DATA_PORT_TRAPRET) <= pcu_trapret;

	-- Esto no se toca hasta que esté la ALU terminada.
	alu_instance: entity work.alu port map(
		I_clk => E_reloj,
		I_en => uc_aluen,
		I_reset => RST_I,
		I_dataS1 => mux_alu_dat1_output,
		I_dataS2 => mux_alu_dat2_output,
		I_aluop => uc_aluop,
		O_busy => alu_busy,
		O_data => resultado_alu,
		O_lt => alu_lt,
		O_ltu => alu_ltu,
		O_eq => alu_eq
	);
	
	uc_instance: entity work.control port map(
		-- Aquí faltan tanto señales como entradas a la UC.
		E_reloj => E_reloj,
		E_act => act,
	--	I_reset => RST_I,

		-- Aqui hay que meter la signal que recoja todos los busy
		E_ocupado => (alu_busy = '1' or bus_busy = '1'),

	--	I_interrupt => I_interrupt,
		E_codigoOp => dec_codigoOp,
		E_fun3 => dec_fun3,
		E_fun7 => dec_fun7,
	--	I_lt => alu_lt,
	--	I_ltu => alu_ltu,
	--	I_eq => alu_eq,
		S_decoder_act => uc_dec_act,
		S_alu_act => uc_alu_act,
	--	O_busen => uc_busen,
	--	O_pcuen => uc_pcuen,
		S_reg_act => uc_reg_act,
		S_alu_op => uc_alu_op,
	--	O_busop => uc_busop,
		S_reg_op => uc_reg_op,
	--	O_pcuop => uc_pcuop,
		S_reg_sel1 => uc_mux_alu_dat1_sel,
		S_reg_sel2 => uc_mux_alu_dat2_sel
	--	O_mux_bus_addr_sel => uc_mux_bus_addr_sel,
	--	O_mux_reg_data_sel => uc_mux_reg_data_sel
	);
	
	dec_instance: entity work.decoder port map(
		E_reloj => E_reloj,
		E_act => uc_dec_act,
		-- la instruccion viene de la UC. Falta tanto la salida como la señal por la que viaja.
		-- S_instruccion de la UC es la que hace falta conectar?
		E_instruccion => bus_data,
		S_reg_sel1 => dec_reg_sel1,
		S_reg_sel2 => dec_reg_sel2,
		S_reg_dest => dec_reg_dest,
		S_inmediato => dec_inmediato,
		S_codigoOp => dec_codigoOp,
		S_fun3 => dec_fun3,
		S_fun7 => dec_fun7
	);
	-- Esto hay que mirarlo muy despacio ¿Hemos visto los generic map?
	mux_alu_dat1: entity work.mux
	generic map(
		PORTS => MUX_ALU_DAT1_PORTS
	)
	port map(
		I_inputs => mux_alu_dat1_input,
		I_sel => uc_mux_alu_dat1_sel,
		O_output => mux_alu_dat1_output
	);
	
	mux_alu_dat2: entity work.mux
	generic map(
		PORTS => MUX_ALU_DAT2_PORTS
	)
	port map(
		I_inputs => mux_alu_dat2_input,
		I_sel => uc_mux_alu_dat2_sel,
		O_output => mux_alu_dat2_output
	);
	
	mux_bus_addr: entity work.mux
	generic map(
		PORTS => MUX_BUS_ADDR_PORTS
	)
	port map(
		I_inputs => mux_bus_addr_input,
		I_sel => uc_mux_bus_addr_sel,
		O_output => mux_bus_addr_output
	);
	
	mux_reg_data: entity work.mux
	generic map(
		PORTS => MUX_REG_DATA_PORTS
	)
	port map(
		I_inputs => mux_reg_data_input,
		I_sel => uc_mux_reg_data_sel,
		O_output => mux_reg_data_output
	);
	
	-- Esto no se toca hasta que estén los registros hechos
	reg_instance: entity work.registers port map(
		I_clk => E_reloj,
		I_en => uc_regen,
		I_op => uc_regop,
		I_selS1 => dec_rs1,
		I_selS2 => dec_rs2,
		I_selD => dec_rd,
		I_data => mux_reg_data_output,
		O_dataS1 => reg_dataS1,
		O_dataS2 => reg_dataS2
	);
	
	

	process(E_reloj)
	begin

	end process;
end Behavioral;
