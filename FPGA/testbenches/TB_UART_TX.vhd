library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_UART_TX is
generic
(
	baud			:	integer	:=	2100000;
	word_size	:	integer	:= 8
);
end TB_UART_TX;
architecture testbench of TB_UART_TX is
	
	component UART_TX is
	generic
	(
		baud			:	integer	:= baud;			--	Baud padrão
		clock			:	integer	:= 50000000;	--	50MHz de clock interno padrao
		frame_size	:	integer	:=	word_size	--	Quantidade de bits no enquadramento de dados
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

	signal w_DATA	:	std_logic_vector(word_size-1 downto 0);
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
		wait until rising_edge(w_CLK);
		w_RST <= '0';
		wait;
	end process;
	
	-- Carga
	process
	begin
		w_LS <= '1';
		w_DATA <= (OTHERS => '0');
		wait for 40 ns;
		for i in 0 to (2**word_size-1) loop
			w_DATA <= std_logic_vector(to_unsigned(i, w_DATA'length));
			w_LS <= '0';
			wait until w_RTS = '0';
			w_LS <= '1';
			wait until w_RTS = '1';		
		end loop;
		wait;
	end process;

end testbench;