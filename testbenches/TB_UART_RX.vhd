library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_UART_RX is
generic
(
	baud	:	integer	:=	2100000
);
end TB_UART_RX;
architecture testbench of TB_UART_RX is
	constant delay	:	time		:= 1 sec*(1.0/real(baud));
	component UART_RX
	generic
	(
		baud			:	integer;	--	Baud padrão
		clock			:	integer; -- 50MHz de clock interno padrao
		frame_size	:	integer
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_RX		:	in		std_logic;
		o_DATA	:	out	std_logic_vector(frame_size-1 downto 0)
	);
	end component;

	signal w_CLK	:	std_logic;
	signal w_RST	:	std_logic;
	signal w_RX		:	std_logic;
	signal w_DATA	:	std_logic_vector(7 downto 0);

begin

	U_RX	:	UART_RX
	generic map
	(
		baud			=> baud,
		clock			=> 50000000,
		frame_size	=> 8
	)
	port map
	(
		i_CLK		=>	w_CLK,
		i_RST		=>	w_RST,
		i_RX		=>	w_RX,
		o_DATA	=>	w_DATA
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

	-- TX
	process
		variable v_RX : STD_LOGIC_VECTOR(w_DATA'range);
		
	begin
		
		w_RX <= '1';
		wait for delay;
		w_RX <= '0';
		wait for delay/10;	-- Introduzir falha para teste de failsafe
		w_RX <= '1'; 			-- Se tudo estiver bem, máquina de estados deve voltar para IDLE
		for i in 0 to 255 loop
			v_RX := std_logic_vector(to_unsigned(i, w_DATA'length));
			wait for delay;
			w_RX <= '0';
			wait for delay;
			for i in 0 to 7 loop
				w_RX <= v_RX(i);
				wait for delay;
			end loop;
			w_RX <= '1';
		end loop;
		wait;
	end process;

end testbench;