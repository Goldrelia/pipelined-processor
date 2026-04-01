library IEEE;
use IEEE.std_logic_1164.all;

entity imm_gen is
    port(
        imm_in: in std_logic_vector(11 downto 0);
        zero_ext: in std_logic; --1 for zero extending, 0 for sign extending
        imm_out: out std_logic_vector(31 downto 0)
    );
end imm_gen;

architecture behaviour of imm_gen is
begin
    process(imm_in,zero_ext)
    begin
        if zero_ext='1' then --we want to zero extend
            imm_out(11 downto 0)<=imm_in;
            imm_out(31 downto 12)<=(others=>'0');
        else --we want to sign extend
            imm_out(11 downto 0)<=imm_in;
            imm_out(31 downto 12)<=(others=>imm_in(11));
        end if;
    end process;
end behaviour;
