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
    -- The signals below are the signals whitch make the connections of the circuit     
    -- IF Stage : Program Counter
    signal PC          : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_next     : std_logic_vector(31 downto 0); -- PC+4 (sequential next address)
    -- IF Stage: Instruction Memory Output
    signal instruction : std_logic_vector(31 downto 0) := (others => '0');
    -- IF/ID Pipeline Register
    signal IF_ID_PC    : std_logic_vector(31 downto 0); -- PC of fetched instruction
    signal IF_ID_IR    : std_logic_vector(31 downto 0); -- Fetched instruction world
    -- IF Stage: PC MUX Output
    -- Selects between sequential PC+4 and branchéjump target addresses
    signal mux_out : std_logic_vector(31 downto 0); 
    -- ID Stage: Register File Outputs
    signal reg1_out : std_logic_vector(31 downto 0); -- Value read from rs1
    signal reg2_out : std_logic_vector(31 downto 0); -- Value read from rs2
    -- ID Stage: Immediate Generator Output
    signal imm_value : std_logic_vector(31 downto 0); -- Sign-extended immediate value
    -- ID/EX Pipeline Register
    signal ID_EX_PC : std_logic_vector(31 downto 0); -- PC passed to EX
    signal ID_EX_IR : std_logic_vector(31 downto 0); -- Instruction passed to EX
    signal register1ex_out : std_logic_vector(31 downto 0); -- rs1 value in EX
    signal register2ex_out : std_logic_vector(31 downto 0); -- rs2 value in EX
    signal immex_val : std_logic_vector(31 downto 0); -- Immediate value in EX
    --ID/EX Control Signals (EX outputs)
    signal control_memtoreg_ex: std_logic; -- Mem read to WB
    signal control_regwrite_ex : std_logic; -- Enables register write
    signal control_branch_ex : std_logic; -- Instruction is a branch
    signal control_memread_ex : std_logic; -- Enables data memory read
    signal control_memwrite_ex : std_logic; -- Enables data memory write
    signal control_alu_src_ex : std_logic; -- Selects the immediate value for ALU
    signal control_alu_op_ex : std_logic_vector(4 downto 0); -- ALU operation result
    -- ID Stage: Control Unit Outputs
    signal control_memtoreg : std_logic;
    signal control_regwrite : std_logic;
    signal control_branch   : std_logic;
    signal control_branch_type : std_logic_vector(2 downto 0);
    signal control_jal      : std_logic; -- Instruction is JAL
    signal control_jalr     : std_logic; -- Instruction is JALR
    signal control_memread  : std_logic;
    signal control_memwrite : std_logic;
    signal control_alu_src  : std_logic;
    signal control_alu_op   : std_logic_vector(4 downto 0);

    -- Pipeline: Branch-type and Control Signals
    signal control_branch_type_ex : std_logic_vector(2 downto 0); -- Brnach type in EX
    signal control_jal_ex        : std_logic; -- JAL active in EX
    signal control_jalr_ex       : std_logic; -- JALR active in EX
    signal control_link_mem      : std_logic; -- Link active in MEM
    signal control_link_wb       : std_logic; -- Link active in WB

    -- EX Stage: Branch/jump Resolution
    signal branch_condition_ex : std_logic; -- Result of branch comparison
    signal branch_taken_ex     : std_logic; -- Branch or jump taken
    signal pc_taken_mem        : std_logic; -- Taken flag to MEM
    signal pc_target_ex        : std_logic_vector(31 downto 0); -- Resolved jump/branch
    signal pc_target_mem       : std_logic_vector(31 downto 0); -- Target to MEM
    signal pc_plus4_mem        : std_logic_vector(31 downto 0); -- PC+4 in MEM
    signal pc_plus4_wb         : std_logic_vector(31 downto 0); -- PC+4 in WB
    signal pc_base_ex          : std_logic_vector(31 downto 0);  -- PC basefor target calculation
    signal jal_target_ex       : std_logic_vector(31 downto 0); -- JAL target
    signal jalr_target_raw_ex  : std_logic_vector(31 downto 0); -- JALR before LSB clear
    signal jalr_target_ex      : std_logic_vector(31 downto 0);-- JALR target

    -- Jump-link logic
    -- When EX must write PC+4 to rd
    signal link_ex             : std_logic;

    -- For the MUX in the execution phase
    signal alu_in_2 : std_logic_vector(31 downto 0);
    signal alu_mem_wb : std_logic_vector(31 downto 0);

    -- Address signals (to avoid dynamic expressions)
    signal instr_addr : integer := 0; -- Word address into instruction memory
    signal data_addr : integer := 0; -- Word address into data memory
    signal rs1_addr : integer := 0; -- Register file read port 1
    signal rs2_addr : integer := 0; -- Register file read port 2
    signal rd_addr : integer := 0; -- Register file write port
    -- For the ALU
    signal alu_result : std_logic_vector(31 downto 0);
    signal alu_zero   : std_logic;
    -- EX/MEM Pipeline Registers
    signal alu_result_mem : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_zero_mem: std_logic;
    signal rs2_out_mem: std_logic_vector(31 downto 0);
    signal control_memtoreg_mem : std_logic;
    signal control_regwrite_mem : std_logic;
    signal control_branch_mem : std_logic;
    signal control_memread_mem : std_logic;
    signal control_memwrite_mem : std_logic;
    signal ID_MEM_IR : std_logic_vector(31 downto 0);
    -- MEM Stage: Data Memory Output
    -- Word read for data memory
    signal data_mem_read  : std_logic_vector(31 downto 0);
    -- MEM/WB Pipeline Register
    signal ID_WB_IR : std_logic_vector(31 downto 0); -- Instruction in WB
    signal write_data : std_logic_vector(31 downto 0); -- Data for WB
    signal alu_result_wb : std_logic_vector(31 downto 0); -- ALU result forwarded to WB
    signal control_memtoreg_wb : std_logic;
    signal control_regwrite_wb : std_logic;
    -- WB Stage: Final Write-back Data
    signal wb_data : std_logic_vector(31 downto 0);
    -- Hazard detection Unit Outputs
    -- hazard_mux = '1' signals a stall
    signal pc_write_en : std_logic; -- freezes pc during stall
    signal if_id_write_en : std_logic; -- freezes IF/ID during stall
    signal hazard_mux : std_logic; -- detects stall
    -- for the hazard mux output

-- AUIPC
    signal control_auipc    : std_logic;
    signal control_auipc_ex : std_logic;
    signal alu_in_1         : std_logic_vector(31 downto 0);

    -- Intermediate signals for conditional port map expressions
    signal if_id_reset          : std_logic;
    signal id_ex_reset          : std_logic;
    signal ex_mem_reset 	: std_logic;
    signal id_ex_memtoreg_in    : std_logic;
    signal id_ex_regwrite_in    : std_logic;
    signal id_ex_branch_in      : std_logic;
    signal id_ex_branch_type_in : std_logic_vector(2 downto 0);
    signal id_ex_jal_in         : std_logic;
    signal id_ex_jalr_in        : std_logic;
    signal id_ex_memread_in     : std_logic;
    signal id_ex_memwrite_in    : std_logic;
    signal id_ex_alu_src_in     : std_logic;
    signal id_ex_alu_op_in      : std_logic_vector(4 downto 0);
    signal id_ex_auipc_in       : std_logic;
    -- IF/ID stores instruction address; link writes need PC+4 of that instruction
    signal wb_link_pc_plus4   : std_logic_vector(31 downto 0);
    -- addi x0, x0, 0 bubble for EX when stalling ID (per handout)
    constant BUBBLE_IR : std_logic_vector(31 downto 0) := x"00000013";
    signal id_ex_ir_in    : std_logic_vector(31 downto 0);
    signal id_ex_imm_in  : std_logic_vector(31 downto 0);
    signal id_ex_rs1_in  : std_logic_vector(31 downto 0);
    signal id_ex_rs2_in  : std_logic_vector(31 downto 0);
    -- Hazard stall or taken branch/jump in EX: kill wrong-path instr in ID/EX
    signal bubble_id_ex  : std_logic;
    signal if_id_ir_in   : std_logic_vector(31 downto 0);
    signal if_id_pc_in   : std_logic_vector(31 downto 0);

    begin
        -- Link return address: the value written to rd for JAL/JALR
        wb_link_pc_plus4 <= std_logic_vector(unsigned(pc_plus4_wb) + 4);
        -- When a bubble is needed, zero out data and inject NOP into ID/EX, prevents stalled instruction
        -- from affecting EX
        id_ex_ir_in   <= BUBBLE_IR when bubble_id_ex = '1' else IF_ID_IR;
        id_ex_imm_in  <= (others => '0') when bubble_id_ex = '1' else imm_value;
        id_ex_rs1_in  <= (others => '0') when bubble_id_ex = '1' else reg1_out;
        id_ex_rs2_in  <= (others => '0') when bubble_id_ex = '1' else reg2_out;

        if_id_reset <= reset;
	    id_ex_reset <= reset;
	    ex_mem_reset <= reset;
        -- Stall PC/IF on hazard; always advance PC on a taken branch/jump in EX
        pc_write_en   <= branch_taken_ex or (not hazard_mux);
        -- On branch/jump taken, overwrite IF/ID with bubble (must still clock in)
        if_id_write_en <= (not hazard_mux) or branch_taken_ex;
        -- Control signals for ID/EX: zero out everything when a bubble is inserted
        id_ex_memtoreg_in    <= '0' when bubble_id_ex = '1' else control_memtoreg;
        id_ex_regwrite_in    <= '0' when bubble_id_ex = '1' else control_regwrite;
        id_ex_branch_in      <= '0' when bubble_id_ex = '1' else control_branch;
        id_ex_branch_type_in <= "000" when bubble_id_ex = '1' else control_branch_type;
        id_ex_jal_in         <= '0' when bubble_id_ex = '1' else control_jal;
        id_ex_jalr_in        <= '0' when bubble_id_ex = '1' else control_jalr;
        id_ex_memread_in     <= '0' when bubble_id_ex = '1' else control_memread;
        id_ex_memwrite_in    <= '0' when bubble_id_ex = '1' else control_memwrite;
        id_ex_alu_src_in     <= '0' when bubble_id_ex = '1' else control_alu_src;
        id_ex_alu_op_in      <= "00000" when bubble_id_ex = '1' else control_alu_op;
        id_ex_auipc_in       <= '0' when bubble_id_ex = '1' else control_auipc;

        -- Sequential next PC (Used when branch/jump is taken)
        PC_next <= std_logic_vector(unsigned(PC) + 4);
        
        -- Holds the current program counter
        PC_reg: entity work.reg
            port map(
                clk      => clk,
                reset    => reset,
                en       => pc_write_en,
                data_in  => mux_out,
                data_out => PC
            );

        -- Fetch word at current PC (PC_next would skip address 0 when PC = 0)
        instr_addr <= to_integer(unsigned(PC)) / 4;

        -- Instruction Memory (read-only)
        instruction_mem: entity work.memory
            generic map(
                ram_size => 1024
            )
            port map(
                clock       => clk,
                address     => instr_addr,
                memread     => '1',
                memwrite    => '0',
                writedata   => (others => '0'),
                readdata    => instruction,
                waitrequest => open
            );

        -- PC MUX: selects between sequential PC+4 and the resolved branch/jump target
        mux: entity work.MUX_2_1_32bit
    		port map(
        		A => PC_next,
        		B => pc_target_ex,
       			S => branch_taken_ex,
        		Y => mux_out
    		);

        -- Squash wrong-path fetch after branch/jump resolves in EX
        if_id_ir_in <= BUBBLE_IR when branch_taken_ex = '1' else instruction;
        if_id_pc_in <= PC;
        
        -- IF/ID Pipeline Regoster: latched PC and instruction end of IF
        if_id_reg: entity work.if_id_register
            port map(
                clk    => clk,
                reset  => if_id_reset,
                en     => if_id_write_en,
                pc_in  => if_id_pc_in,
                ir_in  => if_id_ir_in,
                pc_out => IF_ID_PC,
                ir_out => IF_ID_IR
            );

        -- Compute register file addresses
        rs1_addr <= to_integer(unsigned(IF_ID_IR(19 downto 15)));
        rs2_addr <= to_integer(unsigned(IF_ID_IR(24 downto 20)));
        rd_addr <= to_integer(unsigned(ID_WB_IR(11 downto 7)));

        -- Register File: Reads rs1 and rs2 in ID, write rd in WB
        register_file: entity work.register_file
            port map(
                clock => clk,
                rs1_addr => rs1_addr,
                rs2_addr => rs2_addr,
                rd_addr => rd_addr,
                rd_data => wb_data, 
                rd_write => control_regwrite_wb,
                rs1_data => reg1_out,
                rs2_data => reg2_out
            );

        -- Immediate Generator: sign-extends the immediate field based on
        -- instruction type
        sign_extender: entity work.imm_gen
            port map(
                instruction => IF_ID_IR,
                imm_out => imm_value
            );
        -- Control Unit: decodes opcode/funct3/funct7 into pipeline control signals
        control_unit: entity work.control
            port map(
                opcode => IF_ID_IR(6 downto 0),
                funct3 => IF_ID_IR(14 downto 12),
                funct7 => IF_ID_IR(31 downto 25),
                alu_ctrl    => control_alu_op,
                memtoreg    => control_memtoreg,
                regwrite    => control_regwrite,
                branch      => control_branch,
                branch_type => control_branch_type,
                jal         => control_jal,
                jalr        => control_jalr,
                memread     => control_memread,
                memwrite    => control_memwrite,
                alu_src     => control_alu_src,
                auipc => control_auipc
            );

        -- ID/EX register: latched decoded values and control signals
        id_ex_register: entity work.id_ex_register
            port map(
                clk => clk,
                reset  => id_ex_reset,
                en => '1',
                -- Input ports
                pc_in => IF_ID_PC,
                ir_in => id_ex_ir_in,
                ir_in_ext => id_ex_imm_in,
                rs1_in => id_ex_rs1_in,
                rs2_in => id_ex_rs2_in,
                -- Output ports
                pc_out => ID_EX_PC,
                ir_out => ID_EX_IR,
                rs1_out => register1ex_out,
                rs2_out => register2ex_out,
                ir_out_ext => immex_val,
                -- Input control signals
                memtoreg_in_control    => id_ex_memtoreg_in,
                regwrite_in_control    => id_ex_regwrite_in,
                branch_in_control      => id_ex_branch_in,
                branch_type_in_control => id_ex_branch_type_in,
                jal_in_control         => id_ex_jal_in,
                jalr_in_control        => id_ex_jalr_in,
                memread_in_control     => id_ex_memread_in,
                memwrite_in_control    => id_ex_memwrite_in,
                alu_src_in_control     => id_ex_alu_src_in,
                alu_op_in_control      => id_ex_alu_op_in,
                -- Output control signals
                memtoreg_out_control => control_memtoreg_ex,
                regwrite_out_control => control_regwrite_ex,
                branch_out_control => control_branch_ex,
                branch_type_out_control => control_branch_type_ex,
                jal_out_control => control_jal_ex,
                jalr_out_control => control_jalr_ex,
                memread_out_control => control_memread_ex,
                memwrite_out_control => control_memwrite_ex,
                alu_src_out_control => control_alu_src_ex,
                alu_op_out_control => control_alu_op_ex,

                -- AUIPC
                auipc_in_control  => id_ex_auipc_in,
                auipc_out_control => control_auipc_ex
            );
        
        -- Forwarding is not required for full marks, implement only 1 MUX
        -- Selects register value or sign-extended immediate value
        mux_ex: entity work.MUX_2_1_32bit
            port map(
                A => register2ex_out,
                B => immex_val,
                S => control_alu_src_ex,
                Y => alu_in_2
            );
        
        -- AUIPC
        -- Selects rs1 or current PC
        mux_ex_a: entity work.MUX_2_1_32bit
            port map(
                A => register1ex_out,
                B => pc_base_ex,
                S => control_auipc_ex,
                Y => alu_in_1
            );
        
        -- ALU: Executes the operation
        alu_unit: entity work.alu
            port map(
                A => alu_in_1,
                B => alu_in_2,
                alu_ctrl => control_alu_op_ex,
                result => alu_result,
                zero => alu_zero
            );

        -- Branch/jump target and condition calculations in EX stage
        pc_base_ex <= ID_EX_PC;
        branch_condition_ex <=
            '1' when control_branch_type_ex = "000" and register1ex_out = register2ex_out else
            '1' when control_branch_type_ex = "001" and register1ex_out /= register2ex_out else
            '1' when control_branch_type_ex = "100" and signed(register1ex_out) < signed(register2ex_out) else
            '1' when control_branch_type_ex = "101" and signed(register1ex_out) >= signed(register2ex_out) else
            '1' when control_branch_type_ex = "110" and unsigned(register1ex_out) < unsigned(register2ex_out) else
            '1' when control_branch_type_ex = "111" and unsigned(register1ex_out) >= unsigned(register2ex_out) else
            '0';
        branch_taken_ex <= (control_branch_ex and branch_condition_ex) or control_jal_ex or control_jalr_ex;
        bubble_id_ex    <= hazard_mux or branch_taken_ex;
        link_ex <= control_jal_ex or control_jalr_ex;
        jal_target_ex <= std_logic_vector(signed(pc_base_ex) + signed(immex_val));
        jalr_target_raw_ex <= std_logic_vector(signed(register1ex_out) + signed(immex_val));
        jalr_target_ex <= jalr_target_raw_ex(31 downto 1) & '0';
        pc_target_ex <= jal_target_ex when control_jal_ex = '1' else
                        jalr_target_ex when control_jalr_ex = '1' else
                        std_logic_vector(signed(pc_base_ex) + signed(immex_val));

        -- EX/MEM register: latched ALU result, store data and control signals
        ex_mem_register: entity work.ex_mem_register
            port map(
                clk => clk,
                reset => ex_mem_reset,
                en => '1',
                alu_result_in => alu_result,
                alu_zero_in => alu_zero,
                rs2_in => register2ex_out,
                ir_in => ID_EX_IR,
                pc_in => ID_EX_PC,
                pc_target_in => pc_target_ex,
                pc_taken_in => branch_taken_ex,
                link_in_control => link_ex,
                memtoreg_in_control => control_memtoreg_ex,
                regwrite_in_control => control_regwrite_ex,
                branch_in_control => control_branch_ex,
                memread_in_control => control_memread_ex,
                memwrite_in_control => control_memwrite_ex,
                ir_out => ID_MEM_IR,
                alu_result_out => alu_result_mem,
                alu_zero_out => alu_zero_mem,
                rs2_out => rs2_out_mem,
                pc_out => pc_plus4_mem,
                pc_target_out => pc_target_mem,
                pc_taken_out => pc_taken_mem,
                link_out_control => control_link_mem,
                memtoreg_out_control => control_memtoreg_mem,
                regwrite_out_control => control_regwrite_mem,
                branch_out_control => control_branch_mem,
                memread_out_control => control_memread_mem,
                memwrite_out_control => control_memwrite_mem
            );

        -- Compute data address
        -- Convert ALU byte address to a word index for the memory array
        data_addr <= to_integer(unsigned(alu_result_mem))/4;
        -- Data memory: 2048 words
        data_mem: entity work.memory
            generic map(
                ram_size => 8192
            )
            port map(
                clock       => clk,
                address     => data_addr,
                memread     => control_memread_mem,
                memwrite    => control_memwrite_mem,
                writedata   => rs2_out_mem,
                readdata    => data_mem_read,
                waitrequest => open
            );
        
        -- MEM/WB register: latched memory read data, ALU result, and link/control
        -- signals for the WB stage
        mem_wb_register: entity work.mem_wb_register
            port map(
                clk => clk,
                reset => reset,
                en => '1',
                data_in => data_mem_read,
                alu_result_in => alu_result_mem,
                pc_in => pc_plus4_mem,
                ir_in => ID_MEM_IR,
                link_in_control => control_link_mem,
                memtoreg_in_control => control_memtoreg_mem,
                regwrite_in_control => control_regwrite_mem,
                data_out => write_data,
                alu_result_out => alu_result_wb,
                pc_out => pc_plus4_wb,
                ir_out => ID_WB_IR,
                link_out_control => control_link_wb,
                memtoreg_out_control => control_memtoreg_wb,
                regwrite_out_control => control_regwrite_wb
            );

        -- Select between ALU result and data memory output
        wb_mux0: entity work.MUX_2_1_32bit
            port map(
                A => alu_result_wb,
                B => write_data, 
                S => control_memtoreg_wb,
                Y => alu_mem_wb
            );

        -- Override with the link return address for JAL/JALR
        wb_mux1: entity work.MUX_2_1_32bit
            port map(
                A => alu_mem_wb,
                B => wb_link_pc_plus4,
                S => control_link_wb,
                Y => wb_data
            );
        -- The hazard detection control
        -- detects when an instruction is a load in EX
        -- and the following instruction in ID reads the same register
        -- Assert hazard_mux one cycle to freeze the PC and IG/ID
        -- Insert a NOP bubble into ID/EX
        -- No forwarding is implemented
        hazard_control: entity work.control_hazard
            port map(
                decode_inst_reg1 => IF_ID_IR(19 downto 15),
                decode_inst_reg2 => IF_ID_IR(24 downto 20),
                ex_inst_dest     => ID_EX_IR(11 downto 7),
                ex_regwrite      => control_regwrite_ex,
                mem_inst_dest    => ID_MEM_IR(11 downto 7),
                mem_regwrite     => control_regwrite_mem,
                wb_inst_dest     => ID_WB_IR(11 downto 7),
                wb_regwrite      => control_regwrite_wb,
                hazard_out       => hazard_mux
            );

end behavioral;