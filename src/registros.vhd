library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity registros is
	Port(
		E_Reloj: in std_logic;
		E_Enable: in std_logic;
		E_CodOP: in bit;
		E_Sel1: in std_logic_vector(4 downto 0);-- Seleccion del primer registro. Se usa tambien para indicar destino en el SW
		E_Sel2: in std_logic_vector(4 downto 0);-- Seleccion del segundo registro. 
		--I_selD: in std_logic_vector(4 downto 0);
		E_Dato: in std_logic_vector(XLEN-1 downto 0); -- Dato a guardar para el SW
		S_Registro1: out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO; -- Salida registro 1 (LW)
		S_Registro2: out std_logic_vector(XLEN-1 downto 0) := XLEN_CERO  -- Salida registro 2 (LW)
		--S_OCUPADO: out std_logic --BIT QUE INDICA SI SE ESTA HACIENDO UNA ACCION O NO. Indica si la tarea se ha acabado
	);
end registros;


architecture Funcional of registros is
signal regs: store_registros := (others => XLEN_CERO);
signal S_OCUPADO : std_logic;
begin

	process(E_Reloj, E_Enable, E_CodOP, E_Sel1, E_Sel2, E_Dato)
	begin
		-- Si es de subida
		if rising_edge(E_Reloj) and E_Enable = '1' then
			
			--data := X"00000000"; --Inicializacion de data
			
			if E_CodOP = '0' then
				S_OCUPADO <= '1'; -- Se empieza a trabajar
				S_Registro1 <= regs(to_integer(unsigned(E_Sel1)));
				S_Registro2 <= regs(to_integer(unsigned(E_Sel2)));
				--data := I_data;
			end if;

			if E_CodOP = '1' then
				S_OCUPADO <= '1'; -- Se empieza a trabajar
				regs(to_integer(unsigned(E_Sel1))) <= E_Dato;
				--S_OCUPADO = 0; --Se termina de trabajar. Por lo que he visto es necesario ponerlo despues de process
			end if;
		end if;
		S_OCUPADO <= '0';
	end process;
	
end Funcional;
