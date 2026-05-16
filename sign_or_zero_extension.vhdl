----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: sign_or_zero_extension - struct
-- Description: Configurable sign or zero extension unit. Extends an immediate
--              field (e.g., 16-bit) to the full datapath width (e.g., 32-bit).
--              Controlled by SIGNNEXT to switch between arithmetic (sign-extended)
--              and logical (zero-extended) immediate operations.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_or_zero_extension is
    generic (
        WIDTH_IN            : integer := 16;
        WIDTH_OUT           : INTEGER := 32
    );

    port(
        A                   : in STD_LOGIC_VECTOR(WIDTH_IN - 1 downto 0);
        SIGNNEXT            : in STD_LOGIC;
        Y                   : out STD_LOGIC_VECTOR(WIDTH_OUT - 1 downto 0)
    );
end;

architecture struct of sign_or_zero_extension is
    signal sign_bit : std_logic;
begin

    -- Select extension bit: MSB of input for sign extension, '0' for zero extension
    sign_bit <= A(WIDTH_IN - 1) when SIGNNEXT = '1' else '0';
    
    -- Concatenate the duplicated extension bits with the original input vector
    Y <= (WIDTH_OUT - 1 downto WIDTH_IN => sign_bit) & A;

end struct;