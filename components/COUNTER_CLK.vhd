--*************************************************************************************
--
-- Módulo		: COUNTER_CLK
-- Descrição	: Componente para geraçao de clock por contador
-- 
-- Parâmetros Genéricos:
--
--					max_count	--> Contagem a ser alcançada para alternação do nível do clock
--
-- Entradas:
--					i_CLK			--> Sinal de clock para o contador.
--					i_RST			--> Sinal de reset do componente.
--
-- Saídas:
--					o_CLK			--> Sinal de clock de saída baseada no estouro da contagem.
--
--*************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COUNTER_CLK is
generic
(
	max_count	:	integer
);
port
(
	i_CLK	:	in std_logic;
	i_RST	:	in std_logic;
	o_CLK	:	out std_logic
);
end COUNTER_CLK;

architecture behavioral of COUNTER_CLK is
	signal r_CLK_COUNTER	:	integer range 0 to max_count;
	signal r_CLK			:	std_logic;
begin

	o_CLK <= r_CLK;
	process (i_CLK, i_RST)
	begin
		if(i_RST = '1') then
			r_CLK_COUNTER <= 0;
			r_CLK <= '0';

		elsif(rising_edge(i_CLK)) then

			if(r_CLK_COUNTER = max_count) then
				r_CLK_COUNTER <= 0;
				r_CLK <= not r_CLK;
			else r_CLK_COUNTER <= r_CLK_COUNTER + 1;
			end if;
		end if;
	end process;

end behavioral;