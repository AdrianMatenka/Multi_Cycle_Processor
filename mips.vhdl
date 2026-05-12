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
            -- Register Enables
            IRWrite         : out STD_LOGIC;
            MemWrite        : out STD_LOGIC;
            PCWrite         : out STD_LOGIC;
            Branch          : out STD_LOGIC;
            RegWrite        : out STD_LOGIC;
            -- ALU Decoder
            ALUControl      : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    component datapath
        port(
            -- Inputs
            CLK             : in STD_LOGIC;
            Reset           : in STD_LOGIC;

            -- Signals from Controll Unit
            PCWrite         : in STD_LOGIC;
            IRWrite         : in STD_LOGIC;
            RegWrite        : in STD_LOGIC;
            RegDst          : in STD_LOGIC;
            MemtoReg        : in STD_LOGIC;
            IorD            : in STD_LOGIC;
            ALUSrcA         : in STD_LOGIC;
            Branch          : in STD_LOGIC;
            ALUSrcB         : in STD_LOGIC_VECTOR(1 downto 0);
            PCSrc           : in STD_LOGIC_VECTOR(1 downto 0);
            ALUControl      : in STD_LOGIC_VECTOR(2 downto 0);

            -- Signals from RAM memory
            RD              : in STD_LOGIC_VECTOR(31 downto 0);
            ADR             : out STD_LOGIC_VECTOR(31 downto 0);
            WD              : out STD_LOGIC_VECTOR(31 downto 0);

            -- Back to Controll Unit
            Opcode          : out STD_LOGIC_VECTOR(5 downto 0);
            Funct           : out STD_LOGIC_VECTOR(5 downto 0);
            ZERO            : out STD_LOGIC
        );
    end component;

    -- Internal control signals
    signal MemtoReg        : STD_LOGIC;
    signal RegDst          : STD_LOGIC;
    signal IorD            : STD_LOGIC;
    signal PCSrc           : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUSrcB         : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUSrcA         : STD_LOGIC;
    signal IRWrite         : STD_LOGIC;
    signal PCWrite         : STD_LOGIC;
    signal Branch          : STD_LOGIC;
    signal RegWrite        : STD_LOGIC;
    signal ALUControl      : STD_LOGIC_VECTOR(2 downto 0);
    signal Opcode          : STD_LOGIC_VECTOR(5 downto 0);
    signal Funct           : STD_LOGIC_VECTOR(5 downto 0);
    signal ZERO            : STD_LOGIC;


begin
    -- Instruction Decoder / State Machine
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
        IRWrite     => IRWrite,
        MemWrite    => WE,
        PCWrite     => PCWrite,
        Branch      => Branch,
        RegWrite    => RegWrite,
        ALUControl  => ALUControl
    );

    -- Execution unit
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
        ALUSrcB     => ALUSrcB,
        PCSrc       => PCSrc,
        ALUControl  => ALUControl,
        RD          => RD,
        ADR         => ADR,
        WD          => WD,
        Opcode      => Opcode,
        Funct       => Funct,
        ZERO        => ZERO
    );

end;