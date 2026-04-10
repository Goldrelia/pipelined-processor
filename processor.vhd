-- 1. Libraries first
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor is
    port(
        clk   : in std_logic;
        reset : in std_logic
    );
end processor;

architecture behavioral of processor is

    -- Signal declarations
    signal branch_taken : std_logic;
    signal branch_target : std_logic_vector(31 downto 0);
    -- For the PC
    signal PC          : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_next     : std_logic_vector(31 downto 0);
    -- For the instruction memory
    signal instruction : std_logic_vector(31 downto 0);
    -- For the IF/ID register
    signal IF_ID_PC    : std_logic_vector(31 downto 0);
    signal IF_ID_IR    : std_logic_vector(31 downto 0);
    -- For the MUX
    signal mux_out : std_logic_vector(31 downto 0);
    -- For the register file
    signal reg1_out : std_logic_vector(31 downto 0);
    signal reg2_out : std_logic_vector(31 downto 0);
    -- For the sign extender
    signal imm_value : std_logic_vector(31 downto 0);
    -- For the ID/EX register
    signal ID_EX_PC : std_logic_vector(31 downto 0);
    signal ID_EX_IR : std_logic_vector(31 downto 0);
    signal register1ex_out : std_logic_vector(31 downto 0);
    signal register2ex_out : std_logic_vector(31 downto 0);
    signal immex_val : std_logic_vector(31 downto 0);
    signal control_memtoreg_ex: std_logic;
    signal control_regwrite_ex : std_logic;
    signal control_branch_ex : std_logic;
    signal control_memread_ex : std_logic;
    signal control_memwrite_ex : std_logic;
    signal control_alu_src_ex : std_logic;
    signal control_alu_op_ex : std_logic_vector(4 downto 0);
    -- For the control unit
    signal control_memtoreg : std_logic;
    signal control_regwrite : std_logic;
    signal control_branch   : std_logic;
    signal control_memread  : std_logic;
    signal control_memwrite : std_logic;
    signal control_alu_src  : std_logic;
    signal control_alu_op   : std_logic_vector(4 downto 0);
    -- For the MUX in the execution phase
    signal alu_in_2 : std_logic_vector(31 downto 0);
    -- For the ALU
    signal alu_result : std_logic_vector(31 downto 0);
    signal alu_zero   : std_logic;
    -- For the ex_mem register
    signal alu_result_mem : std_logic_vector(31 downto 0);
    signal alu_zero_mem: std_logic;
    signal rs2_out_mem: std_logic_vector(31 downto 0);
    signal control_memtoreg_mem : std_logic;
    signal control_regwrite_mem : std_logic;
    signal control_branch_mem : std_logic;
    signal control_memread_mem : std_logic;
    signal control_memwrite_mem : std_logic;
    signal ID_MEM_IR : std_logic_vector(31 downto 0);
    -- For the data memory
    signal data_mem_read  : std_logic_vector(31 downto 0);
    -- For mem_wb register
    signal ID_WB_IR : std_logic_vector(31 downto 0);
    signal write_data : std_logic_vector(31 downto 0);
    signal alu_result_wb : std_logic_vector(31 downto 0);
    signal control_memtoreg_wb : std_logic;
    signal control_regwrite_wb : std_logic;
    -- For the wb_mux
    signal wb_data : std_logic_vector(31 downto 0);

    begin

        PC_next <= std_logic_vector(unsigned(PC) + 4);
        branch_taken <= control_branch_ex and alu_zero;
        branch_target <= std_logic_vector(unsigned(ID_EX_PC) + unsigned(immex_val(30 downto 0) & '0'));

        PC_reg: entity work.reg
            port map(
                clk      => clk,
                reset    => reset,
                en       => '1',
                data_in  => mux_out,
                data_out => PC
            );

        instruction_mem: entity work.memory
            generic map(
                ram_size => 1024
            )
            port map(
                clock       => clk,
                address     => to_integer(unsigned(PC))/4,
                memread     => '1',
                memwrite    => '0',
                writedata   => (others => '0'),
                readdata    => instruction,
                waitrequest => open
            );

        mux: entity work.MUX_2_1
            port map(
                A => PC_next,
                B => alu_result_mem,
                S => branch_taken,
                Y => mux_out
            );
        
        if_id_reg: entity work.if_id_register
            port map(
                clk    => clk,
                reset  => reset,
                en     => '1',
                pc_in  => PC_next,   -- PC+4 goes into IF/ID
                ir_in  => instruction,
                pc_out => IF_ID_PC,
                ir_out => IF_ID_IR
            );

        register_file: entity work.register_file
            port map(
                clock => clk,
                rs1_addr => to_integer(unsigned(IF_ID_IR(19 downto 15))),
                rs2_addr => to_integer(unsigned(IF_ID_IR(24 downto 20))),
                rd_addr => to_integer(unsigned(ID_WB_IR(11 downto 7))),
                rd_data => wb_data, 
                rd_write => control_regwrite_wb,
                rs1_data => reg1_out,
                rs2_data => reg2_out
            );

        sign_extender: entity work.imm_gen
            port map(
                instruction => IF_ID_IR,
                imm_out => imm_value
            );
        control_unit: entity work.control
            port map(
                opcode => IF_ID_IR(6 downto 0),
                funct3 => IF_ID_IR(14 downto 12),
                funct7 => IF_ID_IR(31 downto 25),
                memtoreg    => control_memtoreg,
                regwrite    => control_regwrite,
                branch      => control_branch,
                memread     => control_memread,
                memwrite    => control_memwrite,
                alu_src     => control_alu_src,
                alu_op      => control_alu_op 
            );

        id_ex_register: entity work.id_ex_register
            port map(
                clk => clk,
                reset =>reset,
                en => '1',
                -- Input ports
                pc_in => IF_ID_PC,
                ir_in => IF_ID_IR,
                ir_in_ext => imm_value,
                rs1_in => reg1_out,
                rs2_in => reg2_out,
                -- Output ports
                pc_out => ID_EX_PC,
                ir_out => ID_EX_IR,
                rs1_out => register1ex_out,
                rs2_out => register2ex_out,
                ir_out_ext => immex_val,
                -- Input control signals
                memtoreg_in_control => control_memtoreg,
                regwrite_in_control => control_regwrite,
                branch_in_control => control_branch,
                memread_in_control => control_memread,
                memwrite_in_control => control_memwrite,
                alu_src_in_control => control_alu_src,
                alu_op_in_control => control_alu_op,
                -- Output control signals
                memtoreg_out_control => control_memtoreg_ex,
                regwrite_out_control => control_regwrite_ex,
                branch_out_control => control_branch_ex,
                memread_out_control => control_memread_ex,
                memwrite_out_control => control_memwrite_ex,
                alu_src_out_control => control_alu_src_ex,
                alu_op_out_control => control_alu_op_ex
            );
        
        -- Fowrwarding is not required for full marks, implement only 1 MUX
        mux_ex: entity work.MUX_2_1
            port map(
                A => register2ex_out,
                B => immex_val,
                S => control_alu_src_ex,
                Y => alu_in_2
            );
        
        alu_unit: entity work.alu
            port map(
                A => register1ex_out,
                B => alu_in_2,
                alu_ctrl => control_alu_op_ex,
                result => alu_result,
                zero => alu_zero
            );

        ex_mem_register: entity work.ex_mem_register
            port map(
                clk => clk,
                reset => reset,
                en => '1',
                alu_result_in => alu_result,
                alu_zero_in => alu_zero,
                rs2_in => register2ex_out,
                ir_in => ID_EX_IR,
                memtoreg_in_control => control_memtoreg_ex,
                regwrite_in_control => control_regwrite_ex,
                branch_in_control => control_branch_ex,
                memread_in_control => control_memread_ex,
                memwrite_in_control => control_memwrite_ex,
                ir_out => ID_MEM_IR,
                alu_result_out => alu_result_mem,
                alu_zero_out => alu_zero_mem,
                rs2_out => rs2_out_mem,
                memtoreg_out_control => control_memtoreg_mem,
                regwrite_out_control => control_regwrite_mem,
                branch_out_control => control_branch_mem,
                memread_out_control => control_memread_mem,
                memwrite_out_control => control_memwrite_mem
            );

        data_mem: entity work.memory
            generic map(
                ram_size => 8192
            )
            port map(
                clock       => clk,
                address     => to_integer(unsigned(alu_result_mem))/4,
                memread     => control_memread_mem,
                memwrite    => control_memwrite_mem,
                writedata   => rs2_out_mem,
                readdata    => data_mem_read,
                waitrequest => open
            );
        
        mem_wb_register: entity work.mem_wb_register
            port map(
                clk => clk,
                reset => reset,
                en => '1',
                data_in => data_mem_read,
                alu_result_in => alu_result_mem,
                ir_in => ID_MEM_IR,
                memtoreg_in_control => control_memtoreg_mem,
                regwrite_in_control => control_regwrite_mem,
                data_out => write_data,
                alu_result_out => alu_result_wb,
                ir_out => ID_WB_IR,
                memtoreg_out_control => control_memtoreg_wb,
                regwrite_out_control => control_regwrite_wb
            );

        wb_mux: entity work.MUX_2_1
            port map(
                A => write_data, --this maybe should be: alu_result_wb
                B => branch_target, --this maybe should be: write_data 
                S => control_memtoreg_wb,
                Y => wb_data
            );

end behavioral;