library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is

	generic
	(
		baud			:	integer				:= 9600;			--	Baud padrão
		clock			:	integer				:= 50000000;	--	50MHz de clock interno padrao
		frame_size	:	integer				:=	8				--	Quantidade de bits no enquadramento de dados
	);
	port
	(
		i_DATA	:	in		std_logic_vector(frame_size-1 downto 0);
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_LS		:	in		std_logic;
		o_TX		:	out	std_logic
	);

end UART_TX;

architecture behavioral of UART_TX is

	component COUNTER_CLK
	generic
	(
		max_count	:	integer := clock / (2*baud)
	);
	port
	(
		i_CLK	:	in std_logic;
		i_RST	:	in std_logic;
		o_CLK	:	out std_logic
	);
	end component;

	component EDGE_DETECTOR
	port
	(
		i_RST				:	in std_logic;
		i_CLK				:	in std_logic;	
		i_SIGNAL			:	in std_logic;
		o_EDGE_UP		:	out std_logic;
		o_EDGE_DOWN		:	out std_logic
	);
	end component;

	component PAR2SER
	generic
	(
		word_size	:	integer		:= frame_size+2;
		rst_val		:	std_logic	:= '1'
	);
	port
	(
		i_RST		: in std_logic;
		i_CLK		: in std_logic;
		i_LOAD	: in std_logic;
		i_ND		: in std_logic;
		i_DATA	: in std_logic_vector(word_size-1 downto 0);
		o_TX		: out std_logic
	);
	end component;

	signal w_CCLK		:	std_logic;
	signal w_DATA		:	std_logic_vector(frame_size+1 downto 0);
	signal w_DATA_INV	:	std_logic_vector(i_DATA'range);
	signal w_ND			:	std_logic;
	signal w_PCLK		:	std_logic;
	signal w_RST		:	std_logic;
	signal w_TX			:	std_logic;

begin

	CC1	:	COUNTER_CLK
	port map
	(
		i_CLK	=> i_CLK,
		i_RST => W_RST,
		o_CLK => w_CCLK
	);

	P2S	:	PAR2SER
	port map
	(
		i_RST		=> i_RST,
		i_CLK		=> w_PCLK,
		i_LOAD	=> i_LS,
		i_ND		=> w_ND,
		i_DATA	=> w_DATA,
		o_TX		=>	w_TX
	);

	FLIP_INPUT : for i in i_DATA'range generate
		w_DATA_INV(i) <= i_DATA(frame_size-1-i);
	end generate;

	w_DATA <= '0' & w_DATA_INV & '1';
	w_ND <= not i_LS;
	w_RST <= i_LS or i_RST;

	with i_LS select
		w_PCLK <= i_CLK when '1',
		w_CCLK when others;

	with i_LS select
		o_TX <= '1' when '1',
		w_TX when others;

end behavioral;