library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_decoder is
    port(
        ALUOp        : in STD_LOGIC_VECTOR(1 downto 0);
        Funct        : in STD_LOGIC_VECTOR(5 downto 0);
        ALUControl   : out STD_LOGIC_VECTOR(2 downto 0)
    );
end;

architecture struct of alu_decoder is
    signal Control   : STD_LOGIC_VECTOR(2 downto 0);
begin
    process(all)
    begin

        case ALUOp is

            when "00" => Control <= "010";                          -- add (for lb/sb/addi)
            when "01" => Control <= "110";                          -- sub (for beq)    
            when others =>  case funct is                           -- R-type instructions
                                when "100000"   => Control <= "010";-- add
                                when "100010"   => Control <= "110";-- sub
                                when "100100"   => Control <= "000";-- and
                                when "100101"   => Control <= "001";-- or
                                when "101010"   => Control <= "111";-- slt
                                when others     => Control <= "000";-- ???
                            end case; 

        end case;

    end process;

    ALUControl <= Control;

end struct;