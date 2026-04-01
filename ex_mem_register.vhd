library IEEE;
use IEEE.std_logic_1164.all;

entity ex_mem_register is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;

        --Inputs from EX stage
        branch_taken_in: in std_logic;
        alu_result_in: in std_logic_vector(31 downto 0);
        rs2_in: in std_logic_vector(31 downto 0);
        ir_in: in std_logic_vector(31 downto 0);
        memtoreg_in_control: in std_logic;
        regwrite_in_control: in std_logic;
        branch_in_control: in std_logic;
        memread_in_control: in std_logic;
        memwrite_in_control: in std_logic;


        --Outputs to MEM stage
        branch_taken_out: out std_logic;
        ir_out: out std_logic_vector(31 downto 0);
        alu_result_out: out std_logic_vector(31 downto 0);
        rs2_out: out std_logic_vector(31 downto 0);
        memtoreg_out_control: out std_logic;
        regwrite_out_control: out std_logic;
        branch_out_control: out std_logic;
        memread_out_control: out std_logic;
        memwrite_out_control: out std_logic
    );
end ex_mem_register;

architecture behavioural of ex_mem_register is
    begin
        process(reset, clk)
            begin 
                if reset = '1' THEN
                    branch_taken_out <= '0';
                    ir_out <= (others => '0');
                    alu_result_out <= (others => '0');
                    rs2_out <= (others => '0');
                    memtoreg_out_control <= '0';
                    regwrite_out_control <= '0';
                    branch_out_control <= '0';
                    memread_out_control <= '0';
                    memwrite_out_control <= '0';

                elsif rising_edge(clk) THEN
                    if en = '1' then
                        branch_taken_out <= branch_taken_in;
                        alu_result_out <= alu_result_in;
                        ir_out <= ir_in;
                        rs2_out <= rs2_in;
                        memtoreg_out_control <= memtoreg_in_control;
                        regwrite_out_control <= regwrite_in_control;
                        branch_out_control <= branch_in_control;
                        memread_out_control <= memread_in_control;
                        memwrite_out_control <= memwrite_in_control;
                    end if;
                end if;
        end process;
end behavioural;
