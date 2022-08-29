library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_MONITOR is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 50000000;
	input_bytes		:	integer := 1
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_RX		:	out std_logic;
	o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
);
end TOP_MONITOR;

architecture rtl of TOP_MONITOR is
	
	component MONITOR_RX is
	generic
	(
		baud				:	integer := baud;
		clock				:	integer := clock;
		input_bytes		:	integer := input_bytes
	);
	port
	(
		i_RX		:	in std_logic;
		i_CLK		:	in std_logic;
		i_RST		:	in std_logic;
		o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
	);
	end component;

	signal w_RST	: std_logic;
	signal w_BYTES	: std_logic_vector(7 downto 0);

begin

	U1 : MONITOR_RX
	port map
	(
		i_RX		=> i_RX,
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		o_BYTES	=> w_BYTES
	);

	o_BYTES <= w_BYTES;
	o_RX <= i_RX;

end rtl;