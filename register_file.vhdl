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
    type ram_type is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal registers : ram_type := (others => (others => '0'));
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if (WE3 = '1' and to_integer(unsigned(A3)) /= 0) then 
                registers(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;

    RD1 <= x"00000000" when to_integer(unsigned(A1)) = 0 else registers(to_integer(unsigned(A1)));
    RD2 <= x"00000000" when to_integer(unsigned(A2)) = 0 else registers(to_integer(unsigned(A2)));

end struct;