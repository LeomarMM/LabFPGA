--*************************************************************************************
--
--	Modulo	:	EDGE_DETECTOR
--	Entradas :
--					i_CLK				--> Clock global.
--					i_RST				--> Reset assíncrono.
--					i_SIGNAL			--> Sinal de referência
--	Saídas:
--					o_EDGE_UP		--> Pulso de subida do sinal.
--					o_EDGE_DOWN		--> Pulso de descida do sinal.
--
--*************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EDGE_DETECTOR is
port
(
	i_RST				:	in std_logic;
	i_CLK				:	in std_logic;	
	i_SIGNAL			:	in std_logic;
	o_EDGE_UP		:	out std_logic;
	o_EDGE_DOWN		:	out std_logic
);
end EDGE_DETECTOR;

architecture behavioral of EDGE_DETECTOR is
----------------------------------------------------------------------------------------------
-- Sinais internos.
----------------------------------------------------------------------------------------------
	signal w_SIGNAL_R, w_SIGNAL_S, w_SIGNAL_T : std_logic;

begin
----------------------------------------------------------------------------------------------
-- Detector de bordas
----------------------------------------------------------------------------------------------
	U1 : process(i_CLK, i_RST)														
 	begin																							
		if (i_RST = '1')  then																	
			w_SIGNAL_R	<=	'0';																		
			w_SIGNAL_S	<=	'0';																		
			w_SIGNAL_T	<=	'0';
		elsif falling_edge (i_CLK) then												
			w_SIGNAL_R <= i_SIGNAL;																			
			w_SIGNAL_S <= w_SIGNAL_R;																		
			w_SIGNAL_T <= w_SIGNAL_S;																		
		end if;																					
	end process U1;																

	-- Borda de descida do sinal
   o_EDGE_DOWN <= not(w_SIGNAL_S) and w_SIGNAL_T;		
	
   -- Borda de subida do sinal
   o_EDGE_UP <= w_SIGNAL_S and not(w_SIGNAL_T);													   


----------------------------------------------------------------------------------------------
end behavioral;
