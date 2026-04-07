library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity testbench is
end testbench;

architecture behavioral of testbench is

    -- Component declaration for processor
    component processor is
        port(
            clk   : in std_logic;
            reset : in std_logic
        );
    end component;

    -- Signals
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Clock period: 1 GHz = 1 ns period
    constant clk_period : time := 1 ns;

begin

    -- Instantiate processor
    dut: processor
        port map(
            clk   => clk,
            reset => reset
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Reset and run simulation
    stim_process: process
        file program_file : text open read_mode is "program.txt";
        variable line_in : line;
        variable instr : std_logic_vector(31 downto 0);
        variable cycle_count : integer := 0;
    begin
        -- Reset for a few cycles
        reset <= '1';
        wait for 5 * clk_period;
        reset <= '0';

        -- Read program.txt and load into instruction memory (this is simplified; in reality, you'd need to access the memory component)
        -- For now, assume the processor's memory is initialized externally or via generics

        -- Run for 10,000 cycles
        while cycle_count < 10000 loop
            wait for clk_period;
            cycle_count := cycle_count + 1;
        end loop;

        -- After 10,000 cycles, write outputs
        -- Write register_file.txt (32 lines, one per register)
        -- Write memory.txt (8192 lines, one per 32-bit word)

        -- Simplified: Assume you have access to register file and data memory signals
        -- In a real testbench, you'd need to add ports or internal signals to the processor for this

        -- For example:
        -- file reg_file : text open write_mode is "register_file.txt";
        -- for i in 0 to 31 loop
        --     write(line_out, to_string(unsigned(register_values(i)), 32));
        --     writeline(reg_file, line_out);
        -- end loop;

        -- Similarly for memory

        wait;
    end process;

end behavioral;