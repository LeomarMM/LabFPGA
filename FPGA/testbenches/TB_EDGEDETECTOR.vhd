library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_EDGEDETECTOR is
end TB_EDGEDETECTOR;
architecture testbench of TB_EDGEDETECTOR is

component EDGE_DETECTOR
port
(
	i_RST				:	in std_logic;
	i_CLK				:	in std_logic;	
	i_SIGNAL			:	in std_logic;
	o_EDGE_DOWN		:	out std_logic
);
end component;
signal w_CLK : std_logic;
signal w_RST : std_logic;
signal w_SIGNAL : std_logic := '1';
signal w_OUT	: std_logic;
begin

	ETB : EDGE_DETECTOR
	port map
	(
		i_RST => w_RST,
		i_CLK => w_CLK,
		i_SIGNAL => w_SIGNAL,
		o_EDGE_DOWN => w_OUT
	);

	-- Clock
	process
	begin
		w_CLK <= '0';
		wait for 10 ns;
		w_CLK <= '1';
		wait for 10 ns;
	end process;

	-- Reset
	process
	begin
		w_RST	<= '1';
		wait until rising_edge(w_CLK);
		w_RST <= '0';
		wait;
	end process;
	
	-- Carga
	process
	begin
		wait for 10 ns;
		w_SIGNAL <= '0';
	end process;

end testbench;