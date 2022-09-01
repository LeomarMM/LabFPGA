library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_MONITOR is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 100000000;
	input_bytes		:	integer := 11
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_TX		:	out std_logic;
	o_RST		:	out std_logic;
	o_BYTES	:	out std_logic_vector(8 downto 0)
);
end TOP_MONITOR;

architecture rtl of TOP_MONITOR is

	component PLL
	port 
	(
		refclk   : in  std_logic := '0';
		rst      : in  std_logic := '0';
		outclk_0 : out std_logic;
		locked   : out std_logic
	);
	end component;
	
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
		o_TX		:	out std_logic;
		o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
	);
	end component;

	signal w_CLK	: std_logic;
	signal w_RST	: std_logic;
	signal w_BYTES	: std_logic_vector(8*input_bytes-1 downto 0);

begin
	
	U1 : PLL
	port map
	(
		refclk	=> i_CLK,
		rst		=> i_RST,
		outclk_0	=> w_CLK,
		locked	=> w_RST
	);

	U2 : MONITOR_RX
	port map
	(
		i_RX		=> i_RX,
		i_CLK		=> w_CLK,
		i_RST		=> "not"(w_RST),
		o_TX		=>	o_TX,
		o_BYTES	=> w_BYTES
	);

	o_BYTES <= w_BYTES(8 downto 0);
	o_RST	<=	w_RST;

end rtl;