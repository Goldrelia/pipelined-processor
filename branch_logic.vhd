library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch_logic is
    port(
        rs1_data    : in  std_logic_vector(31 downto 0);
        rs2_data    : in  std_logic_vector(31 downto 0);
        funct3      : in  std_logic_vector(2 downto 0);
        branch_en   : in  std_logic; -- '1' if the instruction is a branch
        take_branch : out std_logic  -- '1' if the condition is met
    );
end entity;

architecture behavioral of branch_logic is
begin
    process(rs1_data, rs2_data, funct3, branch_en)
        variable r1_signed : signed(31 downto 0);
        variable r2_signed : signed(31 downto 0);
        variable r1_unsig  : unsigned(31 downto 0);
        variable r2_unsig  : unsigned(31 downto 0);
    begin
        -- Default to not taking the branch
        take_branch <= '0'; 
        
        if branch_en = '1' then
            r1_signed := signed(rs1_data);
            r2_signed := signed(rs2_data);
            r1_unsig  := unsigned(rs1_data);
            r2_unsig  := unsigned(rs2_data);

            case funct3 is
                when "000" => -- BEQ
                    if r1_signed = r2_signed then take_branch <= '1'; end if;
                when "001" => -- BNE
                    if r1_signed /= r2_signed then take_branch <= '1'; end if;
                when "100" => -- BLT (Less Than)
                    if r1_signed < r2_signed then take_branch <= '1'; end if;
                when "101" => -- BGE (Greater or Equal)
                    if r1_signed >= r2_signed then take_branch <= '1'; end if;
                when "110" => -- BLTU (Less Than Unsigned)
                    if r1_unsig < r2_unsig then take_branch <= '1'; end if;
                when "111" => -- BGEU (Greater or Equal Unsigned)
                    if r1_unsig >= r2_unsig then take_branch <= '1'; end if;
                when others =>
                    take_branch <= '0';
            end case;
        end if;
    end process;
end behavioral;