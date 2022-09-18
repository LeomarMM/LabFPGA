library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_DE1SoC is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 100000000;
	bytes				:	integer := 11
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_TX		:	out std_logic;
	o_LEDR	:	out std_logic_vector(9 downto 0);
	o_HEX5	:	out std_logic_vector(6 downto 0);
	o_HEX4	:	out std_logic_vector(6 downto 0);
	o_HEX3	:	out std_logic_vector(6 downto 0);
	o_HEX2	:	out std_logic_vector(6 downto 0);
	o_HEX1	:	out std_logic_vector(6 downto 0);
	o_HEX0	:	out std_logic_vector(6 downto 0)
);
end TOP_DE1SoC;

architecture rtl of TOP_DE1SoC is

	component PLL
	port
	(
		refclk   : in  std_logic := '0';
		rst      : in  std_logic := '0';
		outclk_0 : out std_logic;
		locked   : out std_logic
	);
	end component;

	component DE1SoC is
	generic
	(
		baud				:	integer := baud;
		clock				:	integer := clock
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RX		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_LEDS	:	in		std_logic_vector(9 downto 0);
		i_7S5		:	in		std_logic_vector(6 downto 0);
		i_7S4		:	in		std_logic_vector(6 downto 0);
		i_7S3		:	in		std_logic_vector(6 downto 0);
		i_7S2		:	in		std_logic_vector(6 downto 0);
		i_7S1		:	in		std_logic_vector(6 downto 0);
		i_7S0		:	in		std_logic_vector(6 downto 0);
		o_SWITCH	:	out	std_logic_vector(9 downto 0);
		o_BUTTON	:	out	std_logic_vector(3 downto 0);
		o_TX		:	out	std_logic
	);
	end component;

	signal w_CLK		: std_logic;
	signal w_LOCKED	: std_logic;
	signal w_RST		: std_logic;
	signal HEX5			: std_logic_vector(6 downto 0);
	signal HEX4			: std_logic_vector(6 downto 0);
	signal HEX3			: std_logic_vector(6 downto 0);
	signal HEX2			: std_logic_vector(6 downto 0);
	signal HEX1			: std_logic_vector(6 downto 0);
	signal HEX0			: std_logic_vector(6 downto 0);
	signal SW			: std_logic_vector(9 downto 0);
	signal KEY			: std_logic_vector(3 downto 0);
	signal LEDR			: std_logic_vector(9 downto 0);

begin
	
	w_RST <= "not"(w_LOCKED);
	o_LEDR <= LEDR;
	o_HEX5 <= HEX5;
	o_HEX4 <= HEX4;
	o_HEX3 <= HEX3;
	o_HEX2 <= HEX2;
	o_HEX1 <= HEX1;
	o_HEX0 <= HEX0;
	
	U1 : PLL
	port map
	(
		refclk	=> i_CLK,
		rst		=> i_RST,
		outclk_0	=> w_CLK,
		locked	=> w_LOCKED
	);

	U2 : DE1SoC
	port map
	(
		i_CLK		=> w_CLK,
		i_RX		=> i_RX,
		i_RST		=> w_RST,
		i_LEDS	=> LEDR,
		i_7S5		=> HEX5,
		i_7S4		=> HEX4,
		i_7S3		=> HEX3,
		i_7S2		=> HEX2,
		i_7S1		=> HEX1,
		i_7S0		=> HEX0,
		o_SWITCH	=> SW,
		o_BUTTON	=> KEY,
		o_TX		=> o_TX
	);

	LEDR <= SW;
	HEX5 <= SW(6 downto 0);
	HEX4 <= SW(6 downto 0);
	HEX3 <= SW(6 downto 0);
	HEX2 <= SW(6 downto 0);
	HEX1 <= SW(6 downto 0);
	HEX0 <= SW(6 downto 0);

end rtl;