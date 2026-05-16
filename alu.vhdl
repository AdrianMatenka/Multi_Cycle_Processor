----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: alu - struct
-- Description: 32-bit Arithmetic Logic Unit (ALU) supporting arithmetic,
--              logical, comparison, and shift operations. Generates a Zero flag.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port(
        SrcA        : in STD_LOGIC_VECTOR(31 downto 0);
        SrcB        : in STD_LOGIC_VECTOR(31 downto 0);
        ALUControl  : in STD_LOGIC_VECTOR(2 downto 0);
        Zero        : out STD_LOGIC;
        ALUResult   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end;

architecture struct of alu is
    signal Result   : STD_LOGIC_VECTOR(31 downto 0);
begin
    -- Combinational execution unit executing operations based on ALUControl selection
    process(all)
    begin

        case ALUControl is

            when "000" => Result <= (SrcA and SrcB);
            when "001" => Result <= (SrcA or SrcB);
            when "010" => Result <= STD_LOGIC_VECTOR(signed(SrcA) + signed(SrcB));
            when "110" => Result <= STD_LOGIC_VECTOR(signed(SrcA) - signed(SrcB));
            when "111" => 
                            -- Set Less Than (SLT) operation using signed comparison
                            if (signed(SrcA) < signed(SrcB)) then
                                Result <= x"00000001";
                            else
                                Result <= x"00000000";
                            end if;
            when "011" => Result <= STD_LOGIC_VECTOR(shift_right(unsigned(SrcB), to_integer(unsigned(SrcA(4 downto 0)))));
            when "100" => Result <= (SrcA xor SrcB);
            when others => Result <= x"00000000";  

        end case;

    end process;

    -- Zero flag generation used for branch instructions (e.g., beq, bne)
    Zero <= '1' when Result = x"00000000" else '0';

    -- Output drive
    ALUResult <= Result;

end struct;