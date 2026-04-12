library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_hazard is
    port(
        decode_inst_reg1  : in std_logic_vector(4 downto 0);  -- rs1 in ID
        decode_inst_reg2  : in std_logic_vector(4 downto 0);  -- rs2 in ID
        ex_inst_dest      : in std_logic_vector(4 downto 0);  -- rd in EX
        ex_regwrite       : in std_logic;                     -- regwrite in EX
        mem_inst_dest     : in std_logic_vector(4 downto 0);  -- rd in MEM
        mem_regwrite      : in std_logic;                     -- regwrite in MEM

        pc_write          : out std_logic;
        if_id_write       : out std_logic;
        hazard_out        : out std_logic
    );
end entity;

architecture behavioral of control_hazard is
begin
    process(ex_regwrite, ex_inst_dest, mem_regwrite, mem_inst_dest, decode_inst_reg1, decode_inst_reg2)
    begin
        -- EX stage has a pending write that ID stage needs
        if (ex_regwrite = '1' and ex_inst_dest /= "00000"
            and (ex_inst_dest = decode_inst_reg1 or ex_inst_dest = decode_inst_reg2)) then
            pc_write    <= '0';
            if_id_write <= '0';
            hazard_out  <= '1';

        -- MEM stage has a pending write that ID stage needs
        elsif (mem_regwrite = '1' and mem_inst_dest /= "00000"
            and (mem_inst_dest = decode_inst_reg1 or mem_inst_dest = decode_inst_reg2)) then
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