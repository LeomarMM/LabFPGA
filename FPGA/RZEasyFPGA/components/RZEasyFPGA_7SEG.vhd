library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RZEasyFPGA_7SEG is
generic 
(
	clock				:	integer := 50000000;
	ss_div			:	integer := 1000
);
port
(
	i_CLK		:	in std_logic;
	i_HEX3	:	in std_logic_vector(6 downto 0);
	i_HEX2	:	in std_logic_vector(6 downto 0);
	i_HEX1	:	in std_logic_vector(6 downto 0);
	i_HEX0	:	in std_logic_vector(6 downto 0);
	o_HEX		:	out std_logic_vector(6 downto 0);
	o_SEL		:	out std_logic_vector(3 downto 0)
);
end RZEasyFPGA_7SEG;

architecture rtl of RZEasyFPGA_7SEG is 

	signal r_SEL		: std_logic_vector(3 downto 0) := "1110";
	signal r_COUNTER	: integer range 0 to clock/ss_div := 0;
	signal r_HEX		: std_logic_vector(6 downto 0) := i_HEX0;
begin
	process(i_CLK, r_SEL)
	begin
		if(rising_edge(i_CLK)) then
			if(r_COUNTER = clock/ss_div) then
				case r_SEL is
				when "1110" => 
					r_HEX <= i_HEX1;
					r_SEL <= "1101";
				when "1101" => 
					r_HEX <= i_HEX2;
					r_SEL <= "1011";
				when "1011" => 
					r_HEX <= i_HEX3;
					r_SEL <= "0111";
				when "0111" => 
					r_HEX <= i_HEX0;
					r_SEL <= "1110";
				when others =>
					r_HEX <= i_HEX0;
					r_SEL <= "1110";
				end case;
				r_COUNTER <= 0;
			else
				r_COUNTER <= r_COUNTER + 1;
			end if;
		end if;
	end process;
	o_SEL <= r_SEL;
	o_HEX <= r_HEX;
end rtl;