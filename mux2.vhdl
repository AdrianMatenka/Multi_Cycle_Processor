----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: mux2 - struct
-- Description: Generic 2-to-1 multiplexer block used extensively for switching
--              between alternate data and address paths depending on control lines.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2 is
    generic (
        WIDTH       : INTEGER := 32
    );

    port(
        Input1          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        Input2          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        MUXControl      : in STD_LOGIC;
        MUXResult       : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
    );
end;

architecture struct of mux2 is
    signal Result       : STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
begin

    -- Combinational process choosing between Input1 (control = '0') and Input2 (control = '1')
    process (all)
    begin

        case MUXControl is
            when '0' => Result <= Input1;
            when '1' => Result <= Input2;
            when others => Result <= (others => '0');
        end case;

    end process;

    -- Driving output results continuously
    MUXResult <= Result;

end struct;