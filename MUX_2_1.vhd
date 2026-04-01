LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 

USE ieee.numeric_std.all;                               


entity MUX_2_1 is
	Port(	A: in std_logic;
			B: in std_logic;
			S: in std_logic;
			Y: out std_logic);
end MUX_2_1;


architecture MUX_2_1_behavioral of MUX_2_1 is
	BEGIN
		with S select
			y <= 	A when '0',
					B when '1',
				   'X' when others;
END MUX_2_1_behavioral;
