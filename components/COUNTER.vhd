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

entity COUNTER is
generic
(
	max_count	:	integer := 50;
	reverse		:	std_logic := '0'
);
port
(
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	i_ENA		:	in	std_logic := '1';
	o_COUNT	:	out integer range 0 to max_count;
	o_EQ		:	out std_logic
);
end COUNTER;

architecture behavioral of COUNTER is

	signal r_COUNTER	:	integer range 0 to max_count := 0;
	signal w_EQ			:	std_logic;

begin

	o_COUNT <= r_COUNTER;
	o_EQ <= w_EQ;
	w_EQ <= '1' when ((r_COUNTER = max_count and reverse = '0') or (r_COUNTER = 0 and reverse = '1')) else '0';

	process (i_CLK, i_RST, w_EQ, r_COUNTER)
	begin
		if(i_RST = '1') then
			if(reverse = '0') then 
				r_COUNTER <= 0;
			else
				r_COUNTER <= max_count;
			end if;
		elsif(rising_edge(i_CLK)) then
			if((w_EQ = '0' and i_ENA = '1')) then
				if(reverse = '0') then 
					r_COUNTER <= (r_COUNTER + 1);
				else
					r_COUNTER <= (r_COUNTER - 1);
				end if;
			end if;
		end if;
	end process;

end behavioral;