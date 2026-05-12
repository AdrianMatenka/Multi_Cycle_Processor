library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench for the complete MIPS Multi-cycle system
entity tb_top is
end;

architecture sim of tb_top is
    -- Signal declarations
    signal clk   : std_logic := '0';
    signal reset : std_logic;
    signal writedata : std_logic_vector(31 downto 0);
    signal adr       : std_logic_vector(31 downto 0);
    signal memwrite  : std_logic;

    -- Clock period definition
    constant T : time := 10 ns;

begin
    -- Unit Under Test (UUT) instantiation
    uut: entity work.top port map (
        clk       => clk,
        reset     => reset,
        writedata => writedata,
        adr       => adr,
        memwrite  => memwrite
    );

    -- Clock generation
    clk <= not clk after T/2;

    -- Stimulus process
    process
    begin
        -- Initial reset sequence
        reset <= '1';
        wait for T * 2.2; -- Reset for two full cycles and a bit
        reset <= '0';
        
        -- The processor will now start fetching instructions from the RAM.
        -- We wait for enough time to let the program finish its cycles.
        -- Given the memfile.txt has 5 instructions, each taking 3-5 cycles:
        wait for T * 250; 

        -- End simulation
        assert false report "Simulation Finished" severity failure;
    end process;

end architecture;