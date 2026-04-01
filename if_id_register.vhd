library IEEE;
use IEEE.std_logic_1164.all;

entity if_id_register is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;

        --Inputs from IF stage
        pc_in: in std_logic_vector(31 downto 0);
        ir_in: in std_logic_vector(31 downto 0);

        --Outputs to ID stage
        pc_out: out std_logic_vector(31 downto 0);
        ir_out: out std_logic_vector(31 downto 0)
    );
end if_id_register;

architecture structural of if_id_register is
    --Component declaration
    component generic_register is
        generic(N:integer);
        port(
            clk: in std_logic;
            reset: in std_logic;
            en: in std_logic;
            d: in std_logic_vector(N-1 downto 0);
            q: out std_logic_vector(N-1 downto 0)
        );
    end component;
begin
    --Component instantiation
    pc_reg: generic_register --Program Counter
        generic map (N=>32)
        port map(
            clk=>clk,
            reset=>reset,
            en=>en,
            d=>pc_in,
            q=>pc_out
        );
    
    ir_reg: generic_register --Instruction Word
        generic map (N=>32)
        port map(
            clk=>clk,
            reset=>reset,
            en=>en,
            d=>ir_in,
            q=>ir_out
        );
end structural;
