--*************************************************************************************
--
-- Módulo		: UART_TX
-- Descrição	: Componente para transmissão de dados via UART
-- 
-- Parâmetros Genéricos:
--
--					baud			--> Velocidade de transmissão em bits por segundo.
--					clock			--> Frequência do clock global em Hertz.
--					frame_size	--> Tamanho do enquadramento de dados do pacote.
--
-- Entradas:
--					i_CLK			--> Clock global. Precisa ser mais rápido que a frequência do baud.
--					i_RST			--> Sinal de reset do componente.
--					i_LS			--> Sinal de carregamento/envio. 
--										 Em valor lógico alto, carrega o dado no serializador.
--										 Na borda de descida, inicia a transmissão do dado.
--					i_DATA		--> Dado a ser transmitido pelo módulo.
--
-- Saídas:
--					o_RTS			--> Ready To Send, indica se o módulo está disponível para transmitir.
--					o_TX			--> Saída serial do módulo.
--
--*************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is

	generic
	(
		baud			:	integer	:= 9600;			--	Baud padrão
		clock			:	integer	:= 50000000;	--	50MHz de clock interno padrao
		frame_size	:	integer	:=	8				--	Quantidade de bits no enquadramento de dados
	);
	port
	(
		i_DATA	:	in		std_logic_vector(frame_size-1 downto 0);
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_LS		:	in		std_logic;
		o_TX		:	out	std_logic;
		o_RTS		:	out	std_logic
	);

end UART_TX;

architecture behavioral of UART_TX is

	type send_state is (IDLE, SEND);
	attribute syn_encoding : string;
	attribute syn_encoding of send_state : type is "safe";

	constant phy_size	:	integer := frame_size + 2;
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
		word_size	:	integer		:= phy_size;
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
	signal w_DATA		:	std_logic_vector(phy_size-1 downto 0);
	signal w_LOAD		:	std_logic;
	signal w_LS_DOWN	:	std_logic;
	signal w_ND			:	std_logic;
	signal w_PCLK		:	std_logic;
	signal w_RST		:	std_logic;
	signal w_TX			:	std_logic;
	signal r_BITC		:	integer range 0 to phy_size+1;
	signal t_STATE		:	send_state;

begin

	CC1	:	COUNTER_CLK
	port map
	(
		i_CLK	=> i_CLK,
		i_RST => w_RST,
		o_CLK => w_CCLK
	);

	P2S	:	PAR2SER
	port map
	(
		i_RST		=> i_RST,
		i_CLK		=> w_PCLK,
		i_LOAD	=> w_LOAD,
		i_ND		=> w_ND,
		i_DATA	=> w_DATA,
		o_TX		=>	w_TX
	);

	ED1	:	EDGE_DETECTOR
	port map
	(
		i_RST				=> i_RST,
		i_CLK				=> i_CLK,
		i_SIGNAL			=> i_LS,
		o_EDGE_DOWN 	=> w_LS_DOWN
	);

	w_DATA <= '1' & i_DATA & '0';

	process(t_STATE, i_CLK, w_CCLK, w_TX)
	begin
		case t_STATE is
		when IDLE 	=>
			w_RST <= '1';
			w_LOAD <= '1';
			o_RTS <= '1';
			w_PCLK <= i_CLK;
			w_ND <= '0';
			o_TX <= '1';
		when others	=>
			w_RST <= '0';
			w_LOAD <= '0';
			o_RTS <= '0';
			w_ND <= '1';
			w_PCLK <= w_CCLK;
			o_TX <= w_TX;
		end case;
	end process;

	process(i_RST, w_PCLK, w_LS_DOWN, r_BITC)
	begin
		if(i_RST = '1') then
			t_STATE <= IDLE;
		elsif(falling_edge(w_PCLK)) then
			case t_STATE is
			
				when IDLE =>
					if(w_LS_DOWN = '1') then
						t_STATE <= SEND;
					else
						t_STATE <= IDLE;
					end if;

				when SEND =>
					if(r_BITC = phy_size) then
						t_STATE <= IDLE;
					else
						t_STATE <= SEND;
					end if;

			end case;
		end if;
	end process;

	process(i_RST, w_PCLK, t_STATE)
	begin
		if(i_RST = '1') then
			r_BITC <= 0;
		elsif(falling_edge(w_PCLK) and t_STATE = SEND) then
			if(r_BITC /= phy_size) then r_BITC <= r_BITC + 1;
			else
				r_BITC <= 0;
			end if;
		end if;
	end process;

end behavioral;