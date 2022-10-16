library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_DE1SoC is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 100000000
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

	-- Declare signals and components inside this region

	component CHRONO_COUNTER
	generic
	(
		clock	:	integer := clock
	);
	port
	(
		i_RST		:	in	std_logic;
		i_CLK		:	in	std_logic;
		i_ENA		:	in std_logic;
		o_MINMSN	:	out std_logic_vector(3 downto 0);
		o_MINLSN	:	out std_logic_vector(3 downto 0);
		o_SECMSN	:	out std_logic_vector(3 downto 0);
		o_SECLSN	:	out std_logic_vector(3 downto 0);
		o_CSMSN	:	out std_logic_vector(3 downto 0);
		o_CSLSN	:	out std_logic_vector(3 downto 0)
	);
	end component;
	
	component DECODER
	port
	( 
		i_NUMERO		: in  std_logic_vector(3 downto 0);
		i_RST 		: in  std_logic;
		o_DISPLAY  	: out std_logic_vector(6 downto 0)
	);
	end component;
	
	signal w_MINMSN	:	std_logic_vector(3 downto 0);
	signal w_MINLSN	:	std_logic_vector(3 downto 0);
	signal w_SECMSN	:	std_logic_vector(3 downto 0);
	signal w_SECLSN	:	std_logic_vector(3 downto 0);
	signal w_CSMSN		:	std_logic_vector(3 downto 0);
	signal w_CSLSN		:	std_logic_vector(3 downto 0);

	-- End of signal and component declaration region
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

	-- Implement your logic inside this region

	U3 : CHRONO_COUNTER
	port map
	(
		i_RST		=>	w_RST,
		i_CLK		=>	w_CLK,
		i_ENA		=>	'1',
		o_MINMSN	=>	w_MINMSN,
		o_MINLSN	=>	w_MINLSN,
		o_SECMSN	=>	w_SECMSN,
		o_SECLSN	=>	w_SECLSN,
		o_CSMSN	=> w_CSMSN,
		o_CSLSN	=> w_CSLSN
	);
	
	DEC_HEX5 : DECODER
	port map
	(
		i_NUMERO		=>	w_MINMSN,
		i_RST			=> w_RST,
		o_DISPLAY	=> HEX5
	);

	DEC_HEX4 : DECODER
	port map
	(
		i_NUMERO		=>	w_MINLSN,
		i_RST			=> w_RST,
		o_DISPLAY	=> HEX4
	);

	DEC_HEX3 : DECODER
	port map
	(
		i_NUMERO		=>	w_SECMSN,
		i_RST			=> w_RST,
		o_DISPLAY	=> HEX3
	);

	DEC_HEX2 : DECODER
	port map
	(
		i_NUMERO		=>	w_SECLSN,
		i_RST			=> w_RST,
		o_DISPLAY	=> HEX2
	);

	DEC_HEX1 : DECODER
	port map
	(
		i_NUMERO		=>	w_CSMSN,
		i_RST			=> w_RST,
		o_DISPLAY	=> HEX1
	);

	DEC_HEX0 : DECODER
	port map
	(
		i_NUMERO		=>	w_CSLSN,
		i_RST			=> w_RST,
		o_DISPLAY	=> HEX0
	);

	LEDR <= SW;

	-- End of logic implementation region

end rtl;