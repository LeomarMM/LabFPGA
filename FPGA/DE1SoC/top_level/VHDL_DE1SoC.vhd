library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VHDL_DE1SoC is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 50000000
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
end VHDL_DE1SoC;

architecture rtl of VHDL_DE1SoC is

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

	signal HEX5			: std_logic_vector(6 downto 0);
	signal HEX4			: std_logic_vector(6 downto 0);
	signal HEX3			: std_logic_vector(6 downto 0);
	signal HEX2			: std_logic_vector(6 downto 0);
	signal HEX1			: std_logic_vector(6 downto 0);
	signal HEX0			: std_logic_vector(6 downto 0);
	signal SW			: std_logic_vector(9 downto 0);
	signal KEY			: std_logic_vector(3 downto 0);
	signal LEDR			: std_logic_vector(9 downto 0);

	-- Declare signals and components inside this region


	-- End of signal and component declaration region

begin
	
	o_LEDR <= LEDR;
	o_HEX5 <= HEX5;
	o_HEX4 <= HEX4;
	o_HEX3 <= HEX3;
	o_HEX2 <= HEX2;
	o_HEX1 <= HEX1;
	o_HEX0 <= HEX0;
	
	U1 : DE1SoC
	port map
	(
		i_CLK		=> i_CLK,
		i_RX		=> i_RX,
		i_RST		=> i_RST,
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

	-- Implement your logic inside this region


	-- End of logic implementation region

end rtl;