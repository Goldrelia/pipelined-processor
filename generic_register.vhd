library IEEE;
use IEEE.std_logic_1164.all;

entity generic_register is
    generic(
        N: integer:=32 --32 bits but can be overriden
    );
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;
        d: in std_logic_vector(N-1 downto 0);
        q: out std_logic_vector(N-1 downto 0)
    );
end generic_register;

architecture behaviour of generic_register is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset='1' then
                q<=(others=>'0'); --reset and clear all bits to 0
            elsif en='1' then
                q<=d; --new data
            end if;
        end if;
    end process;
end behaviour;
            