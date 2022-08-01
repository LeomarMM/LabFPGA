library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_TOP_UART is
generic
(
	baud			:	integer	:=	9600
);
end TB_TOP_UART;

architecture testbench of TB_TOP_UART is

	constant delay	:	time	:= 1 sec*(1.0/real(baud));
	component TOP_UART
	port
	(
		i_RX		:	in std_logic;
		i_CLK		:	in std_logic;
		i_RST		:	in std_logic;
		o_TX		:	out std_logic
	);
	end component;
	signal w_RX		:	std_logic;
	signal w_CLK	:	std_logic;
	signal w_RST	:	std_logic;
	signal w_TX		:	std_logic;

begin

	U1 : TOP_UART
	port map
	(
		i_RX	=> w_RX,
		i_CLK	=> w_CLK,
		i_RST	=> w_RST,
		o_TX	=> w_TX
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

	-- TX
	process
		variable v_RX : STD_LOGIC_VECTOR(7 downto 0);
	begin
		w_RX <= '1';
		for i in 0 to 255 loop
			v_RX := std_logic_vector(to_unsigned(i, 8));
			wait for delay;
			w_RX <= '0';
			wait for delay;
			for i in 0 to 7 loop
				w_RX <= v_RX(i);
				wait for delay;
			end loop;
			w_RX <= '1';
			wait for delay*10;
		end loop;
		wait;
	end process;
end testbench;