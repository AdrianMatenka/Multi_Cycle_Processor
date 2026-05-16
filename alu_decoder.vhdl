----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: alu_decoder - struct
-- Description: ALU Decoder for the MIPS Control Unit. Maps the ALUOp from the
--              main controller and the Funct field from R-type instructions
--              to the specific ALUControl signals.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_decoder is
    port(
        ALUOp        : in STD_LOGIC_VECTOR(2 downto 0);
        Funct        : in STD_LOGIC_VECTOR(5 downto 0);
        ALUControl   : out STD_LOGIC_VECTOR(2 downto 0)
    );
end;

architecture struct of alu_decoder is
    signal Control   : STD_LOGIC_VECTOR(2 downto 0);
begin
    -- Combinational process to decode ALU operations based on ALUOp and Funct fields
    process(all)
    begin

        case ALUOp is

            when "000" => Control <= "010";                             -- add (for lb/sb/addi)
            when "001" => Control <= "110";                             -- sub (for beq/bne)    
            when "011" => Control <= "001";                             -- ori
            when "100" => Control <= "100";                             -- xori
            when others =>  case funct is                               -- R-type instructions
                                when "100000"   => Control <= "010";    -- add
                                when "100010"   => Control <= "110";    -- sub
                                when "100100"   => Control <= "000";    -- and
                                when "100101"   => Control <= "001";    -- or
                                when "101010"   => Control <= "111";    -- slt
                                when "000110"   => Control <= "011";    -- srlv
                                when others     => Control <= "000";    -- default case for unknown functions
                            end case; 

        end case;

    end process;

    -- Continuous assignment of the internal control signal to the output port
    ALUControl <= Control;

end struct;