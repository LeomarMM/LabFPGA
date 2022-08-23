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

	type top_state is (IDLE, RECV, FILL_BUFFER, FILL_OUTPUT, RESET_BUFFER);
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

	signal w_DATA_RX 	:	std_logic_vector(7 downto 0);
	signal w_RST		:	std_logic;
	signal w_RECV		:	std_logic;
	signal t_STATE		:	top_state;
	signal r_BUFFER	:	std_logic_vector(8*input_bytes downto 0);
	signal r_OUTPUT	:	std_logic_vector(8*input_bytes-1 downto 0);

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
	
	o_BYTES <= r_OUTPUT;
	
	-- Registrador de bufferização
	process(i_CLK, i_RST, w_RST, t_STATE, w_DATA_RX, r_BUFFER)
	begin
		if(w_RST = '1' or i_RST = '1') then
			r_BUFFER <= (0 => '1', OTHERS => '0');
		elsif(rising_edge(i_CLK) and t_STATE = FILL_BUFFER) then
			r_BUFFER <= r_BUFFER(8*(input_bytes-1) downto 0) & w_DATA_RX;
		end if;
	end process;
	
	-- Registrador de saída
	process(i_CLK, i_RST, t_STATE, w_DATA_RX, r_BUFFER, r_OUTPUT)
	begin
		if(i_RST = '1') then
			r_OUTPUT <= (OTHERS => '0');
		elsif(rising_edge(i_CLK) and t_STATE = FILL_OUTPUT) then
			r_OUTPUT <= r_BUFFER(8*input_bytes-1 downto 0);
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
						t_STATE <= FILL_OUTPUT;
					else
						t_STATE <= IDLE;
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
				w_RST <= '0';
			when RECV =>
				w_RST <= '0';
			when FILL_BUFFER =>
				w_RST <= '0';
			when FILL_OUTPUT =>
				w_RST <= '0';
			when RESET_BUFFER =>
				w_RST <= '1';
		end case;
	end process;

end behavioral;