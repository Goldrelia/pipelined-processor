-- just to remember 
-- How to wire the register file in this:
reg_file : register_file
    port map (
        clock    => clock,
        rs1_addr => to_integer(unsigned(IF_ID_IR(19 downto 15))),
        rs2_addr => to_integer(unsigned(IF_ID_IR(24 downto 20))),
        rs1_data => ID_EX_A,
        rs2_data => ID_EX_B,
        rd_addr  => to_integer(unsigned(MEM_WB_IR(11 downto 7))),
        rd_data  => WB_data,
        rd_write => MEM_WB_RegWrite
    );

