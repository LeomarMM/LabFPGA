library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity MONITOR is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 50000000;
	input_bytes		:	integer := 3;
	output_bytes	:	integer := 3
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_TX		:	out std_logic;
	o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
);
end MONITOR;

architecture behavioral of MONITOR is

	type top_state is (IDLE, RECV, SAVE);
	attribute syn_encoding : string;
	attribute syn_encoding of top_state :  type is "safe";

	component UART_RX
	generic
	(
		baud	:	integer	:= baud;
		clock	:	integer	:=	clock
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
		baud	:	integer	:= baud;
		clock	:	integer	:= clock
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
	signal w_VRST		:	std_logic;
	signal t_STATE		:	top_state;
	signal r_RX			:	std_logic_vector(8*input_bytes-1 downto 0);

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
		i_LS		=>	'1',
		o_TX		=>	o_TX,
		o_RTS		=>	w_RTS
	);
	
	w_DATA_TX <= w_DATA_RX + '1';
	o_BYTES <= r_RX;

	process(i_CLK, i_RST, t_STATE)
		variable v_RX : std_logic_vector(8*input_bytes downto 0);
	begin
		if(i_RST = '1') then
			t_STATE <= IDLE;
			v_RX := (0 => '1', OTHERS => '0');
			r_RX <= (OTHERS => '0');
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
						t_STATE <= SAVE;
					else
						t_STATE <= RECV;
					end if;
				when SAVE =>
					v_RX := v_RX(8*(input_bytes-1) downto 0) & w_DATA_RX;
					if(v_RX(v_RX'high) = '1') then
						r_RX <= v_RX(8*input_bytes-1 downto 0);
						v_RX := (0 => '1', OTHERS => '0');
						t_STATE <= IDLE;
					else
						t_STATE <= IDLE;
					end if;
			end case;
		end if;
	end process;

end behavioral;