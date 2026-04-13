library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control is
    port(
        opcode   : in std_logic_vector(6 downto 0);
        funct3   : in std_logic_vector(2 downto 0);
        funct7   : in std_logic_vector(6 downto 0);
        alu_ctrl : out std_logic_vector(4 downto 0);

        memtoreg : out std_logic;
        regwrite : out std_logic;
        branch   : out std_logic;
        branch_type : out std_logic_vector(2 downto 0);
        jal      : out std_logic;
        jalr     : out std_logic;
        memread  : out std_logic;
        memwrite : out std_logic;
        alu_src  : out std_logic;
        auipc    : out std_logic
    );
end entity;

architecture behavioral of control is
begin
    process(opcode, funct3, funct7)
    begin
        alu_ctrl <= (others=>'0');
        memtoreg <= '0';
        regwrite <= '0';
        branch   <= '0';
        branch_type <= (others => '0');
        jal      <= '0';
        jalr     <= '0';
        memread  <= '0';
        memwrite <= '0';
        alu_src  <= '0';
        auipc <= '0';

        case opcode is
            -- R-type
            when "0110011" =>
                regwrite <= '1';
                case funct3 is
                    when "000" => 
            		if funct7 = "0000000" then
                		alu_ctrl <= "00000";  -- ADD
            		elsif funct7 = "0100000" then
                		alu_ctrl <= "00001";  -- SUB
            		elsif funct7 = "0000001" then
                		alu_ctrl <= "00010";  -- MUL
            		end if;
                    when "110" => alu_ctrl <= "00011";                     -- OR
                    when "111" => alu_ctrl <= "00100";                     -- AND
                    when "001" => alu_ctrl <= "00101";                     -- SLL
                    when "101" =>
                        if funct7 = "0000000" then alu_ctrl <= "00110";    -- SRL
                        else alu_ctrl <= "00111";                           -- SRA
                        end if;
                    when others => alu_ctrl <= (others=>'0');
                end case;

            -- I-type
            when "0010011" =>
                regwrite <= '1';
                alu_src  <= '1';
                case funct3 is
                    when "000" => alu_ctrl <= "00000";   -- ADDI
                    when "100" => alu_ctrl <= "01111";   -- XORI
                    when "110" => alu_ctrl <= "00011";   -- ORI
                    when "111" => alu_ctrl <= "00100";   -- ANDI
                    when "010" => alu_ctrl <= "01000";   -- SLTI
                    when others => alu_ctrl <= (others=>'0');
                end case;

            -- Load / Store
            when "0000011" => 
                regwrite <= '1';
                memread  <= '1';
                alu_src  <= '1';
                memtoreg <= '1';
                alu_ctrl <= "01100"; -- LW/SW address calculation
            
            when "0100011" => 
                memwrite <= '1';
                alu_src  <= '1';
                alu_ctrl <= "01100"; -- LW/SW address calculation

            -- Branches
            when "1100011" => 
                branch   <= '1';
                branch_type <= funct3;
                alu_ctrl <= "01101"; -- BEQ/BNE/BLT/BGE

            -- JAL
            when "1101111" => 
                regwrite <= '1';
                jal     <= '1';
                
            -- JALR
            when "1100111" => 
                regwrite <= '1';
                jal     <= '0';
                jalr     <= '1';
                alu_src  <= '1';
                alu_ctrl <= "00000"; -- Force ALU to ADD (rs1 + imm)

            -- LUI / AUIPC
            when "0110111" =>
                regwrite <= '1';
                alu_ctrl <= "01010"; -- LUI
            when "0010111" =>
                regwrite <= '1';
                auipc <= '1';
                alu_ctrl <= "01011"; -- AUIPC

            when others => alu_ctrl <= (others=>'0');
        end case;
    end process;

end architecture behavioral;
