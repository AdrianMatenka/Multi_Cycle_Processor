----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: mips - struct
-- Description: Core processor module integrating the Control Unit and the Datapath.
--              It exposes the external system memory interface (RAM) to the 
--              outside world, connecting signals like address, read/write data,
--              and memory write enable.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mips is
    port(
        CLK, Reset  : in  STD_LOGIC;
        -- External memory interface
        RD          : in  STD_LOGIC_VECTOR(31 downto 0);
        WE          : out STD_LOGIC;
        ADR         : out STD_LOGIC_VECTOR(31 downto 0);
        WD          : out STD_LOGIC_VECTOR(31 downto 0)
    );
end;

architecture struct of mips is
    -- Component declaration for the instruction decoder and FSM coordinator
    component control_unit
        port(
            -- Inputs
            CLK             : in STD_LOGIC;
            Reset           : in STD_LOGIC;
            Opcode          : in STD_LOGIC_VECTOR(5 downto 0);
            Funct           : in STD_LOGIC_VECTOR(5 downto 0);
            -- Multiplexer Selects
            MemtoReg        : out STD_LOGIC;
            RegDst          : out STD_LOGIC;
            IorD            : out STD_LOGIC;
            PCSrc           : out STD_LOGIC_VECTOR(1 downto 0);
            ALUSrcB         : out STD_LOGIC_VECTOR(1 downto 0);
            ALUSrcA         : out STD_LOGIC;
            LoadByte        : out STD_LOGIC;
            -- Register Enables
            IRWrite         : out STD_LOGIC;
            MemWrite        : out STD_LOGIC;
            PCWrite         : out STD_LOGIC;
            Branch          : out STD_LOGIC_VECTOR(1 downto 0);
            RegWrite        : out STD_LOGIC;
            -- ALU Decoder
            ALUControl      : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    -- Component declaration for the execution datapath elements
    component datapath
        port(
            -- Inputs
            CLK             : in STD_LOGIC;
            Reset           : in STD_LOGIC;

            -- Signals from Control Unit
            PCWrite         : in STD_LOGIC;
            IRWrite         : in STD_LOGIC;
            RegWrite        : in STD_LOGIC;
            RegDst          : in STD_LOGIC;
            MemtoReg        : in STD_LOGIC;
            IorD            : in STD_LOGIC;
            ALUSrcA         : in STD_LOGIC;
            Branch          : in STD_LOGIC_VECTOR(1 downto 0);
            LoadByte        : in STD_LOGIC;
            ALUSrcB         : in STD_LOGIC_VECTOR(1 downto 0);
            PCSrc           : in STD_LOGIC_VECTOR(1 downto 0);
            ALUControl      : in STD_LOGIC_VECTOR(2 downto 0);

            -- Signals from RAM memory
            RD              : in STD_LOGIC_VECTOR(31 downto 0);
            ADR             : out STD_LOGIC_VECTOR(31 downto 0);
            WD              : out STD_LOGIC_VECTOR(31 downto 0);

            -- Back to Control Unit
            Opcode          : out STD_LOGIC_VECTOR(5 downto 0);
            Funct           : out STD_LOGIC_VECTOR(5 downto 0);
            ZERO            : out STD_LOGIC
        );
    end component;

    -- Internal control buses and status flags linking Control Unit and Datapath
    signal MemtoReg        : STD_LOGIC;
    signal RegDst          : STD_LOGIC;
    signal IorD            : STD_LOGIC;
    signal PCSrc           : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUSrcB         : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUSrcA         : STD_LOGIC;
    signal IRWrite         : STD_LOGIC;
    signal PCWrite         : STD_LOGIC;
    signal Branch          : STD_LOGIC_VECTOR(1 downto 0);
    signal RegWrite        : STD_LOGIC;
    signal ALUControl      : STD_LOGIC_VECTOR(2 downto 0);
    signal Opcode          : STD_LOGIC_VECTOR(5 downto 0);
    signal Funct           : STD_LOGIC_VECTOR(5 downto 0);
    signal ZERO            : STD_LOGIC;
    signal LoadByte        : STD_LOGIC; 

begin

    -- Instantiating the Control Unit (Instruction Decoder / State Machine)
    control_unit1: control_unit
     port map(
        CLK         => CLK,
        Reset       => Reset,
        Opcode      => Opcode,
        Funct       => Funct,
        MemtoReg    => MemtoReg,
        RegDst      => RegDst,
        IorD        => IorD,
        PCSrc       => PCSrc,
        ALUSrcB     => ALUSrcB,
        ALUSrcA     => ALUSrcA,
        LoadByte    => LoadByte,
        IRWrite     => IRWrite,
        MemWrite    => WE, -- Directly driving the external memory write enable port
        PCWrite     => PCWrite,
        Branch      => Branch,
        RegWrite    => RegWrite,
        ALUControl  => ALUControl
    );

    -- Instantiating the execution core (Datapath)
    datapath_inst1: datapath
     port map(
        CLK         => CLK,
        Reset       => Reset,
        PCWrite     => PCWrite,
        IRWrite     => IRWrite,
        RegWrite    => RegWrite,
        RegDst      => RegDst,
        MemtoReg    => MemtoReg,
        IorD        => IorD,
        ALUSrcA     => ALUSrcA,
        Branch      => Branch,
        LoadByte    => LoadByte,
        ALUSrcB     => ALUSrcB,
        PCSrc       => PCSrc,
        ALUControl  => ALUControl,
        RD          => RD,  -- External RAM data input
        ADR         => ADR, -- External RAM target address output
        WD          => WD,  -- External RAM write data output
        Opcode      => Opcode,
        Funct       => Funct,
        ZERO        => ZERO
    );

end struct;