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
    -- For the PC
    signal PC          : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_next     : std_logic_vector(31 downto 0);
    -- For the instruction memory
    signal instruction : std_logic_vector(31 downto 0);
    -- For the IF/ID register
    signal IF_ID_PC    : std_logic_vector(31 downto 0);
    signal IF_ID_IR    : std_logic_vector(31 downto 0);
    signal branch_mux_out : std_logic_vector(31 downto 0);
    -- For the MUX
    signal mux_out : std_logic_vector(31 downto 0);
    signal alu_result_out : std_logic_vector(31 downto 0);
    signal branch_taken_out : std_logic_vector(31 downto 0);
    -- For the register file
    signal MEM_WB_IR : std_logic_vector(31 downto 0);
    signal MEM_WB_MUX : std_logic_vector(31 downto 0);
    signal reg1_out : std_logic_vector(31 downto 0);
    signal reg2_out : std_logic_vector(31 downto 0);
    signal MEM_WB_write : std_logic := '0';
    signal WB_data : std_logic_vector(31 downto 0);
    -- For the sign extender
    signal imm_value : std_logic_vector(31 downto 0);

begin

    PC_next <= std_logic_vector(unsigned(PC) + 4);

    PC_reg: entity work.reg
        port map(
            clk      => clk,
            reset    => reset,
            en       => '1',
            data_in  => PC_next,
            data_out => PC
        );

    instruction_mem: entity work.memory
        port map(
            clock       => clk,
            address     => to_integer(unsigned(PC)),
            memread     => '1',
            memwrite    => '0',
            writedata   => (others => '0'),
            readdata    => instruction,
            waitrequest => open
        );

    mux: entity work.MUX_2_1
        port map(
            A => PC_next,
            B => alu_result_out,
            S => branch_taken_out,
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
            rd_addr => to_integer(unsigned(MEM_WB_IR(11 downto 7))),
            rd_data => WB_data, 
            rd_write => MEM_WB_write,
            rs1_data => reg1_out,
            rs2_data => reg2_out
        );

    sign_extender: entity work.imm_gen
        port map(
            instruction => to_integer(unsigned(IF_ID_IR(31 downto 20))),
            imm_out => imm_value
        );
    
    
    

end behavioral;