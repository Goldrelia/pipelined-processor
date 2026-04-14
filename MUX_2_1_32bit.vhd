LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 

entity MUX_2_1_32bit is
    Port(
        A: in std_logic_vector(31 downto 0);
        B: in std_logic_vector(31 downto 0);
        S: in std_logic;
        Y: out std_logic_vector(31 downto 0)
    );
end MUX_2_1_32bit;

architecture behavioral of MUX_2_1_32bit is
BEGIN
    with S select
        Y <= A when '0',
             B when '1',
             (others => 'X') when others;
END behavioral;