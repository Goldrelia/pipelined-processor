LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 

USE ieee.numeric_std.all;                               


entity adder is
	Port(	A: in std_logic_vector(31 downto 0);
			B: in std_logic_vector(31 downto 0);
			Y: out std_logic_vector(31 downto 0));
end adder;


architecture adder_behavioral of adder is
	BEGIN
		Y <= 	std_logic_vector(unsigned(A) + unsigned(B));
END adder_behavioral;