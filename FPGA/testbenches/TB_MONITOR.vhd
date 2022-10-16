library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_MONITOR is
generic
(
	baud				:	integer := 9600;
	bytes				:	integer := 2
);
end TB_MONITOR;

architecture testbench of TB_MONITOR is

	constant delay	:	time	:= 1 sec*(1.0/real(baud));
	component MONITOR
	generic
	(
		baud				:	integer := baud;
		clock				:	integer := 50000000;
		bytes		:	integer := bytes
	);
	port
	(
		i_RX		:	in std_logic;
		i_CLK		:	in std_logic;
		i_RST		:	in std_logic;
		i_PINS	:	in std_logic_vector(8*bytes-1 downto 0) := (OTHERS => '1');
		o_PINS	:	out std_logic_vector(8*bytes-1 downto 0)
	);
	end component;

	signal w_RX		:	std_logic;
	signal w_CLK	:	std_logic;
	signal w_RST	:	std_logic;
	signal w_PINS	:	std_logic_vector(8*bytes-1 downto 0);
	
begin

	U1 : MONITOR
	port map
	(
		i_RX	=> w_RX,
		i_CLK	=> w_CLK,
		i_RST	=> w_RST,
		o_PINS => w_PINS
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
		for i in 0 to 2 loop
			if(i /= 2) then v_RX := std_logic_vector(to_unsigned(i, 8));
			else v_RX := std_logic_vector(to_unsigned(47, 8)); end if;
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