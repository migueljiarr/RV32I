library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity registers is
	Port(
		E_Reloj: in std_logic;
		E_Enable: in std_logic;
		E_CodOP: in regops_t;
		E_Sel1: in std_logic_vector(4 downto 0);-- Seleccion del primer registro. Se usa tambien para indicar destino en el SW
		E_Sel2: in std_logic_vector(4 downto 0);-- Seleccion del segundo registro. 
		--I_selD: in std_logic_vector(4 downto 0);
		E_Dato: in std_logic_vector(XLEN-1 downto 0); -- Dato a guardar para el SW
		S_Registro1: out std_logic_vector(XLEN-1 downto 0) := XLEN_ZERO; -- Salida registro 1 (LW)
		S_Registro2: out std_logic_vector(XLEN-1 downto 0) := XLEN_ZERO;  -- Salida registro 2 (LW)
		S_OCUPADO: out std_logic; --BIT QUE INDICA SI SE ESTA HACIENDO UNA ACCION O NO
	);
end registers;


architecture Funcional of registers is
	--[slozanot - INI] DEBERIA IR EN EL FICHERO CONSTANTS
	type store_registros is array(0 to 31) of std_logic_vector(XLEN-1 downto 0);
	--[slozanot - FIN] DEBERIA IR EN EL FICHERO 
	signal regs: store_registros := (others => X"00000000");
	
begin

	process(E_Reloj, E_Enable, E_CodOP, E_Sel1, E_Sel2, I_selD, E_Dato)
		variable data: std_logic_vector(XLEN-1 downto 0);
	begin
		-- Si es de subida
		if rising_edge(I_clk) and I_en = '1' then
			
			data := X"00000000"; --Inicializacion de data
			
			if E_CodOP = OP_READ then
				S_OCUPADO = 1; -- Se empieza a trabajar
				S_Registro1 <= regs(to_integer(unsigned(E_Sel1)));
				S_Registro2 <= regs(to_integer(unsigned(E_Sel2)));
				--data := I_data;
				S_OCUPADO = 0; -- Se ha terminado de trabajar
			end if;

			if E_CodOP = OP_WRITE then
				S_OCUPADO = 1; -- Se empieza a trabajar
				regs(to_integer(unsigned(E_Sel1))) <= E_Dato;
				S_OCUPADO = 0; --Se termina de trabajar
			end if;
		end if;
	end process;
	
end Behavioral;
