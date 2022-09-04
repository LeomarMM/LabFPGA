library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MONITOR_RX is
generic
(
	baud				:	integer;
	clock				:	integer;
	input_bytes		:	integer
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_TX		:	out std_logic;
	o_BYTES	:	out std_logic_vector(8*input_bytes-1 downto 0)
);
end MONITOR_RX;

architecture behavioral of MONITOR_RX is

	type top_state is (IDLE, RECV, FILL_BUFFER, 
	CRC_FEED, CRC_CHECK, CRC_COUNT,
	START_RESPONSE, SEND_RESPONSE,
	FILL_OUTPUT, RESET_BUFFER);
	attribute syn_encoding : string;
	attribute syn_encoding of top_state :  type is "safe";
	
	constant buffer_size : integer := 8*(input_bytes+1);
	constant output_size : integer := 8*input_bytes;

	component COUNTER
	generic
	(
		max_count	:	integer := buffer_size-1;
		reverse		:	std_logic := '1'
	);
	port
	(
		i_CLK		:	in std_logic;
		i_RST		:	in std_logic;
		i_ENA		:	in std_logic;
		o_COUNT	:	out integer range 0 to max_count;
		o_EQ		:	out std_logic
	);
	end component;

	component CRC8
	generic
	(
		polynomial		:	std_logic_vector(7 downto 0) := x"2F"
	);
	port
	(
		i_DATA	:	in std_logic;
		i_CLK		:	in std_logic;
		i_RST		:	in std_logic;
		i_ENA		:	in	std_logic;
		o_CRC		:	out std_logic_vector(7 downto 0)
	);
	end component;

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

	component UART_TX
	generic
	(
		baud			:	integer	:= baud;
		clock			:	integer	:= clock
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

	constant ACK		:	std_logic_vector(7 downto 0) := x"06";
	constant NAK		:	std_logic_vector(7 downto 0) := x"15";
	signal w_BUF_RST	:	std_logic;
	signal w_BUF_CRC	:	std_logic_vector(buffer_size-1 downto 0);
	signal w_CNT_ENA	:	std_logic;
	signal w_CNT_EQ	:	std_logic;
	signal w_CNT_RST	:	std_logic;
	signal w_CNT_VAL	:	integer range 0 to buffer_size - 1;
	signal w_CRC_DATA	:	std_logic;
	signal w_CRC_ENA	:	std_logic;
	signal w_CRC_OUT	:	std_logic_vector(7 downto 0);
	signal w_CRC_RST	:	std_logic;
	signal w_DATA_RX 	:	std_logic_vector(7 downto 0);
	signal w_DATA_TX	:	std_logic_vector(7 downto 0);
	signal w_LS			:	std_logic;
	signal w_RECV		:	std_logic;
	signal w_RTS		:	std_logic;
	signal r_BUFFER	:	std_logic_vector(buffer_size downto 0) := (0 => '1', OTHERS => '0');
	signal r_OUTPUT	:	std_logic_vector(output_size-1 downto 0) := (OTHERS => '0');
	signal r_EQ			:	std_logic := '0';
	signal t_STATE		:	top_state;

begin

	o_BYTES <= r_OUTPUT;
	w_BUF_CRC <= r_BUFFER(buffer_size-1 downto 8) & x"00";
	w_CRC_DATA <= w_BUF_CRC(w_CNT_VAL);

	w_DATA_TX <= ACK when r_EQ = '1' else NAK;
	w_CNT_ENA <= '1' when t_STATE = CRC_COUNT else '0';

	CC1	:	COUNTER
	port map
	(
		i_CLK	=>	"not"(i_CLK),
		i_RST	=>	w_CNT_RST,
		i_ENA => w_CNT_ENA,
		o_EQ	=> w_CNT_EQ,
		o_COUNT => w_CNT_VAL
	);

	U1	: CRC8
	port map
	(
		i_DATA	=> w_CRC_DATA,
		i_CLK		=> "not"(i_CLK),
		i_RST		=> w_CRC_RST,
		i_ENA		=>	w_CRC_ENA,
		o_CRC		=> w_CRC_OUT
	);

	U2 : UART_RX
	port map
	(
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		i_RX		=> i_RX,
		o_DATA	=>	w_DATA_RX,
		o_RECV	=>	w_RECV
	);
	
	U3 : UART_TX
	port map
	(
		i_DATA	=> w_DATA_TX,
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		i_LS		=> w_LS,
		o_TX		=>	o_TX,
		o_RTS		=>	w_RTS
	);

	-- Registrador de bufferização
	process(i_CLK, w_BUF_RST)
	begin
		if(w_BUF_RST = '1') then
			r_BUFFER <= (0 => '1', OTHERS => '0');
		elsif(falling_edge(i_CLK)) then
			if(t_STATE = FILL_BUFFER) then
				r_BUFFER <= r_BUFFER(output_size downto 0) & w_DATA_RX;
			end if;
		end if;
	end process;
	
	
	-- Registrador de saída
	process(i_CLK, i_RST)
	begin
		if(i_RST = '1') then
			r_OUTPUT <= (OTHERS => '0');
		elsif(falling_edge(i_CLK)) then
			if(t_STATE = FILL_OUTPUT and r_EQ = '1') then
				r_OUTPUT <= r_BUFFER(buffer_size-1 downto 8);
			end if;
		end if;
	end process;
	
	-- Registrador CRC
	process(i_CLK, i_RST)
	begin
		if(i_RST = '1') then
			r_EQ <= '0';
		elsif(falling_edge(i_CLK)) then
			if(t_STATE = CRC_CHECK) then
				if(r_BUFFER(7 downto 0) = w_CRC_OUT) then
					r_EQ <= '1';
				else 
					r_EQ <= '0';
				end if;
			end if;
		end if;
	end process;
	
	-- Lógica de transição de estados
	process(i_CLK, i_RST)
	begin
		if(i_RST = '1') then
			t_STATE <= RESET_BUFFER;
		elsif(rising_edge(i_CLK)) then
			case t_STATE is
				when IDLE =>
					if(w_RECV = '1') then
						t_STATE <= RECV;
					else
						t_STATE <= IDLE;
					end if;
				when RECV =>
					if(w_RECV = '0') then
						t_STATE <= FILL_BUFFER;
					else
						t_STATE <= RECV;
					end if;
				when FILL_BUFFER =>
					if(r_BUFFER(r_BUFFER'high) = '1') then
						t_STATE <= CRC_FEED;
					else
						t_STATE <= IDLE;
					end if;
				when CRC_FEED =>
					if(w_CNT_EQ = '1') then
						t_STATE <= CRC_CHECK;
					else
						t_STATE <= CRC_COUNT;
					end if;
				when CRC_COUNT =>
						t_STATE <= CRC_FEED;
				when CRC_CHECK =>
					t_STATE <= FILL_OUTPUT;
				when FILL_OUTPUT =>
					t_STATE <= START_RESPONSE;
				when START_RESPONSE =>
					if(w_RTS = '0') then
						t_STATE <= SEND_RESPONSE;
					else
						t_STATE <= START_RESPONSE;
					end if;
				when SEND_RESPONSE =>
					if(w_RTS = '1') then
						t_STATE <= RESET_BUFFER;
					else
						t_STATE <= SEND_RESPONSE;
					end if;
				when RESET_BUFFER =>
					t_STATE <= IDLE;
			end case;
		end if;
	end process;
	
	-- Barramentos dependentes de estados
	process(t_STATE)
	begin
		case t_STATE is
			when IDLE =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '1';
				w_LS		 <= '1';
			when RECV =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when FILL_BUFFER =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when CRC_FEED =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '0';
				w_CRC_ENA <= '1';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when CRC_COUNT =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '0';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when CRC_CHECK =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '0';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when FILL_OUTPUT =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when START_RESPONSE =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '0';
			when SEND_RESPONSE =>
				w_BUF_RST <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
			when RESET_BUFFER =>
				w_BUF_RST <= '1';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '0';
				w_LS		 <= '1';
		end case;
	end process;

end behavioral;