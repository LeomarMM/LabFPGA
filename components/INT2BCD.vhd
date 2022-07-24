--*************************************************************************************
--
-- Modulo	:	INT2BCD
--
-- Desenvolvido apenas para testes, revisar método de conversão se necessário
-- para entregas finais
-- 
-- Entradas	:
--					i_INT			--> Inteiro a ser convertido para BCD
-- Saídas:
--					o_BCD_0		--> Saída do dígito menos significativo
--					o_BCD_1		--> Saída do dígito do meio
--					o_BCD_2		--> Saída do dígito mais significativo
--
--*************************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity INT2BCD is
port
(
	i_INT		:	in integer range 0 to 255;
	o_BCD_0	:	out std_logic_vector(3 downto 0);
	o_BCD_1	:	out std_logic_vector(3 downto 0);
	o_BCD_2	:	out std_logic_vector(3 downto 0)
);
end INT2BCD;

architecture behavioral of INT2BCD is
type bcd_vector is array(2 downto 0) of integer range 0 to 9;
signal BCD : bcd_vector;
begin
	process(i_INT, BCD)
	variable i_MOD	:	integer range 0 to 9;
	variable i_DIV	:	integer range 0 to 255;
	begin
		i_DIV := i_INT;
		for i in 0 to 2 loop
			i_MOD := i_DIV mod 10;
			i_DIV := i_DIV / 10;
			BCD(i) <= i_MOD;
		end loop;
	o_BCD_0 <= std_logic_vector(to_unsigned(BCD(0), o_BCD_0'length));
	o_BCD_1 <= std_logic_vector(to_unsigned(BCD(1), o_BCD_1'length));
	o_BCD_2 <= std_logic_vector(to_unsigned(BCD(2), o_BCD_2'length));
	end process;
end behavioral;