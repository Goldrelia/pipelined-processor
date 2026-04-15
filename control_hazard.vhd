library IEEE;
use IEEE.std_logic_1164.all;

entity control_hazard is
    port(
        --source reg for instruction in decode stage
        decode_inst_reg1 : in std_logic_vector(4 downto 0);
        decode_inst_reg2 : in std_logic_vector(4 downto 0);
        
        --destination reg and write-enable from execute stage
        ex_inst_dest     : in std_logic_vector(4 downto 0);
        ex_regwrite      : in std_logic;
        
        --destination reg and write-enable from memory stage
        mem_inst_dest    : in std_logic_vector(4 downto 0);
        mem_regwrite     : in std_logic;
        
        --destination reg and write-enable from writeback stage
        wb_inst_dest     : in std_logic_vector(4 downto 0);
        wb_regwrite      : in std_logic;
        
        --output flag to see if hazard is detected
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

        --check 3 cases:
        --1: execute data hazard: if instruction immediatly ahead is going to write to needed register right now
        --2: memory data hazard: if instruction 2 cycles ahead is writing to our source register
        --3: writeback data hazard: if instruction 3 cycles ahead is writing to RF
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
