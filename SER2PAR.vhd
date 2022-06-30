--*************************************************************************************
--
-- Modulo	:	SER2PAR
-- Entradas	:
--					i_CLK			--> Clock global.
--					i_RST			--> Reset assíncrono.
--					i_ND			--> Sinal que informa o serializador para mandar um novo bit para a serial UART (RX)
-- 				i_RX			--> Dados serial recebidos da interface UART
-- Saídas:
--					o_DATA		--> Palavra de oito bits recebida.
--
--*************************************************************************************

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

entity SER2PAR is
	generic
	(
		word_size	:	integer := 8
	);
	port
	(
		i_RST		: in std_logic;
		i_CLK		: in std_logic;
		i_ND		: in std_logic;
		o_DATA	: out std_logic_vector(word_size-1 downto 0);
		i_RX		: in std_logic
	);
end SER2PAR;

architecture Behavioral of SER2PAR is
----------------------------------------------------------------------------------------------
-- Sinais internos.
----------------------------------------------------------------------------------------------
	signal w_DATA	: std_logic_vector (o_DATA'range);
----------------------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------------------

	U1 : process (i_RST, i_CLK)
	begin
		
		if (i_RST = '1') then
			w_DATA <= (others => '1');
			
		else
			if rising_edge (i_CLK) then
			
				if(i_ND = '1') then
				
					w_DATA <= w_DATA(word_size-2 downto 0) & i_RX;
		
				end if;
	
			end if;
	
		end if;

	end process U1;

	o_DATA <= w_DATA;

----------------------------------------------------------------------------------------------
end Behavioral;