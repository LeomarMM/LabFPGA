library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX is
	generic
	(
		baud			:	integer				:= 9600;			--	Baud padrão
		clock			:	integer				:= 50000000;	--	50MHz de clock interno padrao
		frame_size	:	integer				:=	8;				--	Quantidade de bits no enquadramento de dados
		parity		:	std_logic_vector	:= "00"			--	Paridade
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_RX		:	in		std_logic;
		o_RECV	:	out	std_logic_vector(frame_size-1 downto 0)
	);
end UART_RX;

architecture behavioral of UART_RX is

	type uart_state is (IDLE, START, RECV);
	attribute syn_encoding : string;
	attribute syn_encoding of uart_state : type is "safe";

	signal r_ND				:	std_logic;
	signal r_INTERRUPT	:	std_logic;
	signal t_STATE			:	uart_state;
	signal w_BAUD_RST		:	std_logic;
	signal w_CLK			:	std_logic;
	signal w_RECV			:	std_logic_vector(frame_size downto 0);
	signal w_RX_DOWN		:	std_logic;

	component EDGE_DETECTOR
	port
	(
		i_RST				:	in std_logic;
		i_CLK				:	in std_logic;	
		i_SIGNAL			:	in std_logic;
		o_EDGE_DOWN		:	out std_logic
	);
	end component;

	component SER2PAR
	generic
	(
		word_size	:	integer := frame_size+1
	);
	port
	(
		i_RST		:	in std_logic;
		i_CLK		:	in std_logic;
		i_ND		:	in std_logic;
		o_DATA	:	out std_logic_vector(word_size-1 downto 0);
		i_RX		:	in std_logic
	);
	end component;

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
begin

	CC1	:	COUNTER_CLK
	port map
	(
		i_CLK	=> i_CLK,
		i_RST => w_BAUD_RST,
		o_CLK => w_CLK
	);

	ED1	:	EDGE_DETECTOR
	port map
	(
		i_RST			=> i_RST,
		i_CLK			=> i_CLK,
		i_SIGNAL		=> i_RX,
		o_EDGE_DOWN => w_RX_DOWN
	);
	
	S2P	:	SER2PAR
	port map
	(
		i_RST		=>	w_BAUD_RST,
		i_CLK		=>	w_CLK,
		i_ND		=>	r_ND,
		o_DATA	=>	w_RECV,
		i_RX		=>	i_RX
	);
	
	-- Máquina de Estados
	UART_MACH	:	process(i_CLK, w_CLK, i_RX, i_RST, t_STATE, w_RX_DOWN)
	begin
		if(i_RST = '1') then
			t_STATE <= IDLE;
			w_BAUD_RST <= '1';
			r_ND <= '0';
			o_RECV <= (OTHERS => '1');
		elsif(rising_edge(i_CLK)) then
			case t_STATE is
				when IDLE	=>
					if(w_RX_DOWN = '1') then
						t_STATE <= START;
						w_BAUD_RST <= '0';
						r_ND <= '1';
					else
						t_STATE <= IDLE;
						w_BAUD_RST <= '1';
						r_ND <= '0';
					end if;
				when START	=>
					if(r_INTERRUPT = '1') then
						t_STATE <= IDLE;
						w_BAUD_RST <= '1';
						r_ND <= '0';
					elsif(w_RECV(0) = '0') then
						t_STATE <= RECV;
						w_BAUD_RST <= '0';
						r_ND <= '1';
					else
						t_STATE <= START;
						w_BAUD_RST <= '0';
						r_ND <= '1';
					end if;
				when RECV =>
					if(r_INTERRUPT = '1') then
						for i in o_RECV'range loop
							o_RECV(i) <= w_RECV(frame_size-1-i);
						end loop;
						t_STATE <= IDLE;
						w_BAUD_RST <= '1';
						r_ND <= '0';
					else
						t_STATE <= RECV;
						w_BAUD_RST <= '0';
						r_ND <= '1';
					end if;
			end case;
		end if;
	end process UART_MACH;

	-- Interruptor
	INT_RX	:	process(w_CLK, w_RECV, w_BAUD_RST, t_STATE)
	begin
		if(w_BAUD_RST = '1') then
			r_INTERRUPT <= '0';
		elsif(falling_edge(w_CLK) and (w_RECV(frame_size) = '0' or (t_STATE = START and w_RECV(0) = '1'))) then
			r_INTERRUPT <= '1';
		end if;
	end process INT_RX;

end behavioral;