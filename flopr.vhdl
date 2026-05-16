----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: flopenr - asynchronous
-- Description: Parameterizable Flip-Flop with an active-high Synchronous/Asynchronous
--              Enable and an Asynchronous Reset. Used extensively as pipeline/
--              state registers within the architecture.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flopenr is
    generic (
        WIDTH               : INTEGER := 32
    );

    port(
        CLK, reset          : in STD_LOGIC;
        EN                  : in STD_LOGIC;
        D                   : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        Q                   : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
    );
end;

architecture asynchronous of flopenr is
begin

    -- Sequential process capturing asynchronous reset and rising edge clock event
    process(CLK, reset)
    begin

        if reset then
            Q <= (others => '0');
        elsif rising_edge(CLK) then
            if EN then
                Q <= D;
            end if;
        end if;

    end process;

end;