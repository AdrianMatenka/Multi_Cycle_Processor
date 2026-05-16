----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: tb_top - sim
-- Description: Simulation Testbench for the complete integrated MIPS system.
--              Generates the master clock signal, handles system initialization 
--              via a dedicated reset phase, and supervises simulation execution.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end;

architecture sim of tb_top is
    -- Internal testbench stimulator and monitor signals
    signal clk   : std_logic := '0';
    signal reset : std_logic;
    signal writedata : std_logic_vector(31 downto 0);
    signal adr       : std_logic_vector(31 downto 0);
    signal memwrite  : std_logic;

    -- 100 MHz clock configuration constant (10 ns clock period)
    constant T : time := 10 ns;

begin
    -- Unit Under Test (UUT) structural instantiation
    uut: entity work.top port map (
        clk       => clk,
        reset     => reset,
        writedata => writedata,
        adr       => adr,
        memwrite  => memwrite
    );

    -- Continuous clock toggle loop generator
    clk <= not clk after T/2;

    -- Main stimulus process driving the multi-cycle execution sequence
    process
    begin
        -- Assert asynchronous system reset sequence
        reset <= '1';
        wait for T * 2.2; -- Hold reset for two full clock cycles and an offset fraction
        reset <= '0';
        
        -- Reset dropped: Processor enters state S0 (Fetch) and begins loading 
        -- assembly instructions decoded from the external memfile.txt block.
        wait for T * 250; 

        -- Stop simulation execution and report final validation status
        assert false report "Simulation Finished Successfully" severity failure;
    end process;

end architecture;