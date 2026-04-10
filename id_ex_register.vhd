library IEEE;
use IEEE.std_logic_1164.all;

entity id_ex_register is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;

        --Inputs from ID stage
        pc_in: in std_logic_vector(31 downto 0);
        ir_in: in std_logic_vector(31 downto 0);
        ir_in_ext: in std_logic_vector(31 downto 0);
        rs1_in: in std_logic_vector(31 downto 0);
        rs2_in: in std_logic_vector(31 downto 0);
        --Define the input control signals
        memtoreg_in_control: in std_logic;
        regwrite_in_control: in std_logic;
        branch_in_control: in std_logic;
        branch_type_in_control: in std_logic_vector(2 downto 0);
        jal_in_control: in std_logic;
        jalr_in_control: in std_logic;
        memread_in_control: in std_logic;
        memwrite_in_control: in std_logic;
        alu_src_in_control: in std_logic;
        alu_op_in_control: in std_logic_vector(4 downto 0);

        --Outputs to EX stage
        pc_out: out std_logic_vector(31 downto 0);
        ir_out: out std_logic_vector(31 downto 0);
        rs1_out: out std_logic_vector(31 downto 0);
        rs2_out: out std_logic_vector(31 downto 0);
        ir_out_ext: out std_logic_vector(31 downto 0);
        --Define the output control signals
        memtoreg_out_control: out std_logic;
        regwrite_out_control: out std_logic;
        branch_out_control: out std_logic;
        branch_type_out_control: out std_logic_vector(2 downto 0);
        jal_out_control: out std_logic;
        jalr_out_control: out std_logic;
        memread_out_control: out std_logic;
        memwrite_out_control: out std_logic;
        alu_src_out_control: out std_logic;
        alu_op_out_control: out std_logic_vector(4 downto 0)
    );
end id_ex_register;

architecture behavioural of id_ex_register is
    begin
        process(reset, clk)
            begin 
                if reset = '1' THEN
                    pc_out <= (others => '0');
                    ir_out <= (others => '0');
                    ir_out_ext <= (others => '0');
                    rs1_out <= (others => '0');
                    rs2_out <= (others => '0');
                    memtoreg_out_control <= '0';
                    regwrite_out_control <= '0';
                    branch_out_control <= '0';
                    memread_out_control <= '0';
                    memwrite_out_control <= '0';
                    alu_src_out_control <= '0';
                    alu_op_out_control <= (others => '0');
                    branch_type_out_control <= (others => '0');
                    jal_out_control <= '0';
                    jalr_out_control <= '0';

                elsif rising_edge(clk) THEN
                    if en = '1' then
                        pc_out <= pc_in;
                        ir_out <= ir_in;
                        ir_out_ext <= ir_in_ext;
                        rs1_out <= rs1_in;
                        rs2_out <= rs2_in;
                        memtoreg_out_control <= memtoreg_in_control;
                        regwrite_out_control <= regwrite_in_control;
                        branch_out_control <= branch_in_control;
                        memread_out_control <= memread_in_control;
                        memwrite_out_control <= memwrite_in_control;
                        alu_src_out_control <= alu_src_in_control;
                        alu_op_out_control <= alu_op_in_control;
                        branch_type_out_control <= branch_type_in_control;
                        jal_out_control <= jal_in_control;
                        jalr_out_control <= jalr_in_control;
                    end if;
                end if;
        end process;
end behavioural;
