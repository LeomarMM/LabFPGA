library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity USER_VHDL is
generic
(
	clock			:	integer := 50000000
);
port
(
	i_CLK		:	in		std_logic;
	i_RST		:	in		std_logic;
	i_SW		:	in		std_logic_vector(9 downto 0);
	i_KEY		:	in		std_logic_vector(3 downto 0);
	o_LEDR	:	out	std_logic_vector(9 downto 0);
	o_HEX5	:	out	std_logic_vector(6 downto 0);
	o_HEX4	:	out	std_logic_vector(6 downto 0);
	o_HEX3	:	out	std_logic_vector(6 downto 0);
	o_HEX2	:	out	std_logic_vector(6 downto 0);
	o_HEX1	:	out	std_logic_vector(6 downto 0);
	o_HEX0	:	out	std_logic_vector(6 downto 0)
);
end USER_VHDL;

architecture rtl of USER_VHDL is
begin

	o_HEX5 <= "1111111";
	o_HEX4 <= "1111111";
	o_HEX3 <= "1111111";
	o_HEX2 <= "1111111";
	o_HEX1 <= "1111111";
	o_HEX0 <= "1111111";
	
	o_LEDR(9 downto 2) <= "11111100";
	o_LEDR(0) <= i_SW(0) AND i_SW(1);
	o_LEDR(1) <= i_SW(2) OR i_SW(3);

end rtl;