library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity DEBOUNCER is
generic
(
	clock_hz			:	integer;
	start_signal	:	std_logic;
	time_ms			:	integer
);
port
(
	i_SIGNAL	:	in std_logic;
	i_CLK		:	in std_logic;
	o_SIGNAL	:	out std_logic
);
end DEBOUNCER;

architecture behavioral of DEBOUNCER is

	constant s_time	:	integer := clock_hz*time_ms/1000;
	signal w_DEADLINE	:	std_logic;
	signal r_D			:	std_logic_vector(2 downto 0) := "01" & start_signal;
	signal r_COUNTER	:	integer range 0 to s_time;

begin

	w_DEADLINE <=	'1' when r_COUNTER = s_time else
						'0';

	process(i_SIGNAL, i_CLK, r_D, w_DEADLINE)
		variable v_NEQ : std_logic;
	begin
		v_NEQ := (r_D(0) xor r_D(1));
		if(v_NEQ = '1') then
			r_COUNTER <= 0;
		elsif(rising_edge(i_CLK) and w_DEADLINE = '0') then
			r_COUNTER <= r_COUNTER + 1;
		end if;
	end process;
	
	process(i_SIGNAL, i_CLK, r_D, w_DEADLINE)
	begin
		if(rising_edge(i_CLK)) then
			r_D(0) <= i_SIGNAL;
			r_D(1) <= r_D(0);
			if(w_DEADLINE = '1') then
				r_D(2) <= r_D(1);
			end if;
		end if;
	end process;
	
	o_SIGNAL <= r_D(2);

end behavioral;