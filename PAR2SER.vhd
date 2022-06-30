--*************************************************************************************
--
-- Modulo	:	PAR2SER
-- Entradas	:
--					i_CLK		--> Clock global.
--					i_RST		--> Reset assíncrono da FPGA.
--					i_DATA	--> Palavra de 8 bits que será serializada.
--					i_LOAD	--> Pulso pra carregar o serializador com a palavra.
--					i_ND		--> Sinal que informa o serializador para mandar um novo bit para a serial UART (TX)
-- Saídas:
--					o_TX		--> Conteúdo serializado.
--
--*************************************************************************************

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

entity PAR2SER is
	port
	(
		i_RST		: in std_logic;
		i_CLK		: in std_logic;
		i_LOAD	: in std_logic;
		i_ND		: in std_logic;
		i_DATA	: in std_logic_vector(7 downto 0);
		o_TX		: out std_logic
	);
end PAR2SER;

architecture Behavioral of PAR2SER is
----------------------------------------------------------------------------------------------
-- Sinais internos.
----------------------------------------------------------------------------------------------
	signal w_DATA	: std_logic_vector (i_DATA'range);
	signal w_ND		: std_logic;
----------------------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------------------
-- Serializador ( Bit mais significativo primeiro).
----------------------------------------------------------------------------------------------
	U1 : process (i_CLK, i_RST)
	begin

		if(i_RST = '1') then
			w_ND <= '0';
		elsif falling_edge(i_CLK) then
			if(i_ND = '1') then
				o_TX <= w_DATA(7);
				w_ND <= '1';
			else
				w_ND <= '0';
			end if;
		end if;

	end process U1;
	
	-- Carregando/deslocando o dado no serializador

	U2 : process (i_CLK)
	begin

		if rising_edge(i_CLK) then
			if(i_LOAD = '1') then
				w_DATA <= i_DATA;

			elsif(w_ND = '1') then
				w_DATA <= w_DATA(6 downto 0) & '0';
			end if;
		end if;

	end process U2;

----------------------------------------------------------------------------------------------
end Behavioral;