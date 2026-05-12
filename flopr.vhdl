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