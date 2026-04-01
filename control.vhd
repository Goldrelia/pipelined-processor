library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control is
    port(
        opcode   : in std_logic_vector(6 downto 0);
        funct3   : in std_logic_vector(2 downto 0);
        funct7   : in std_logic_vector(6 downto 0);
        alu_ctrl : out std_logic_vector(4 downto 0)
    );
end entity;

architecture behavioral of control is
begin
    process(opcode, funct3, funct7)
    begin
        alu_ctrl <= (others=>'0');

        case opcode is
            -- R-type
            when "0110011" =>
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
                case funct3 is
                    when "000" => alu_ctrl <= "00000";   -- ADDI
                    when "100" => alu_ctrl <= "01111";   -- XORI
                    when "110" => alu_ctrl <= "00011";   -- ORI
                    when "111" => alu_ctrl <= "00100";   -- ANDI
                    when "010" => alu_ctrl <= "01000";   -- SLTI
                    when others => alu_ctrl <= (others=>'0');
                end case;

            -- Load / Store
            when "0000011" | "0100011" => alu_ctrl <= "01100"; -- LW/SW address calculation

            -- Branches
            when "1100011" => alu_ctrl <= "01101"; -- BEQ/BNE/BLT/BGE

            -- JAL / JALR
            when "1101111" | "1100111" => alu_ctrl <= "01110";

            -- LUI / AUIPC
            when "0110111" => alu_ctrl <= "01010"; -- LUI
            when "0010111" => alu_ctrl <= "01011"; -- AUIPC

            when others => alu_ctrl <= (others=>'0');
        end case;
    end process;

end architecture behavioral;
