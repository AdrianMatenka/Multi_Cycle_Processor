----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: register_file - struct
-- Description: Dual-read, single-write 32-bit MIPS Register File. 
--              Hardwires register 0 to constant zero to satisfy the standard 
--              MIPS ISA specification requirement ($zero register).
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    port(
        CLK                 : in STD_LOGIC;
        WE3                 : in STD_LOGIC;
        A1, A2, A3          : in STD_LOGIC_VECTOR(4 downto 0);
        WD3                 : in STD_LOGIC_VECTOR(31 downto 0);
        RD1, RD2            : out STD_LOGIC_VECTOR(31 downto 0)
    );
end;

architecture struct of register_file is
    -- Internal 32x32-bit register array type definition initialized to zeros
    type ram_type is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal registers : ram_type := (others => (others => '0'));
begin

    -- Synchronous write block operating on the rising edge of the clock
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Prevent writing to register $0, preserving its constant value of 0
            if (WE3 = '1' and to_integer(unsigned(A3)) /= 0) then 
                registers(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;

    -- Combinational read logic with hardwired zero logic for address 0
    RD1 <= x"00000000" when to_integer(unsigned(A1)) = 0 else registers(to_integer(unsigned(A1)));
    RD2 <= x"00000000" when to_integer(unsigned(A2)) = 0 else registers(to_integer(unsigned(A2)));

end struct;