----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: mem - behave
-- Description: Unified instruction and data memory simulation model for MIPS.
--              Includes an impure RAM initialization function that parses external
--              hexadecimal code files during testbench simulation setup.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_textio.all;
use STD.TEXTIO.all;

entity mem is
    port(
        clk, we : in  STD_LOGIC;
        a, wd   : in  STD_LOGIC_VECTOR(31 downto 0);
        rd      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end mem;

architecture behave of mem is
    -- 64-word array definition representing a small fast RAM block
    type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    
    -- Impure function to populate RAM array from a file before simulation starts
    impure function init_ram(file_name : in string) return ramtype is
        file text_file       : text open read_mode is file_name;
        variable text_line   : line;
        variable ram_content : ramtype := (others => (others => '0'));
        variable temp_hex    : std_logic_vector(31 downto 0);
    begin
        for i in 0 to 63 loop
            if not endfile(text_file) then
                readline(text_file, text_line);
                hread(text_line, temp_hex); 
                ram_content(i) := temp_hex;
            end if;
        end loop;
        return ram_content;
    end function;

    -- Instantiating internal memory array and loading instructions from external file path
    signal RAM : ramtype := init_ram("c:/Users/adria/Documents/Harris_Book_Exercises/Multi_Cycle_Processor_ver5/memfile.txt");
    
    -- Safe memory indexing pointer
    signal ram_index : integer range 0 to 63 := 0;

begin

    -- Combinational process guarding memory indexing against undefined 'U/X' states and unaligned addresses
    process(all)
        variable raw_index : integer;
    begin
        if is_X(a) then
            ram_index <= 0;
        else
            -- Drop lower 2 bits to convert byte address into a word-aligned index (a / 4)
            raw_index := to_integer(unsigned(a(31 downto 2)));
            if (raw_index > 63 or raw_index < 0) then
                ram_index <= 0;
            else
                ram_index <= raw_index;
            end if;
        end if;
    end process;

    -- Synchronous memory write operation block
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                RAM(ram_index) <= wd;
            end if;
        end if;
    end process;

    -- Continuous read data assignment (asynchronous read logic)
    rd <= RAM(ram_index);

end behave;