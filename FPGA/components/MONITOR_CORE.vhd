--*************************************************************************************
--
--	Módulo		:	MONITOR
-- Descrição	:	Componente de atuação e leitura sobre os pinos do FPGA
--	Entradas:
--					i_RX				--> Sinal de recepção da UART.
--					i_CLK				--> Clock global.
--					i_RST				--> Reset assíncrono.
--	Saídas:
--					o_TX				--> Sinal de transmissão da UART.
--					o_PINS			--> Sinal de saída para os pinos à serem controlados.
--
--*************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.machine_states_common.all;

entity MONITOR_CORE is
generic
(
	baud		:	integer;
	clock		:	integer;
	bytes		:	integer
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	i_PINS	:	in std_logic_vector(8*bytes-1 downto 0);
	o_TX		:	out std_logic;
	o_PINS	:	out std_logic_vector(8*bytes-1 downto 0)
);
end MONITOR_CORE;

architecture behavioral of MONITOR_CORE is

	constant output_size : integer := 8*bytes;
	component CONTROLLER
	generic
	(
		clock		:	integer := clock;
		bytes		:	integer := bytes
	);
	port 
	(
		i_CLK			:		in		std_logic;
		i_PINS		:		in		std_logic_vector(8*bytes-1 downto 0);
		i_RECV		:		in		std_logic;
		i_RST			:		in		std_logic;
		i_RTS			:		in		std_logic;
		i_RX			:		in		std_logic_vector(7 downto 0);
		o_LS			:		out	std_logic;
		o_MEM			:		out	std_logic_vector(8*bytes-1 downto 0);
		o_MEM_ENA	:		out	std_logic;
		o_TX			:		out	std_logic_vector(7 downto 0)
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

	signal w_DATA_RX 		:	std_logic_vector(7 downto 0);
	signal w_LS				:	std_logic;
	signal w_OUTPUT_ENA	:	std_logic;
	signal w_RECV			:	std_logic;
	signal w_RTS			:	std_logic;
	signal w_TX				:	std_logic_vector(7 downto 0);
	signal r_OUTPUT		:	std_logic_vector(output_size-1 downto 0) := (OTHERS => '0');
	signal w_MEM			:	std_logic_vector(8*bytes-1 downto 0);
begin
	U1 : CONTROLLER
	port map
	(
		i_CLK			=> i_CLK,
		i_PINS		=>	i_PINS,
		i_RECV		=> w_RECV,
		i_RST			=> i_RST,
		i_RTS			=> w_RTS,
		i_RX			=> w_DATA_RX,
		o_LS			=> w_LS,
		o_MEM			=> w_MEM,
		o_MEM_ENA	=> w_OUTPUT_ENA,
		o_TX			=> w_TX
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
		i_DATA	=> w_TX,
		i_CLK		=> i_CLK,
		i_RST		=> i_RST,
		i_LS		=> w_LS,
		o_TX		=>	o_TX,
		o_RTS		=>	w_RTS
	);
	
	-- Registradores de saída
	process(i_CLK, i_RST)
	begin
		if(i_RST = '1') then
			r_OUTPUT <= (OTHERS => '0');
		elsif(falling_edge(i_CLK)) then
			if(w_OUTPUT_ENA = '1') then
				r_OUTPUT <= w_MEM;
			end if;
		end if;
	end process;
	
	-- Atribuições de saída
	o_PINS <= r_OUTPUT;

end behavioral;