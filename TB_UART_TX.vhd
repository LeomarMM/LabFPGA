library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_UART_TX is
generic
(
	baud	:	integer	:=	2100000
);
end TB_UART_TX;
architecture testbench of TB_UART_TX is

	
	component UART_TX is
	generic
	(
		baud			:	integer				:= baud;			--	Baud padrão
		clock			:	integer				:= 50000000;	--	50MHz de clock interno padrao
		frame_size	:	integer				:=	8				--	Quantidade de bits no enquadramento de dados
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
	end component;

	signal w_DATA	:	std_logic_vector(7 downto 0);
	signal w_CLK	:	std_logic;
	signal w_RST	:	std_logic;
	signal w_LS		:	std_logic;
	signal w_RTS	:	std_logic;
	signal w_TX		:	std_logic;

begin

	UTX	:	UART_TX
	port map
	(
		i_DATA	=>	w_DATA,
		i_CLK		=>	w_CLK,
		i_RST		=>	w_RST,
		i_LS		=>	w_LS,
		o_TX		=>	w_TX,
		o_RTS		=>	w_RTS
	);

	-- Clock
	process
	begin
		w_CLK <= '0';
		wait for 10 ns;
		w_CLK <= '1';
		wait for 10 ns;
	end process;

	-- Reset
	process
	begin
		w_RST	<= '1';
		wait for 10 ns;
		w_RST <= '0';
		wait;
	end process;
	
	-- Carga
	process
	begin
		w_LS <= '1';
		w_DATA <= "01001101";
		wait for 100ns;
		w_LS <= '0';
		wait for 100ns;
		w_DATA <= "11001100";
		wait on w_RTS;
		w_LS <= '1';
		wait for 30 ns;
		w_LS <= '0';
		wait;
	end process;

end testbench;