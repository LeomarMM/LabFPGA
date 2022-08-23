library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
	o_LEDS	:	out std_logic_vector(2 downto 0);
	o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
);
end TOP_MONITOR;

architecture rtl of TOP_MONITOR is

	component DEBOUNCER is
	generic
	(
		clock_hz			:	integer := 50000000;
		start_signal	:	std_logic := '1';
		time_ms			:	integer := 1
	);
	port
	(
		i_SIGNAL	:	in std_logic;
		i_CLK		:	in std_logic;
		o_SIGNAL	:	out std_logic
	);
	end component;
	
	component MONITOR_RX is
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
		o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
	);
	end component;

	signal w_RST	: std_logic;

begin

	U1 : DEBOUNCER
	port map
	(
		i_SIGNAL	=>	"not"(i_RST),
		i_CLK		=>	i_CLK,
		o_SIGNAL	=> w_RST
	);

	U2 : MONITOR_RX
	port map
	(
		i_RX		=> i_RX,
		i_CLK		=> i_CLK,
		i_RST		=> w_RST,
		o_BYTES	=> o_BYTES
	);

	o_LEDS(0) <= w_RST;
	o_LEDS(1) <= i_RX;
	o_LEDS(2) <= '1';

end rtl;