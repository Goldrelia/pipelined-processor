LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- 32x32-bit register file for RISC-V RV32I
-- Two asynchronous read ports (rs1, rs2) ?> read combinationally in ID stage
-- One synchronous write port (rd) -> written on rising edge in WB stage
-- x0 is hardwired to 0x00000000: writes to x0 are silently ignored,
-- reads from x0 always return 0 regardless of stored value

ENTITY register_file IS
    PORT (
        clock    : IN  STD_LOGIC;

        -- Read ports (ID stage) ? asynchronous, results available same cycle
        -- since want outputs immediately
        rs1_addr : IN  INTEGER RANGE 0 TO 31;
        rs2_addr : IN  INTEGER RANGE 0 TO 31;
        rs1_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rs2_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Write port (WB stage) ? synchronous, write on rising clock edge
        -- since do not want the values in the register file to change mid-cycle
        -- while another instructions is already in the middle of reading
        rd_addr  : IN  INTEGER RANGE 0 TO 31;
        rd_data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_write : IN  STD_LOGIC  -- write enable; assert '1' to write
    );
END register_file;

ARCHITECTURE rtl OF register_file IS

    -- 32 registers, each 32 bits wide
    TYPE REG_FILE IS ARRAY(0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL regs : REG_FILE := (OTHERS => (OTHERS => '0'));

BEGIN

    -- Synchronous write (WB stage)
    -- x0 is never written ? any instruction with rd = x0 is a no-op write
    write_proc : PROCESS(clock)
    BEGIN
        IF rising_edge(clock) THEN
            -- never write to x0
            IF rd_write = '1' AND rd_addr /= 0 THEN
                regs(rd_addr) <= rd_data;
            END IF;
        END IF;
    END PROCESS;

    -- Asynchronous read (ID stage)
    -- x0 always returns 0 regardless of what is stored
    rs1_data <= (OTHERS => '0') WHEN rs1_addr = 0 ELSE regs(rs1_addr);
    rs2_data <= (OTHERS => '0') WHEN rs2_addr = 0 ELSE regs(rs2_addr);

END rtl;