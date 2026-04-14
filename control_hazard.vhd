library IEEE;
use IEEE.std_logic_1164.all;

entity control_hazard is
    port(
        decode_inst_reg1 : in std_logic_vector(4 downto 0);
        decode_inst_reg2 : in std_logic_vector(4 downto 0);
        ex_inst_dest     : in std_logic_vector(4 downto 0);
        ex_regwrite      : in std_logic;
        mem_inst_dest    : in std_logic_vector(4 downto 0);
        mem_regwrite     : in std_logic;
        wb_inst_dest     : in std_logic_vector(4 downto 0);
        wb_regwrite      : in std_logic;
        hazard_out       : out std_logic
    );
end entity;

architecture behavioral of control_hazard is
begin
    process(
        decode_inst_reg1, decode_inst_reg2,
        ex_inst_dest, ex_regwrite,
        mem_inst_dest, mem_regwrite,
        wb_inst_dest, wb_regwrite
    )
    begin
        hazard_out <= '0';

        if (ex_regwrite = '1' and ex_inst_dest /= "00000" and
            ((ex_inst_dest = decode_inst_reg1 and decode_inst_reg1 /= "00000") or
             (ex_inst_dest = decode_inst_reg2 and decode_inst_reg2 /= "00000"))) or
           (mem_regwrite = '1' and mem_inst_dest /= "00000" and
            ((mem_inst_dest = decode_inst_reg1 and decode_inst_reg1 /= "00000") or
             (mem_inst_dest = decode_inst_reg2 and decode_inst_reg2 /= "00000"))) or
           (wb_regwrite = '1' and wb_inst_dest /= "00000" and
            ((wb_inst_dest = decode_inst_reg1 and decode_inst_reg1 /= "00000") or
             (wb_inst_dest = decode_inst_reg2 and decode_inst_reg2 /= "00000"))) then
            hazard_out <= '1';
        end if;
    end process;
end architecture;
