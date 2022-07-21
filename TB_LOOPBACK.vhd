library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_LOOPBACK is
end TB_LOOPBACK;

architecture testbench of TB_LOOPBACK is

	component LOOPBACK
		port
		(
			i_RST		: in std_logic;
			i_CLK		: in std_logic;
			i_DATA	: in std_logic_vector(7 downto 0);
			i_LOAD	: in std_logic;
			i_ND		: in std_logic;
			o_DATA	: out std_logic_vector(7 downto 0)
		);
	end component;

	signal w_RST		:	std_logic;
	signal w_CLK		:	std_logic;
	signal w_DATAIN	:	std_logic_vector(7 downto 0);
	signal w_LOAD		:	std_logic;
	signal w_ND			:	std_logic;
	signal w_DATAOUT	:	std_logic_vector(7 downto 0);
	signal w_FAIL		:	std_logic;

begin

	LBK	:	LOOPBACK
	port map
	(
		i_RST			=>	w_RST,
		i_CLK			=>	w_CLK,
		i_DATA		=>	w_DATAIN,
		i_LOAD		=> w_LOAD,
		i_ND			=> w_ND,
		o_DATA	=> w_DATAOUT
	);
	
	-- Gerador de Clock 
	process
	begin

		w_CLK <= '0';
		wait for 5 ns;
		w_CLK <= '1';
		wait for 5 ns;
	
	end process;

	-- Reset
	process
	begin

		w_RST <= '1';
		wait for 10 ns;
		w_RST <= '0';
		wait;

	end process;

	-- Carga de Dados e Auto-teste
	process
	begin

		w_DATAIN <= (OTHERS => '0');
		w_LOAD <= '0';
		w_ND <= '0';
		w_FAIL <= '0';

		wait for 15 ns;

		for i in 0 to 255 loop

			w_DATAIN <= std_logic_vector(to_unsigned(i, w_DATAIN'length));

			w_LOAD <= '1';

			wait for 5 ns;

			w_LOAD <= '0';

			for j in 7 downto 0 loop

				w_ND <= '1';
				wait for 5 ns;
				w_ND <= '0';
				wait for 5 ns;
				
			end loop;	

			if(w_FAIL = '1' or w_DATAIN /= w_DATAOUT) then
					w_FAIL <= '1';
				else
					w_FAIL <= '0';
				end if;
				
			wait for 5 ns;

		end loop;

		wait;

	end process;

end testbench;