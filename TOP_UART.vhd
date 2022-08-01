library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity TOP_UART is
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_TX		:	out std_logic
);
end TOP_UART;

architecture behavioral of TOP_UART is

	type top_state is (IDLE, RECV, LOAD, SEND_INIT, SEND);
	attribute syn_encoding : string;
	attribute syn_encoding of top_state : type is "safe";

	component UART_RX
	generic
	(
		baud		:	integer	:= 9600;
		clock		:	integer	:=	50000000
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_RX		:	in		std_logic;
		o_DATA	:	out	std_logic_vector(7 downto 0);
		o_RECV	:	out	std_logic
	);
	end component;

	component UART_TX is
	generic
	(
		baud			:	integer	:= 9600;
		clock			:	integer	:= 50000000
	);
	port
	(
		i_DATA	:	in		std_logic_vector(7 downto 0);
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_LS		:	in		std_logic;
		o_TX		:	out	std_logic;
		o_RTS		:	out	std_logic
	);
	end component;

	signal w_DATA_RX 	:	std_logic_vector(7 downto 0);
	signal w_DATA_TX 	:	std_logic_vector(7 downto 0);
	signal w_LS			:	std_logic;
	signal w_RTS		:	std_logic;
	signal w_RECV		:	std_logic;
	signal t_STATE		:	top_state;

begin

	URX	: UART_RX
	port map
	(
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		i_RX		=> i_RX,
		o_DATA	=>	w_DATA_RX,
		o_RECV	=>	w_RECV
	);

	UTX	:	UART_TX
	port map
	(
		i_DATA	=>	w_DATA_TX,
		i_CLK		=>	i_CLK,
		i_RST		=>	i_RST,
		i_LS		=>	w_LS,
		o_TX		=>	o_TX,
		o_RTS		=>	w_RTS
	);
	
	w_DATA_TX <= w_DATA_RX + '1';
	
	with t_STATE select w_LS <=
		'1' when IDLE,
		'1' when RECV,
		'1' when LOAD,
		'0' when SEND_INIT,
		'0' when SEND;

	process(i_CLK, i_RST, t_STATE)
	begin
		if(i_RST = '1') then
			t_STATE <= IDLE;
		elsif(falling_edge(i_CLK)) then
			case t_STATE is
				when IDLE =>
					if(w_RECV = '1') then
						t_STATE <= RECV;
					else
						t_STATE <= IDLE;
					end if;
				when RECV =>
					if(w_RECV = '0') then
						t_STATE <= LOAD;
					else
						t_STATE <= RECV;
					end if;
				when LOAD =>
					t_STATE <= SEND_INIT;
				when SEND_INIT =>
					if(w_RTS = '0') then
						t_STATE <= SEND;
					else
						t_STATE <= SEND_INIT;
					end if;
				when SEND =>
					if(w_RTS = '1') then
						t_STATE <= IDLE;
					else
						t_STATE <= SEND;
					end if;
			end case;
		end if;
	end process;

end behavioral;