library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VHDL is
generic
(
	baud				:	integer := 9600;
	clock				:	integer := 50000000;
	ss_div			:	integer := 1000
);
port
(
	i_RX		:	in std_logic;
	i_CLK		:	in std_logic;
	i_RST		:	in std_logic;
	o_TX		:	out std_logic;
	o_LEDR	:	out std_logic_vector (3 downto 0);
	o_HEX		:	out std_logic_vector(6 downto 0);
	o_SEL		:	out	std_logic_vector(3 downto 0)
);
end VHDL;

architecture rtl of VHDL is

	component DE1SoC is
	generic
	(
		baud				:	integer := baud;
		clock				:	integer := clock
	);
	port
	(
		i_CLK		:	in		std_logic;
		i_RX		:	in		std_logic;
		i_RST		:	in		std_logic;
		i_LEDS	:	in		std_logic_vector(9 downto 0);
		i_7S5		:	in		std_logic_vector(6 downto 0);
		i_7S4		:	in		std_logic_vector(6 downto 0);
		i_7S3		:	in		std_logic_vector(6 downto 0);
		i_7S2		:	in		std_logic_vector(6 downto 0);
		i_7S1		:	in		std_logic_vector(6 downto 0);
		i_7S0		:	in		std_logic_vector(6 downto 0);
		o_SWITCH	:	out	std_logic_vector(9 downto 0);
		o_BUTTON	:	out	std_logic_vector(3 downto 0);
		o_TX		:	out	std_logic
	);
	end component;

	signal HEX5			: std_logic_vector(6 downto 0);
	signal HEX4			: std_logic_vector(6 downto 0);
	signal HEX3			: std_logic_vector(6 downto 0);
	signal HEX2			: std_logic_vector(6 downto 0);
	signal HEX1			: std_logic_vector(6 downto 0);
	signal HEX0			: std_logic_vector(6 downto 0);
	signal SW			: std_logic_vector(9 downto 0);
	signal KEY			: std_logic_vector(3 downto 0);
	signal LEDR			: std_logic_vector(9 downto 0);
	signal w_RST		: std_logic;
	signal r_SEL		: std_logic_vector(3 downto 0) := "1110";
	signal r_COUNTER	: integer range 0 to clock/ss_div := 0;

	-- Declare signals and components inside this region


	-- End of signal and component declaration region

begin

	w_RST <= not(i_RST);
	U1 : DE1SoC
	port map
	(
		i_CLK		=> i_CLK,
		i_RX		=> i_RX,
		i_RST		=> w_RST,
		i_LEDS	=> LEDR,
		i_7S5		=> HEX5,
		i_7S4		=> HEX4,
		i_7S3		=> HEX3,
		i_7S2		=> HEX2,
		i_7S1		=> HEX1,
		i_7S0		=> HEX0,
		o_SWITCH	=> SW,
		o_BUTTON	=> KEY,
		o_TX		=> o_TX
	);
	
	process(i_CLK, w_RST, r_SEL)
	begin
		if(rising_edge(i_CLK)) then
			if(r_COUNTER = clock/ss_div) then
				case r_SEL is
				when "1110" => 
					o_HEX <= HEX1;
					r_SEL <= "1101";
				when "1101" => 
					o_HEX <= HEX2;
					r_SEL <= "1011";
				when "1011" => 
					o_HEX <= HEX3;
					r_SEL <= "0111";
				when "0111" => 
					o_HEX <= HEX0;
					r_SEL <= "1110";
				when others =>
					o_HEX <= HEX0;
					r_SEL <= "1110";
				end case;
				r_COUNTER <= 0;
			else
				r_COUNTER <= r_COUNTER + 1;
			end if;
		end if;
	end process;
	
	o_SEL <= r_SEL;
	o_LEDR <= LEDR(3 downto 0);

	-- Implement your logic inside this region

	-- End of logic implementation region

end rtl;