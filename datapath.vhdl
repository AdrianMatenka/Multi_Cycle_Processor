----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: datapath - struct
-- Description: The main Datapath unit of the MIPS multi-cycle processor.
--              It interconnects the registers, ALU, multiplexers, and 
--              extension blocks to execute instructions by routing data 
--              correctly based on control signals.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
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
end;

architecture struct of datapath is
    component flopenr
        port(
            CLK, reset          : in STD_LOGIC;
            EN                  : in STD_LOGIC;
            D                   : in STD_LOGIC_VECTOR(31 downto 0);
            Q                   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component mux2
        generic (WIDTH : INTEGER := 32);
        port(
            Input1          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
            Input2          : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
            MuxControl      : in STD_LOGIC;
            MuxResult       : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
        );
    end component;

    component register_file
        port(
            CLK                 : in STD_LOGIC;
            WE3                 : in STD_LOGIC;
            A1, A2, A3          : in STD_LOGIC_VECTOR(4 downto 0);
            WD3                 : in STD_LOGIC_VECTOR(31 downto 0);
            RD1, RD2            : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component sign_or_zero_extension
        port(
            A                   : in STD_LOGIC_VECTOR(15 downto 0);
            SIGNNEXT            : in STD_LOGIC;
            Y                   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component mux4
        port(
            Input1          : in STD_LOGIC_VECTOR(31 downto 0);
            Input2          : in STD_LOGIC_VECTOR(31 downto 0);
            Input3          : in STD_LOGIC_VECTOR(31 downto 0);
            Input4          : in STD_LOGIC_VECTOR(31 downto 0);
            MuxControl      : in STD_LOGIC_VECTOR(1 downto 0);
            MuxResult       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component alu
        port(
            SrcA        : in STD_LOGIC_VECTOR(31 downto 0);
            SrcB        : in STD_LOGIC_VECTOR(31 downto 0);
            ALUControl  : in STD_LOGIC_VECTOR(2 downto 0);
            Zero        : out STD_LOGIC;
            ALUResult   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component byte_select
        port (
            Input           : in STD_LOGIC_VECTOR(31 downto 0);
            ByteSelect      : in STD_LOGIC_VECTOR(1 downto 0);
            ByteSelected    : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Internal signal declarations for datapath routing
    signal PCnext       : STD_LOGIC_VECTOR(31 downto 0);
    signal PCEn         : STD_LOGIC;
    signal PC           : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUOut       : STD_LOGIC_VECTOR(31 downto 0);
    signal A, B         : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr        : STD_LOGIC_VECTOR(31 downto 0);
    signal Data         : STD_LOGIC_VECTOR(31 downto 0);
    signal A1, A2, A3   : STD_LOGIC_VECTOR(4 downto 0);
    signal WD3          : STD_LOGIC_VECTOR(31 downto 0);
    signal RD1          : STD_LOGIC_VECTOR(31 downto 0);
    signal RD2          : STD_LOGIC_VECTOR(31 downto 0);
    signal SignImm      : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcA         : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcB         : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult    : STD_LOGIC_VECTOR(31 downto 0);
    signal PCJump       : STD_LOGIC_VECTOR(31 downto 0);
    signal AdrInternal  : STD_LOGIC_VECTOR(31 downto 0);
    signal ByteSelected : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData    : STD_LOGIC_VECTOR(31 downto 0);
    signal TakeBranch   : STD_LOGIC;

begin

    -- Branch condition evaluation: Branch(0) handles BEQ (Zero), Branch(1) handles BNE (not Zero)
    TakeBranch <= (Branch(0) and ZERO) or (Branch(1) and not ZERO);

    -- Master PC Write Enable signal combining unconditional writes and valid branch conditions
    PCEn <= PCWrite or TakeBranch;

    -- Program Counter Register
    flopenr1: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => PCEn,
        D           => PCnext,
        Q           => PC
    );

    -- Memory Address Multiplexer: selects between Program Counter (Instruction Fetch) and ALUOut (Data Access)
    mux2_1: mux2 port map(
        Input1      => PC,
        Input2      => ALUOut,
        MuxControl  => IorD,
        MuxResult   => AdrInternal 
    );

    ADR <= AdrInternal;

    -- Instruction Register (IR) with write enable control
    flopenr2: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => IRWrite,
        D           => RD,
        Q           => Instr
    );

    -- Slicing MIPS Instruction fields
    Opcode  <= Instr(31 downto 26);
    Funct   <= Instr(5 downto 0);
    A1      <= Instr(25 downto 21); -- rs field
    A2      <= Instr(20 downto 16); -- rt field

    -- Register Destination MUX: chooses between rt field (I-type) and rd field (R-type)
    mux2_2: mux2
    generic map(
        WIDTH       => 5
    )
    port map(
        Input1      => Instr(20 downto 16),
        Input2      => Instr(15 downto 11),
        MuxControl  => RegDst,
        MuxResult   => A3 
    );

    -- Data Register (DR) storing raw content read from memory
    flopenr3: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => RD,
        Q           => Data
    );

    -- Byte Selection Sub-module to extract a specific byte for partial load operations
    byteselect1: byte_select port map(
        Input           => Data,
        ByteSelect      => Instr(1 downto 0),
        ByteSelected    => ByteSelected
    );

    -- MUX to select between full 32-bit Word Data and extracted Byte Data
    mux2_5: mux2 port map(
        Input1      => Data,
        Input2      => ByteSelected,
        MuxControl  => LoadByte,
        MuxResult   => WriteData
    ); 

    -- Write Back Data MUX: selects between ALU execution output and loaded Memory Data
    mux2_3: mux2 port map(
        Input1      => ALUOut,
        Input2      => WriteData,
        MuxControl  => MemtoReg,
        MuxResult   => WD3 
    );

    -- MIPS Central Register File
    register_1: register_file port map(
        CLK     => CLK,
        WE3     => RegWrite,
        A1      => A1,
        A2      => A2,
        A3      => A3,
        WD3     => WD3,
        RD1     => RD1,
        RD2     => RD2
    );

    -- Pipeline/Multi-cycle intermediate Register A (Read Data 1 buffer)
    flopenr4: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => RD1,
        Q           => A
    );

    -- Pipeline/Multi-cycle intermediate Register B (Read Data 2 buffer)
    flopenr5: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => RD2,
        Q           => B
    );

    WD <= B;

    -- Sign Extension unit for 16-bit constants found in immediate instructions
    extension: sign_or_zero_extension port map(
        A           => Instr(15 downto 0),
        SIGNNEXT    => '1',
        Y           => SignImm
    );

    -- ALU Source A MUX: routes either the PC value or Register Buffer A to the ALU
    mux2_4: mux2 port map(
        Input1      => PC,
        Input2      => A,
        MuxControl  => ALUSrcA,
        MuxResult   => SrcA 
    );

    -- ALU Source B MUX: selects between Register B, Constant 4 (PC increment), SignImm, or shifted SignImm
    mux4_1: mux4 port map(
        Input1      => B,
        Input2      => x"00000004",
        Input3      => SignImm,
        Input4      => (SignImm(29 downto 0) & "00"),
        MuxControl  => ALUSrcB,
        MuxResult   => SrcB
    );

    -- Execution Core (ALU)
    alu_1: alu port map(
        SrcA => SrcA,
        SrcB => SrcB,
        ALUControl => ALUControl,
        Zero => Zero,
        ALUResult => ALUResult
    );

    -- ALU Output Register to buffer computation results across clock cycles
    flopenr6: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => ALUResult,
        Q           => ALUOut
    );

    -- Calculation of target absolute jump address (combines PC upper bits and shifted instruction immediate)
    PCJump <= PC(31 downto 28) & Instr(25 downto 0) & "00";

    -- PC Next Source MUX: Selects target source for the next PC state
    mux4_2: mux4 port map(
        Input1      => ALUResult,
        Input2      => ALUOut,
        Input3      => PCJump,
        Input4      => A,
        MuxControl  => PCSrc,
        MuxResult   => PCnext
    );

end struct;