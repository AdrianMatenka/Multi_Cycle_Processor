----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: top - struct
-- Description: Complete Top-Level System wrapper. It encapsulates the MIPS core 
--              processor and the unified instruction/data memory component,
--              forming a self-contained processing system.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity top is
    port(
        clk, reset : in  STD_LOGIC;
        writedata  : out STD_LOGIC_VECTOR(31 downto 0);
        adr        : out STD_LOGIC_VECTOR(31 downto 0);
        memwrite   : out STD_LOGIC
    );
end top;

architecture struct of top is
    -- Component declaration for the multi-cycle MIPS core
    component mips
        port(
            CLK, Reset  : in  STD_LOGIC;
            -- External memory interface
            RD          : in  STD_LOGIC_VECTOR(31 downto 0);
            WE          : out STD_LOGIC;
            ADR         : out STD_LOGIC_VECTOR(31 downto 0);
            WD          : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Component declaration for the simulation RAM block
    component mem
        port(
            clk, we : in  STD_LOGIC;
            a, wd   : in  STD_LOGIC_VECTOR(31 downto 0);
            rd      : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Interconnect signals mapping the processor interface to the memory bank
    signal readdata_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal adr_sig      : STD_LOGIC_VECTOR(31 downto 0);
    signal writedata_sig: STD_LOGIC_VECTOR(31 downto 0);
    signal memwrite_sig : STD_LOGIC;

begin
    -- Instantiating the MIPS processor core
    mips_inst: mips port map(
        CLK         => clk,
        Reset       => reset,
        RD          => readdata_sig,
        WE          => memwrite_sig,
        ADR         => adr_sig,
        WD          => writedata_sig
    );

    -- Instantiating the integrated memory system
    mem_inst: mem port map(
        clk => clk,
        we  => memwrite_sig,
        a   => adr_sig,
        wd  => writedata_sig,
        rd  => readdata_sig
    );

    -- Assigning internal monitor signals to external top-level ports
    adr       <= adr_sig;
    writedata <= writedata_sig;
    memwrite  <= memwrite_sig;

end struct;