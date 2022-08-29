--*************************************************************************************
--
-- Módulo		: UART_RX
-- Descrição	: Componente para recepção de dados via UART
-- 
-- Parâmetros Genéricos:
--
--					baud			--> Velocidade de recepção em bits por segundo.
--					clock			--> Frequência do clock global em Hertz.
--					frame_size	--> Tamanho do enquadramento de dados do pacote.
--
-- Entradas:
--					i_CLK			--> Clock global. Precisa ser mais rápido que a frequência do baud.
--					i_RST			--> Sinal de reset do componente.
--					i_RX			--> Entrada do sinal do transmissor, recepção é iniciada na borda de descida
--
-- Saídas:
--					o_DATA		--> Dado recebido na última transmissão.
--					o_RECV		--> Utilizado para indicar se o componente está recebendo dados.
--
--*************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX is
	generic
	(
		baud			:	integer				:= 9600;			--	Baud padrão
		clock			:	integer				:= 50000000;	--	50MHz de clock interno padrao
		frame_size	:	integer				:=	8				--	Quantidade de bits no enquadramento de dados
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_RX		:	in		std_logic;
		o_DATA	:	out	std_logic_vector(frame_size-1 downto 0);
		o_RECV	:	out	std_logic
	);
end UART_RX;

architecture behavioral of UART_RX is

	type recv_state is (IDLE, START, RECV);
	attribute syn_encoding : string;
	attribute syn_encoding of recv_state : type is "safe";

	signal w_ND				:	std_logic;
	signal t_STATE			:	recv_state;
	signal w_RST			:	std_logic;
	signal w_CCLK			:	std_logic;
	signal w_PCLK			:	std_logic;
	signal w_DATA			:	std_logic_vector(frame_size downto 0);
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
		i_RST => w_RST,
		o_CLK => w_CCLK
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
		i_RST		=>	w_RST,
		i_CLK		=>	w_CCLK,
		i_ND		=>	w_ND,
		o_DATA	=>	w_DATA,
		i_RX		=>	i_RX
	);

	-- Saídas Dependentes dos Estados
	process(t_STATE, i_CLK, w_CCLK)
	begin
		case t_STATE is
			when IDLE =>
				o_RECV <= '0';
				w_RST <= '1';
				w_ND <= '0';
				w_PCLK <= i_CLK;
			when START =>
				o_RECV <= '1';
				w_RST <= '0';
				w_ND <= '1';
				w_PCLK <= w_CCLK;
			when RECV =>
				o_RECV <= '1';
				w_RST <= '0';
				w_ND <= '1';
				w_PCLK <= w_CCLK;
		end case;
	end process;
	
	-- Transição de Estados
	UART_MACH : process(w_PCLK, i_RX, i_RST, t_STATE, w_RX_DOWN)
	begin
		if(i_RST = '1') then
			t_STATE <= IDLE;
		elsif(falling_edge(w_PCLK)) then
			case t_STATE is
				when IDLE	=>
					if(w_RX_DOWN = '1') then
						t_STATE <= START;
					else
						t_STATE <= IDLE;
					end if;
				when START	=>
					if(w_DATA(frame_size) = '1') then
						t_STATE <= IDLE;
					elsif(w_DATA(frame_size) = '0') then
						t_STATE <= RECV;
					else
						t_STATE <= START;
					end if;
				when RECV =>
					if(w_DATA(0) = '0') then
						t_STATE <= IDLE;
					else
						t_STATE <= RECV;
					end if;
			end case;
		end if;
	end process UART_MACH;
	
	process(i_CLK, i_RST, w_DATA, t_STATE)
	begin
		if(i_RST = '1') then
			o_DATA <= (OTHERS => '1');
		elsif(falling_edge(i_CLK) and w_DATA(0) = '0') then
			o_DATA <= w_DATA(frame_size downto 1);
		end if;
	end process;

end behavioral;