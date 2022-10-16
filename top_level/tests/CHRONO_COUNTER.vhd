library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CHRONO_COUNTER is
generic
(
	clock	:	integer
);
port
(
	i_RST		:	in	std_logic;
	i_CLK		:	in	std_logic;
	i_ENA		:	in std_logic;
	o_MINMSN	:	out std_logic_vector(3 downto 0);
	o_MINLSN	:	out std_logic_vector(3 downto 0);
	o_SECMSN	:	out std_logic_vector(3 downto 0);
	o_SECLSN	:	out std_logic_vector(3 downto 0);
	o_CSMSN	:	out std_logic_vector(3 downto 0);
	o_CSLSN	:	out std_logic_vector(3 downto 0)
);
end CHRONO_COUNTER;

architecture behavioral of CHRONO_COUNTER is
	constant c_CMAX	:	integer := clock/100;
	signal r_COUNTER	:	integer range 0 to c_CMAX := 0;
begin

	process(i_CLK, i_RST)
		variable v_MINMSN	:	std_logic_vector(3 downto 0)	:=	(OTHERS => '0');
		variable v_MINLSN	:	std_logic_vector(3 downto 0)	:=	(OTHERS => '0');
		variable v_SECMSN	:	std_logic_vector(3 downto 0)	:=	(OTHERS => '0');
		variable v_SECLSN	:	std_logic_vector(3 downto 0)	:=	(OTHERS => '0');
		variable v_CSMSN	:	std_logic_vector(3 downto 0)	:=	(OTHERS => '0');
		variable v_CSLSN	:	std_logic_vector(3 downto 0)	:=	(OTHERS => '0');
	begin
		o_MINMSN		<=	v_MINMSN;
		o_MINLSN		<=	v_MINLSN;
		o_SECMSN		<=	v_SECMSN;
		o_SECLSN		<=	v_SECLSN;
		o_CSMSN		<=	v_CSMSN;
		o_CSLSN		<=	v_CSLSN;
		if(i_RST = '1') then
			v_MINMSN		:=	(OTHERS => '0');
			v_MINLSN		:=	(OTHERS => '0');
			v_SECMSN		:=	(OTHERS => '0');
			v_SECLSN		:=	(OTHERS => '0');
			v_CSMSN		:=	(OTHERS => '0');
			v_CSLSN		:=	(OTHERS => '0');
		elsif(rising_edge(i_CLK)) then
			if(i_ENA = '1') then
				if(r_COUNTER = c_CMAX) then

					r_COUNTER <= 0;
					v_CSLSN := v_CSLSN + '1';

					if(v_CSLSN = x"A") then
						v_CSLSN := x"0";
						v_CSMSN := v_CSMSN + 1;
					end if;

					if(v_CSMSN = x"A") then
						v_CSMSN := x"0";
						v_SECLSN := v_SECLSN + 1;
					end if;
					
					if(v_SECLSN = x"A") then
						v_SECLSN := x"0";
						v_SECMSN := v_SECMSN + 1;
					end if;

					if(v_SECMSN = x"6") then
						v_SECMSN := x"0";
						v_MINLSN := v_MINLSN + 1;
					end if;

					if(v_MINLSN = x"A") then
						v_MINLSN := x"0";
						v_MINMSN := v_MINMSN + 1;
					end if;

					if(v_MINMSN = x"6") then
						v_MINMSN := x"0";
					end if;

				else
					r_COUNTER <= r_COUNTER + 1;
				end if;
			end if;
		end if;
	end process;
end behavioral;