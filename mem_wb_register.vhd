library IEEE;
use IEEE.std_logic_1164.all;

entity mem_wb_register is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;

        --Inputs from MEM stage
        data_in: in std_logic_vector(31 downto 0);
        alu_result_in: in std_logic_vector(31 downto 0);
        pc_in: in std_logic_vector(31 downto 0);
        ir_in: in std_logic_vector(31 downto 0);
        link_in_control: in std_logic;
        memtoreg_in_control: in std_logic;
        regwrite_in_control: in std_logic;

        --Outputs to WB stage
        data_out: out std_logic_vector(31 downto 0);
        alu_result_out: out std_logic_vector(31 downto 0);
        pc_out: out std_logic_vector(31 downto 0);
        ir_out: out std_logic_vector(31 downto 0);
        link_out_control: out std_logic;
        memtoreg_out_control: out std_logic;
        regwrite_out_control: out std_logic
    );
end mem_wb_register;

architecture behavioural of mem_wb_register is
    begin
        process(reset, clk)
            begin 
                if reset = '1' THEN
                    data_out <= (others => '0');
                    alu_result_out <= (others => '0');
                    pc_out <= (others => '0');
                    ir_out <= (others => '0');
                    link_out_control <= '0';
                    memtoreg_out_control <= '0';
                    regwrite_out_control <= '0';

                elsif rising_edge(clk) THEN
                    if en = '1' then
                        data_out <= data_in;
                        alu_result_out <= alu_result_in;
                        pc_out <= pc_in;
                        ir_out <= ir_in;
                        link_out_control <= link_in_control;
                        memtoreg_out_control <= memtoreg_in_control;
                        regwrite_out_control <= regwrite_in_control;
                    end if;
                end if;
        end process;
end behavioural;
