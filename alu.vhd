library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port(
        A        : in  std_logic_vector(31 downto 0);  -- rs1 or PC
        B        : in  std_logic_vector(31 downto 0);  -- rs2 or immediate
        alu_ctrl : in  std_logic_vector(4 downto 0);   -- control signal from control.vhd
        result   : out std_logic_vector(31 downto 0);
        zero     : out std_logic
    );
end entity;

architecture behavioral of alu is

    signal rd : std_logic_vector(31 downto 0);       -- ALU output

begin

    process(A, B, alu_ctrl)
        -- signed and unsigned versions of inputs
        variable rs1_signed           : signed(31 downto 0);
        variable rs2_signed_or_imm    : signed(31 downto 0);
        variable rs1_unsigned         : unsigned(31 downto 0);
        variable rs2_unsigned_or_imm  : unsigned(31 downto 0);
        variable shift_amount         : integer range 0 to 31;
        variable mul_result           : signed(63 downto 0);         -- temporary for multiplication
    begin
        -- Convert inputs to signed and unsigned
        rs1_signed          := signed(A);
        rs2_signed_or_imm   := signed(B);
        rs1_unsigned        := unsigned(A);
        rs2_unsigned_or_imm := unsigned(B);
        shift_amount        := to_integer(unsigned(B(4 downto 0)));  -- for shift instructions

        -- Determine ALU operation based on alu_ctrl
        case alu_ctrl is

            -- =======================
            -- R-type and I-type arithmetic/logic
            -- =======================
            when "00000" => rd <= std_logic_vector(rs1_signed + rs2_signed_or_imm);   -- ADD / ADDI
            when "00001" => rd <= std_logic_vector(rs1_signed - rs2_signed_or_imm);   -- SUB
            when "00010" => 
                mul_result := rs1_signed * rs2_signed_or_imm; 
                rd <= std_logic_vector(mul_result(31 downto 0));                      -- MUL
            when "00011" => rd <= A or B;                                              -- OR / ORI
            when "00100" => rd <= A and B;                                             -- AND / ANDI

            -- =======================
            -- Shift instructions
            -- =======================
            when "00101" => rd <= std_logic_vector(shift_left(rs1_unsigned, shift_amount));   -- SLL
            when "00110" => rd <= std_logic_vector(shift_right(rs1_unsigned, shift_amount));  -- SRL
            when "00111" => rd <= std_logic_vector(shift_right(rs1_signed, shift_amount));    -- SRA

            -- =======================
            -- Set less than
            -- =======================
            when "01000" => 
                rd <= (others=>'0'); 
                if rs1_signed < rs2_signed_or_imm then rd(0) <= '1'; end if;             -- SLTI

            -- =======================
            -- U-type instructions
            -- =======================
            when "01010" => rd <= B;                                                       -- LUI (already shifted in imm_gen.vhd)
            when "01011" => rd <= std_logic_vector(rs1_signed + rs2_signed_or_imm);       -- AUIPC

            -- =======================
            -- Load / Store addresses
            -- =======================
            when "01100" => rd <= std_logic_vector(rs1_signed + rs2_signed_or_imm);       -- LW / SW (address calculation)

            -- =======================
            -- XOR
            -- =======================
            when "01111" => rd <= A xor B;                                                 -- XOR / XORI

            -- default case
            when others   => rd <= (others => '0');

        end case;
    end process;

    -- ALU output
    result <= rd;

    -- Zero flag for branch comparisons
    zero   <= '1' when rd = x"00000000" else '0';

end architecture behavioral;