----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: control_unit - struct
-- Description: Top-level Control Unit for the multi-cycle MIPS processor. 
--              Integrates the main FSM controller and the ALU decoder to 
--              generate all execution and routing control signals.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
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
end;

architecture struct of control_unit is
    -- Component declaration for the main multi-cycle state machine
    component main_controller
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
            ALUOp           : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    -- Component declaration for the ALU internal operational decoder
    component alu_decoder
        port(
            ALUOp        : in STD_LOGIC_VECTOR(2 downto 0);
            Funct        : in STD_LOGIC_VECTOR(5 downto 0);
            ALUControl   : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    -- Internal signal linking the main controller's ALUOp to the ALU decoder
    signal aluop_sig : STD_LOGIC_VECTOR(2 downto 0);
begin

    -- Instance of the main multi-cycle state machine controller
    main_controller_inst: main_controller port map(
        CLK      => CLK,
        Reset    => Reset,
        Opcode   => Opcode,
        Funct    => Funct,
        MemtoReg => MemtoReg,
        RegDst   => RegDst,
        IorD     => IorD,
        PCSrc    => PCSrc,
        ALUSrcB  => ALUSrcB,
        ALUSrcA  => ALUSrcA,
        LoadByte => LoadByte,
        IRWrite  => IRWrite,
        MemWrite => MemWrite,
        PCWrite  => PCWrite,
        Branch   => Branch,
        RegWrite => RegWrite,
        ALUOp    => aluop_sig
    );

    -- Instance of the execution ALU operation decoder
    alu_decoder_inst: alu_decoder port map(
        ALUOp      => aluop_sig,
        Funct      => Funct,
        ALUControl => ALUControl
    );

end struct;