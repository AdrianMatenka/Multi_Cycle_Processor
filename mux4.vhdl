----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: mux4 - struct
-- Description: Generic 4-to-1 multiplexer block. It routes one of the four
--              WIDTH-bit input vectors to the output based on a 2-bit select signal.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux4 is
    generic (
        WIDTH       : INTEGER := 32
    );

    port(
        Input1          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        Input2          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        Input3          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        Input4          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        MUXControl      : in STD_LOGIC_VECTOR(1 downto 0);
        MUXResult       : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
    );
end;

architecture struct of mux4 is
    signal Result       : STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
begin

    -- Combinational process for input selection based on the 2-bit control bus
    process (all)
    begin

        case MUXControl is
            when "00" => Result <= Input1;
            when "01" => Result <= Input2;
            when "10" => Result <= Input3;
            when "11" => Result <= Input4;
            when others => Result <= (others => '0');
        end case;

    end process;

    -- Driving output continuously
    MUXResult <= Result;

end struct;