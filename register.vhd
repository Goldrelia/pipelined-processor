library IEEE;
use IEEE.std_logic_1164.all;

entity reg is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;

        --Inputs from ID stage
        data_in: in std_logic_vector(31 downto 0);

        --Outputs to EX stage
        data_out: out std_logic_vector(31 downto 0)
    );
end reg;

architecture behavioural of reg is
    begin
        process(reset, clk)
            begin 
                if reset = '1' THEN
                    data_out <= (others => '0');

                elsif rising_edge(clk) THEN
                    if en = '1' then
                        data_out <= data_in;
                    end if;
                end if;
        end process;
end behavioural;
