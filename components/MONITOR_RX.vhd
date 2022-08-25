library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity MONITOR_RX is
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
end MONITOR_RX;

architecture behavioral of MONITOR_RX is

	type top_state is (IDLE, RECV, FILL_BUFFER, CRC_CALC, CRC_CHECK, FILL_OUTPUT, RESET_BUFFER);
	attribute syn_encoding : string;
	attribute syn_encoding of top_state :  type is "safe";
	
	constant buffer_size : integer := 8*(input_bytes+1);
	constant output_size : integer := 8*input_bytes;

	component CRC8
	generic
	(
		polynomial		:	integer range 0 to 255 := 16#2F#
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

	signal w_BUF_ENA	:	std_logic;
	signal w_BUF_RST	:	std_logic;
	signal w_BUF_CRC	:	std_logic_vector(buffer_size-1 downto 0);
	signal w_CNT_ENA	:	std_logic;
	signal w_CNT_RST	:	std_logic;
	signal w_CRC_DATA	:	std_logic;
	signal w_CRC_ENA	:	std_logic;
	signal w_CRC_OUT	:	std_logic_vector(7 downto 0);
	signal w_CRC_RST	:	std_logic;
	signal w_DATA_RX 	:	std_logic_vector(7 downto 0);
	signal w_RECV		:	std_logic;
	signal t_STATE		:	top_state;
	signal r_BUFFER	:	std_logic_vector(buffer_size downto 0);
	signal r_COUNTER	:	integer range 0 to buffer_size-1;
	signal r_OUTPUT	:	std_logic_vector(output_size-1 downto 0);

begin

	o_BYTES <= r_OUTPUT;
	w_BUF_CRC <= r_BUFFER(buffer_size-1 downto 8) & x"00";
	w_CRC_DATA <= w_BUF_CRC(r_COUNTER);

	U1	: CRC8
	port map
	(
		i_DATA	=> w_CRC_DATA,
		i_CLK		=> "not"(i_CLK),
		i_RST		=> w_CRC_RST,
		i_ENA		=>	w_CRC_ENA,
		o_CRC		=> w_CRC_OUT
	);

	U2	: UART_RX
	port map
	(
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		i_RX		=> i_RX,
		o_DATA	=>	w_DATA_RX,
		o_RECV	=>	w_RECV
	);
	
	
	-- Registrador de bufferização
	process(i_CLK, i_RST, w_BUF_RST, t_STATE, w_DATA_RX, r_BUFFER)
	begin
		if(w_BUF_RST = '1' or i_RST = '1') then
			r_BUFFER <= (0 => '1', OTHERS => '0');
		elsif(rising_edge(i_CLK) and t_STATE = FILL_BUFFER) then
			r_BUFFER <= r_BUFFER(output_size downto 0) & w_DATA_RX;
		end if;
	end process;
	
	-- Registrador de contagem
	process(i_CLK, i_RST, w_CNT_ENA, w_CNT_RST, t_STATE)
	begin
		if(w_CNT_RST = '1') then
			r_COUNTER <= buffer_size-1;
		elsif(rising_edge(i_CLK) and w_CNT_ENA = '1') then
			r_COUNTER <= r_COUNTER - 1;
		end if;
	end process;
	
	-- Registrador de saída
	process(i_CLK, i_RST, t_STATE, r_BUFFER)
	begin
		if(i_RST = '1') then
			r_OUTPUT <= (OTHERS => '0');
		elsif(rising_edge(i_CLK) and t_STATE = FILL_OUTPUT) then
			r_OUTPUT <= r_BUFFER(buffer_size-1 downto 8);
		end if;
	end process;
	
	process(i_CLK, i_RST, t_STATE, r_BUFFER)
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
						t_STATE <= FILL_BUFFER;
					else
						t_STATE <= RECV;
					end if;
				when FILL_BUFFER =>
					if(r_BUFFER(r_BUFFER'high) = '1') then
						t_STATE <= CRC_CALC;
					else
						t_STATE <= IDLE;
					end if;
				when CRC_CALC =>
					if(r_COUNTER = 0) then
						t_STATE <= CRC_CHECK;
					else
						t_STATE <= CRC_CALC;
					end if;
				when CRC_CHECK =>
					if(r_BUFFER(7 downto 0) = w_CRC_OUT) then
						t_STATE <= FILL_OUTPUT;
					else
						t_STATE <= RESET_BUFFER;
					end if;
				when FILL_OUTPUT =>
					t_STATE <= RESET_BUFFER;
				when RESET_BUFFER =>
					t_STATE <= IDLE;
			end case;
		end if;
	end process;
	
	process(i_CLK, i_RST, t_STATE)
	begin
		case t_STATE is
			when IDLE =>
				w_BUF_ENA <= '0';
				w_BUF_RST <= '0';
				w_CNT_ENA <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '1';
			when RECV =>
				w_BUF_ENA <= '0';
				w_BUF_RST <= '0';
				w_CNT_ENA <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '1';
			when CRC_CALC =>
				w_BUF_ENA <= '0';
				w_BUF_RST <= '0';
				w_CNT_ENA <= '1';
				w_CNT_RST <= '0';
				w_CRC_ENA <= '1';
				w_CRC_RST <= '0';
			when CRC_CHECK =>
				w_BUF_ENA <= '0';
				w_BUF_RST <= '0';
				w_CNT_ENA <= '0';
				w_CNT_RST <= '0';
				w_CRC_ENA <= '1';
				w_CRC_RST <= '0';
			when FILL_BUFFER =>
				w_BUF_ENA <= '1';
				w_BUF_RST <= '0';
				w_CNT_ENA <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '1';
			when FILL_OUTPUT =>
				w_BUF_ENA <= '0';
				w_BUF_RST <= '0';
				w_CNT_ENA <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '1';
			when RESET_BUFFER =>
				w_BUF_ENA <= '0';
				w_BUF_RST <= '1';
				w_CNT_ENA <= '0';
				w_CNT_RST <= '1';
				w_CRC_ENA <= '0';
				w_CRC_RST <= '1';
		end case;
	end process;

end behavioral;