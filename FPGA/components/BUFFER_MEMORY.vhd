library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.machine_states_common.all;

entity BUFFER_MEMORY is
generic (buffer_size : integer);
port 
(
	i_CLK			:	in			std_logic;
	i_RST			:	in 		std_logic;
	i_STATE		:	in			top_state;
	i_BYTE		:	in			std_logic_vector(7 downto 0);
	i_CRC			:	in			std_logic_vector(7 downto 0);
	i_CRC_MATCH	:	in			std_logic;
	i_DATA		:	in			std_logic_vector(buffer_size-1 downto 0);
	o_DATA		:	buffer	std_logic_vector(buffer_size-1 downto 0)
);
end BUFFER_MEMORY;

architecture behavioral of BUFFER_MEMORY is
	constant ACK			:	std_logic_vector(7 downto 0) := x"06";
	constant NAK			:	std_logic_vector(7 downto 0) := x"15";
begin
-- Registradores de bufferização
	process(i_CLK, i_RST)
	begin
		if(i_RST = '1') then
			o_DATA <= (OTHERS => '0');
		elsif(falling_edge(i_CLK)) then
			if(i_STATE = FILL_BUFFER) then
				o_DATA <= o_DATA(buffer_size-9 downto 0) & i_BYTE;
			elsif(i_STATE = LOAD_ACK) then
				if(i_CRC_MATCH = '1') then
					o_DATA(buffer_size-1 downto buffer_size-8) <= ACK;
				else
					o_DATA(buffer_size-1 downto buffer_size-8) <= NAK;
				end if;
			elsif(i_STATE = LOAD_PINS) then
				o_DATA <= i_DATA;
			elsif(i_STATE = LOAD_CRC) then
				o_DATA(7 downto 0) <= i_CRC;
			end if;
		end if;
	end process;
end behavioral;