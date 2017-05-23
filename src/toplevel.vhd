library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity toplevel is
    Port(
    	E_reloj:    in std_logic := '0'
    );
end toplevel; 


architecture estructural of toplevel is
    
    -- Componentes:
    Component cu
	Port(
	    E_reloj:        in std_logic;
	    E_act:          in std_logic;
	    --E_ocupado:      in std_logic;
	    E_resultado:    in std_logic_vector(XLEN-1 downto 0);
	    E_ram_bDat:     in std_logic_vector(XLEN-1 downto 0);
	    E_codigoOp:     in std_logic_vector(4 downto 0);
	    E_fun3:         in std_logic_vector(2 downto 0);
	    E_fun7:         in std_logic_vector(6 downto 0);
	    E_reg_sel1:     in std_logic_vector(log2XLEN-1 downto 0);
	    E_reg_sel2:     in std_logic_vector(log2XLEN-1 downto 0);
	    E_reg_dest:     in std_logic_vector(log2XLEN-1 downto 0);
	    E_inmediato:    in std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
	    S_alu_act:      out std_logic;
	    S_decoder_act:  out std_logic;
	    S_instruccion:  out std_logic_vector(XLEN-1 downto 0);
	    S_alu_op:       out std_logic_vector(3 downto 0);
	    S_mux_immOReg1: out std_logic;
	    S_mux_immOReg2: out std_logic;
	    S_mux_datImm1:  out std_logic_vector(XLEN-1 downto 0);
	    S_mux_datImm2:  out std_logic_vector(XLEN-1 downto 0);
	    S_ram_op:       out std_logic;
	    S_ram_act:      out std_logic;
	    S_ram_bDir:     out std_logic_vector(XLEN-1 downto 0);
	    S_ram_bDat:     out std_logic_vector(XLEN-1 downto 0);
	    S_reg_act:      out std_logic;
	    S_reg_op:       out std_logic;
	    S_reg_sel1:     out std_logic_vector(log2XLEN-1 downto 0);
	    S_reg_sel2:     out std_logic_vector(log2XLEN-1 downto 0);
	    --S_reg_selD:     out std_logic_vector(log2XLEN-1 downto 0);
	    S_reg_dato:     out std_logic_vector(XLEN-1 downto 0)
	);
    end component;

    Component decoder
	port(
	    E_reloj:        in std_logic;
	    E_act:          in std_logic;
	    E_instruccion:  in std_logic_vector(XLEN-1 downto 0);
	    S_reg_sel1:     out std_logic_vector(4 downto 0);
	    S_reg_sel2:     out std_logic_vector(4 downto 0);
	    S_reg_dest:     out std_logic_vector(4 downto 0);
	    S_inmediato:    out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
	    S_codigoOp:     out std_logic_vector(4 downto 0);
	    S_fun3:         out std_logic_vector(2 downto 0);
	    S_fun7:         out std_logic_vector(6 downto 0)
	);
    end component;
	 
    component ram4k
	port (
	    I_CLK, I_Enable, I_WR: in std_logic;
	    I_Address, I_Data: in std_logic_vector(XLEN-1 downto 0);
	    O_Data: out std_logic_vector(XLEN-1 downto 0)
	    --O_Busy: out std_logic
	);
    end component;
	
    component alu
	port(
    	 funcion: in std_logic_vector(3 downto 0);
    	 op1, op2: in std_logic_vector(XLEN-1 downto 0);
    	 enable: in std_logic;
    	 resultado: out std_logic_vector(XLEN-1 downto 0):= XLEN_CERO
	);
    end component;
	
    component registros
	Port(
	    E_Reloj: in std_logic;
	    E_Enable: in std_logic;
	    E_CodOP: in std_logic;
	    E_Sel1: in std_logic_vector(4 downto 0);-- Seleccion del primer registro. Se usa tambien para indicar destino en el SW
	    E_Sel2: in std_logic_vector(4 downto 0);-- Seleccion del segundo registro. 
	    E_Dato: in std_logic_vector(XLEN-1 downto 0); -- Dato a guardar para el SW
	    S_Registro1: out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO; -- Salida registro 1 (LW)
	    S_Registro2: out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO  -- Salida registro 2 (LW)
	    --S_OCUPADO: out std_logic --BIT QUE INDICA SI SE ESTA HACIENDO UNA ACCION O NO. Indica si la tarea se ha acabado
	);
    end component;

    component muxXLEN2a1
	port(
	    i0	: in    std_logic_vector(XLEN-1 downto 0);
	    i1	: in    std_logic_vector(XLEN-1 downto 0);
	    s   : in    std_logic;
            o	: out   std_logic_vector(XLEN-1 downto 0)
	);
    end component;
	

    -- Señales:
    -- Poner a cada componente un busy o poner un busy comun?
    signal busy: 	std_logic := '0';

    -- RAM.
    signal ram_act:	std_logic := '0';
    signal ram_op:	std_logic;
    signal ram_bDat_E:	std_logic_vector(XLEN-1 downto 0);
    signal ram_bDat_S:	std_logic_vector(XLEN-1 downto 0);
    signal ram_bDir_E:	std_logic_vector(XLEN-1 downto 0);

    -- Registros y mux.
    signal reg_act:	    std_logic := '0';
    signal reg_op:	    std_logic;
    signal reg_sel1:	    std_logic_vector(log2XLEN-1 downto 0);
    signal reg_sel2:	    std_logic_vector(log2XLEN-1 downto 0);
    --signal reg_selD:	    std_logic_vector(log2XLEN-1 downto 0);
    signal reg_dato:	    std_logic_vector(XLEN-1 downto 0);	
    signal mux_alu_sel1:    std_logic;
    signal mux_alu_sel2:    std_logic;
    signal reg_dat1:	    std_logic_vector(XLEN-1 downto 0);
    signal reg_dat2:	    std_logic_vector(XLEN-1 downto 0);
	
    -- ALU.
    signal alu_resultado: std_logic_vector(XLEN-1 downto 0);
    signal alu_act: std_logic := '0';
    signal alu_op: std_logic_vector(3 downto 0);
    signal alu_dat1: std_logic_vector (XLEN-1 downto 0);
    signal alu_dat2: std_logic_vector (XLEN-1 downto 0);

    -- Decoder.
    signal dec_act: std_logic := '0';
    signal dec_reg_sel1:    std_logic_vector(4 downto 0);
    signal dec_reg_sel2:    std_logic_vector(4 downto 0);
    signal dec_reg_dest:    std_logic_vector(4 downto 0);
    signal dec_inmediato:   std_logic_vector(XLEN-1 downto 0);
    signal dec_codigoOp:    std_logic_vector(4 downto 0);
    signal dec_fun3:	    std_logic_vector(2 downto 0);
    signal dec_fun7:	    std_logic_vector(6 downto 0);
    signal dec_instruccion: std_logic_vector(XLEN-1 downto 0);
	
    -- CU.
    signal act: std_logic := '1';
    signal uc_inmediato1:  std_logic_vector(XLEN-1 downto 0);	
    signal uc_inmediato2:  std_logic_vector(XLEN-1 downto 0);	
 

begin

    -- Instanciaciones.

    I_cu: cu port map(
	E_reloj => E_reloj,
	E_act => act,

	-- Aqui hay que meter la signal que recoja todos los busy
	--E_ocupado =>  '0', --(alu_busy = '1' or bus_busy = '1'),

	E_resultado	=>  alu_resultado,
	E_codigoOp	=>  dec_codigoOp,
	E_fun3		=>  dec_fun3,
	E_fun7		=>  dec_fun7,
	E_ram_bDat	=>  ram_bDat_S,
	E_reg_sel1	=>  dec_reg_sel1,
	E_reg_sel2	=>  dec_reg_sel2,
	E_reg_dest	=>  dec_reg_dest,
	E_inmediato	=>  dec_inmediato,
	S_alu_act	=>  alu_act,
	S_decoder_act	=>  dec_act,
	S_instruccion	=>  dec_instruccion,
	S_alu_op	=>  alu_op,
	S_mux_immOReg1	=>  mux_alu_sel1,
	S_mux_immOReg2	=>  mux_alu_sel2,
	S_mux_datImm1	=>  uc_inmediato1,
	S_mux_datImm2	=>  uc_inmediato2,
	S_ram_op	=>  ram_op,
	S_ram_act	=>  ram_act,
	S_ram_bDir	=>  ram_bDir_E,
	S_ram_bDat	=>  ram_bDat_E,
	S_reg_act	=>  reg_act,
	S_reg_op	=>  reg_op,
	S_reg_sel1	=>  reg_sel1,
	S_reg_sel2	=>  reg_sel2,
	--S_reg_selD	=>  reg_selD,
	S_reg_dato	=>  reg_dato
    );
	
    I_decoder: decoder port map(
	E_reloj		=>  E_reloj,
	E_act		=>  dec_act,
	E_instruccion	=>  dec_instruccion,
	S_reg_sel1	=>  dec_reg_sel1,
	S_reg_sel2	=>  dec_reg_sel2,
	S_reg_dest	=>  dec_reg_dest,
	S_inmediato	=>  dec_inmediato,
	S_codigoOp	=>  dec_codigoOp,
	S_fun3		=>  dec_fun3,
	S_fun7		=>  dec_fun7
    );

    I_alu: entity work.alu port map(
	enable	    => alu_act,
	op1	    => alu_dat1,
	op2	    => alu_dat2,
	funcion	    => alu_op,
	resultado   => alu_resultado
	--I_reset => RST_I,
	--O_busy => alu_busy,
	--O_lt	=> alu_lt,
	--O_ltu	=> alu_ltu,
	--O_eq	=> alu_eq
    );
	 
    I_mux1: muxXLEN2a1 port map(
	i0  =>	uc_inmediato1,
	i1  =>	reg_dat1,
	s   =>	mux_alu_sel1,
	o   =>	alu_dat1
    );
	 
    I_mux2: muxXLEN2a1 port map(
	i0  =>	uc_inmediato2,
	i1  =>	reg_dat2,
	s   =>	mux_alu_sel2,
	o   =>	alu_dat2
    );
		
    I_reg: registros port map(
	E_Reloj	    => E_reloj,
	E_Enable    => reg_act,
	E_CodOp	    => reg_op,
	E_Sel1	    => reg_sel1,
	E_Sel2	    => reg_sel2,
	--I_selD	    => reg_selD,
	E_Dato	    => reg_dato,
	S_Registro1 => reg_dat1,
	S_Registro2 => reg_dat2
    );
	
    I_ram: ram4k port map(
	I_CLK	    =>	E_reloj,
	I_Enable    =>	ram_act,
	I_WR	    =>	ram_op,
	I_Address   =>	ram_bDir_E,
	I_Data	    =>	ram_bDat_E,
	O_Data	    =>	ram_bDat_S
	--O_Busy: out std_logic
    );
	

    -- Proceso vacío para que todo ocurra secuencialmente
    -- a partir de la señal de reloj.
    process(E_reloj)
    begin

    end process;

end estructural;
