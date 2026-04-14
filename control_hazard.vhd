
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_hazard is
    port(
        decode_inst_reg1  : in std_logic_vector(4 downto 0);
        decode_inst_reg2  : in std_logic_vector(4 downto 0);
        ex_inst_dest      : in std_logic_vector(4 downto 0);
        ex_regwrite       : in std_logic;
        pc_write          : out std_logic;
        if_id_write       : out std_logic;
        hazard_out        : out std_logic
    );
end entity;

architecture behavioral of control_hazard is
begin
    process(ex_regwrite, ex_inst_dest, decode_inst_reg1, decode_inst_reg2)
    begin
        if (ex_regwrite = '1' and ex_inst_dest /= "00000"
            and (ex_inst_dest = decode_inst_reg1 or ex_inst_dest = decode_inst_reg2)) then
            pc_write    <= '0';
            if_id_write <= '0';
            hazard_out  <= '1';
        else
            pc_write    <= '1';
            if_id_write <= '1';
            hazard_out  <= '0';
        end if;
    end process;
end behavioral;