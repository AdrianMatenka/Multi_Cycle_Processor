----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: byte_select - struct
-- Description: Byte selection unit used for executing byte-load instructions 
--              (e.g., lbu). Extracts a specific 8-bit byte from a 32-bit word 
--              and zero-extends it to match the full register width.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity byte_select is
    generic (
        WIDTH       : INTEGER := 32
    );

    port(
        Input               : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        ByteSelect          : in STD_LOGIC_VECTOR(1 downto 0);
        ByteSelected        : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
    );
end;

architecture struct of byte_select is
    signal Result       : STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
begin

    -- Combinational process to extract and zero-extend the chosen byte
    process (all)
    begin

        case ByteSelect is
            when "00" => Result <= x"000000" & Input(7 downto 0);
            when "01" => Result <= x"000000" & Input(15 downto 8);
            when "10" => Result <= x"000000" & Input(23 downto 16);
            when "11" => Result <= x"000000" & Input(31 downto 24);
            when others => Result <= (others => '0');
        end case;

    end process;

    -- Continuous assignment to drive the selected byte output
    ByteSelected <= Result;

end struct;