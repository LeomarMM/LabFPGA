--*************************************************************************************
--
--	Módulo		:	CRC8
-- Descrição	:	Componente para o cálculo do código CRC de oito bits, implementação
-- usando registradores de deslocamento.
--
--	Para gerar um código, deve-se alimentar o dado pelo digito mais significativo
-- para o menos significativo, adicionando-se oito zeros no final da sequência.
-- 
-- Caso esse componente seja alimentado com uma sequência de dados junto de seu código CRC,
-- a saida desse componente deve ser zero, caso contrário, os dados estarão corrompidos.
--
-- Parâmetros Genéricos:
--
--					polynomial		--> Polinômio gerador.
--						ex.: Para x^8+x^5+x^4+1, usar 2#00110001# ou 16#31#
--						Ao escrever o polinômio, x^4 é omitido.
--
--					initial_value	--> Valor de reset dos registradores.
--					final_xor		--> Esse valor e o valor calculado serão alimentados a uma porta XOR
--						e retornados como resultado final.
--
--	Entradas:
--					i_DATA			--> Entrada para sequência de dados.
--					i_CLK				--> Clock global.
--					i_RST				--> Reset assíncrono.
--
--	Saídas:
--					o_CRC				--> Código CRC da sequência.
--
--*************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CRC8 is
generic
(
	polynomial		:	integer range 0 to 255 := 16#31#;
	initial_value	:	std_logic_vector(7 downto 0) := (OTHERS => '0');
	final_xor		:	std_logic_vector(7 downto 0) := (OTHERS => '0')
);
port
(
	i_DATA	:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	i_ENA		:	in	std_logic;
	o_CRC		:	out std_logic_vector(7 downto 0)
);
end CRC8;

architecture behavioral of CRC8 is
	constant c_poly	:	std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(polynomial, 8));
	signal r_CRC		:	std_logic_vector(7 downto 0);
begin
	process(i_CLK, i_RST, i_ENA, i_DATA)
	begin
		if(i_RST = '1') then
			r_CRC <= initial_value;
		elsif(rising_edge(i_CLK) and i_ENA = '1') then
			r_CRC(0) <= r_CRC(7) xor i_DATA;
			for i in 1 to 7 loop
				if(c_poly(i) = '1') then
					r_CRC(i) <= r_CRC(7) xor r_CRC(i-1);
				else
					r_CRC(i) <= r_CRC(i-1);
				end if;
			end loop;
		end if;
	end process;
	o_CRC <= r_CRC xor final_xor;
end behavioral;