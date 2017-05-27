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
      E_reloj:    in std_logic := '0';
	  	S_top_uc_alu_act:      out std_logic;
	   S_top_uc_decoder_act:  out std_logic;
	   S_top_uc_instruccion:  out std_logic_vector(XLEN-1 downto 0);
	   S_top_uc_alu_op:       out std_logic_vector(3 downto 0);
	   S_top_uc_mux_immOReg1: out std_logic;
      S_top_uc_mux_immOReg2: out std_logic;
      S_top_uc_mux_datImm1:  out std_logic_vector(XLEN-1 downto 0);
      S_top_uc_mux_datImm2:  out std_logic_vector(XLEN-1 downto 0);
      S_top_uc_ram_op:       out std_logic;
      S_top_uc_ram_act:      out std_logic;
      S_top_uc_ram_bDir:     out std_logic_vector(XLEN-1 downto 0);
      S_top_uc_ram_bDat:     out std_logic_vector(XLEN-1 downto 0);
      S_top_uc_reg_act:      out std_logic;
      S_top_uc_reg_op:       out std_logic;
      S_top_uc_reg_sel1:     out std_logic_vector(log2XLEN-1 downto 0);
      S_top_uc_reg_sel2:     out std_logic_vector(log2XLEN-1 downto 0);
      S_top_uc_reg_dato:     out std_logic_vector(XLEN-1 downto 0);
		S_top_dec_reg_sel1:     out std_logic_vector(4 downto 0);
	   S_top_dec_reg_sel2:     out std_logic_vector(4 downto 0);
	   S_top_dec_reg_dest:     out std_logic_vector(4 downto 0);
	   S_top_dec_inmediato:    out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
	   S_top_dec_codigoOp:     out std_logic_vector(4 downto 0);
	   S_top_dec_fun3:         out std_logic_vector(2 downto 0);
	   S_top_dec_fun7:         out std_logic_vector(6 downto 0);
		S_top_ram_Data: out std_logic_vector(XLEN-1 downto 0);
		S_top_alu_resultado: out std_logic_vector(XLEN-1 downto 0):= XLEN_CERO;
		S_top_reg_Registro1: out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO; -- Salida registro 1 (LW)
	   S_top_reg_Registro2: out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO  -- Salida registro 2 (LW)
    );
end component;

constant E_reloj_periodo: time := 10 ns;
signal E_reloj: std_logic := '0';
signal S_top_uc_alu_act: std_logic;
signal	   S_top_uc_decoder_act: std_logic;
signal S_top_uc_instruccion: std_logic_vector(XLEN-1 downto 0);
signal	   S_top_uc_alu_op:        std_logic_vector(3 downto 0);
signal	   S_top_uc_mux_immOReg1:  std_logic;
signal      S_top_uc_mux_immOReg2:  std_logic;
signal      S_top_uc_mux_datImm1:   std_logic_vector(XLEN-1 downto 0);
signal      S_top_uc_mux_datImm2:   std_logic_vector(XLEN-1 downto 0);
signal      S_top_uc_ram_op:        std_logic;
signal      S_top_uc_ram_act:       std_logic;
signal      S_top_uc_ram_bDir:      std_logic_vector(XLEN-1 downto 0);
signal      S_top_uc_ram_bDat:      std_logic_vector(XLEN-1 downto 0);
signal      S_top_uc_reg_act:       std_logic;
signal      S_top_uc_reg_op:        std_logic;
signal      S_top_uc_reg_sel1:      std_logic_vector(log2XLEN-1 downto 0);
signal      S_top_uc_reg_sel2:      std_logic_vector(log2XLEN-1 downto 0);
signal      S_top_uc_reg_dato:      std_logic_vector(XLEN-1 downto 0);
signal		S_top_dec_reg_sel1:     std_logic_vector(4 downto 0);
signal	   S_top_dec_reg_sel2:     std_logic_vector(4 downto 0);
signal	   S_top_dec_reg_dest:     std_logic_vector(4 downto 0);
signal	   S_top_dec_inmediato:    std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;
signal	   S_top_dec_codigoOp:     std_logic_vector(4 downto 0);
signal	   S_top_dec_fun3:         std_logic_vector(2 downto 0);
signal	   S_top_dec_fun7:         std_logic_vector(6 downto 0);
signal		S_top_ram_Data: std_logic_vector(XLEN-1 downto 0);
signal		S_top_alu_resultado: std_logic_vector(XLEN-1 downto 0):= XLEN_CERO;
signal		S_top_reg_Registro1: std_logic_vector(XLEN-1 downto 0) := XLEN_CERO; -- Salida registro 1 (LW)
signal	   S_top_reg_Registro2: std_logic_vector(XLEN-1 downto 0) := XLEN_CERO;  -- Salida registro 2 (LW)

begin 

i1: toplevel PORT MAP (E_reloj,S_top_uc_alu_act,S_top_uc_decoder_act,S_top_uc_instruccion,S_top_uc_alu_op,
S_top_uc_mux_immOReg1,S_top_uc_mux_immOReg2,S_top_uc_mux_datImm1,S_top_uc_mux_datImm2,S_top_uc_ram_op,
S_top_uc_ram_act,S_top_uc_ram_bDir,S_top_uc_ram_bDat,S_top_uc_reg_act,S_top_uc_reg_op,S_top_uc_reg_sel1,
S_top_uc_reg_sel2,S_top_uc_reg_dato,S_top_dec_reg_sel1,S_top_dec_reg_sel2,S_top_dec_reg_dest,S_top_dec_inmediato,
S_top_dec_codigoOp,S_top_dec_fun3,S_top_dec_fun7,S_top_ram_Data,S_top_alu_resultado,S_top_reg_Registro1,
S_top_reg_Registro2);

proc_clock: process
begin
    E_reloj <= '0';
    wait for E_reloj_periodo/2;
    E_reloj <= '1';
    wait for E_reloj_periodo/2;
end process;

end test;
