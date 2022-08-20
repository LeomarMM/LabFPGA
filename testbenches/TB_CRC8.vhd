library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_CRC8 is
end TB_CRC8;

architecture testbench of TB_CRC8 is

signal w_CLK	: std_logic;
signal w_RST	: std_logic;
signal w_DATA	: std_logic_vector(23 downto 0);
signal w_CRCIN	: std_logic;
signal w_CRCO	: std_logic_vector(7 downto 0);

component CRC8
generic
(
	polynomial		:	integer range 0 to 255 := 16#2F#;
	initial_value	:	std_logic_vector(7 downto 0) := (OTHERS => '1');
	final_xor		:	std_logic_vector(7 downto 0) := (OTHERS => '1')
);
port
(
	i_DATA	:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_CRC		:	out std_logic_vector(7 downto 0)
);
end component;

begin

	U1 : CRC8
	port map
	(
		i_DATA	=> w_CRCIN,
		i_CLK		=> w_CLK,
		i_RST		=> w_RST,
		o_CRC		=> w_CRCO
	);

	-- Gerador de Clock 
	process
	begin
		w_CLK <= '0';
		wait for 5 ns;
		w_CLK <= '1';
		wait for 5 ns;
	end process;
	
	process
	begin
		w_DATA <= "111111111100001000000000";
		w_RST <= '1';
		wait for 10 ns;
		w_RST <= '0';
		for i in 23 downto 0 loop
			w_CRCIN <= w_DATA(i);
			wait for 10 ns;
		end loop;
		w_RST <= '1';
		wait;
	end process;
	
end testbench;