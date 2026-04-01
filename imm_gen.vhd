library IEEE;
use IEEE.std_logic_1164.all;

entity imm_gen is
    port(
        instruction: in std_logic_vector(31 downto 0);
        imm_out: out std_logic_vector(31 downto 0)
    );
end imm_gen;

architecture behaviour of imm_gen is
    signal opcode: std_logic_vector(6 downto 0);
begin
    process(instruction,opcode)
    begin
        imm_out<=(others=>'0');
        case opcode is
            -- I-type: ALU immediates, LW, JALR
            when "0010011" | "0000011" | "1100111" =>
                imm_out(31 downto 12)<=(others=>instruction(31)); --sign extend
                imm_out(11 downto 0)<=(others=>instruction(31 downto 20));
            
            -- S-type: SW
            when "0100011" =>
                imm_out(31 downto 12)<=(others=>instruction(31)); --sign extend
                imm_out(11 downto 5)<=(others=>instruction(31 downto 25));
                imm_out(4 downto 0)<=(others=>instruction(11 downto 7));

            -- B-type: Branch instructions
            when "1100011" =>
                imm_out(31 downto 12)<=(others=>instruction(31)); --sign extend
                imm_out(11)<=instruction(7);
                imm_out(10 downto 5)<=instruction(30 downto 25);
                imm_out(4 downto 1)<=instruction(11 downto 8);
                imm_out(0)<='0'; --even address
            
            -- J-type: JAL
            when "1101111" =>
                imm_out(31 downto 12)<=(others=>instruction(31)); --sign extend
                imm_out(19 downto 12)<=instruction(19 downto 12);
                imm_out(11)<=instruction(20);
                imm_out(10 downto 1)<=instruction(30 downto 21);
                imm_out(0)<='0'; --even address
            
            -- U-type: LUI, AUIPC
            when "0110111" | "0010111" =>
                imm_out(31 downto 12)<=instruction(31 downto 12);
                imm_out(11 downto 0)<=(others=>'0'); 
            
            when others =>
                imm_out<=(others=>'0');
        end case;
    end process;
end behaviour;
