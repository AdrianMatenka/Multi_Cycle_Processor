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
    type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    
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

    signal RAM : ramtype := init_ram("c:/Users/adria/Documents/Harris_Book_Exercises/Multi_Cycle_Processor/memfile.txt");

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                RAM(to_integer(unsigned(a(31 downto 2)))) <= wd;
            end if;
        end if;
    end process;

    rd <= RAM(to_integer(unsigned(a(31 downto 2))));
end behave;