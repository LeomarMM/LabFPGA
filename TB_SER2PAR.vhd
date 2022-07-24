 library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_SER2PAR is
end TB_SER2PAR;

architecture testbench of TB_SER2PAR is

	component SER2PAR
	port
	(
		i_RST		: in std_logic;
		i_CLK		: in std_logic;
		i_ND		: in std_logic;
		o_DATA	: out std_logic_vector(7 downto 0);
		i_RX		: in std_logic
	);
	end component;
	
	signal w_RST	:	std_logic;
	signal w_CLK	:	std_logic;
	signal w_ND		:	std_logic;
	signal w_DATA	:	std_logic_vector(7 downto 0);
	signal w_RX		:	std_logic;
	signal w_FAIL	:	std_logic;

begin

	S2P	:	SER2PAR
	port map
	(
		i_RST		=> w_RST,
		i_CLK		=>	w_CLK,
		i_ND		=>	w_ND,
		o_DATA	=>	w_DATA,
		i_RX		=>	w_RX
	);
	
	-- Gerador de Clock 
	process
	begin

		w_CLK <= '0';
		wait for 5 ns;
		w_CLK <= '1';
		wait for 5 ns;
	
	end process;

	-- Reset
	process
	begin

		w_RST <= '1';
		wait for 10 ns;
		w_RST <= '0';
		wait;

	end process;
	
	
	-- Carga de Dados e Auto-teste
	process
	
		variable v_RX : STD_LOGIC_VECTOR(w_DATA'range);
		
	begin

		w_FAIL <= '0';
		w_ND <= '0';
		wait for 15 ns;

		for i in 0 to 255 loop
			
			v_RX := std_logic_vector(to_unsigned(i, w_DATA'length));
			for j in 0 to 7 loop
				
				w_RX <= v_RX(j);
				w_ND <= '1';
				wait for 5 ns;
				w_ND <= '0';
				wait for 5 ns;

			end loop;
			
			if(w_FAIL = '1' or w_DATA /= v_RX) then
				w_FAIL <= '1';
			else
				w_FAIL <= '0';
			end if;
			
		end loop;

		wait;

	end process;
	
end testbench;