library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity TOP_UART_RX is
port
(
	i_RX			:	in std_logic;
	i_CLK			:	in std_logic;
	i_RST			:	in std_logic;
	o_DISPLAY_0	:	out std_logic_vector(6 downto 0);
	o_DISPLAY_1	:	out std_logic_vector(6 downto 0);
	o_DISPLAY_2	:	out std_logic_vector(6 downto 0)
);
end TOP_UART_RX;

architecture rtl of TOP_UART_RX is

	component DECODER
	port
	( 
		i_NUMERO		: in  std_logic_vector(3 downto 0);
		i_RST 		: in  std_logic;
		o_DISPLAY  	: out std_logic_vector(6 downto 0)
	);
	end component;
	
	component INT2BCD
	port
	(
		i_INT		:	in integer range 0 to 255;
		o_BCD_0	:	out std_logic_vector(3 downto 0);
		o_BCD_1	:	out std_logic_vector(3 downto 0);
		o_BCD_2	:	out std_logic_vector(3 downto 0)
	);
	end component;
	
	component UART_RX
	generic
	(
		baud		:	integer	:= 115200;
		clock		:	integer	:=	50000000
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_RX		:	in		std_logic;
		o_DATA	:	out	std_logic_vector(7 downto 0)
	);
	end component;

	signal w_DATA 	:	std_logic_vector(7 downto 0);
	signal w_BCD_0	:	std_logic_vector(3 downto 0);
	signal w_BCD_1	:	std_logic_vector(3 downto 0);
	signal w_BCD_2	:	std_logic_vector(3 downto 0);
	signal w_INT	:	integer range 0 to 255;
	
begin

	w_INT <= to_integer(unsigned(w_DATA));
	U1	: UART_RX
	port map
	(
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		i_RX		=> i_RX,
		o_DATA	=>	w_DATA
	);

	U2	: INT2BCD
	port map
	(
		i_INT		=>	w_INT,
		o_BCD_0	=>	w_BCD_0,
		o_BCD_1	=>	w_BCD_1,
		o_BCD_2	=>	w_BCD_2
	);

	U3	:	DECODER
	port map
	( 
		i_NUMERO		=> w_BCD_0,
		i_RST			=> i_RST,
		o_DISPLAY	=> o_DISPLAY_0
	);

	U4	:	DECODER
	port map
	( 
		i_NUMERO		=> w_BCD_1,
		i_RST			=> i_RST,
		o_DISPLAY	=> o_DISPLAY_1
	);
	
	U5	:	DECODER
	port map
	( 
		i_NUMERO		=> w_BCD_2,
		i_RST			=> i_RST,
		o_DISPLAY	=> o_DISPLAY_2
	);

end rtl;