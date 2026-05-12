library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
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
            MUXControl      : in STD_LOGIC;
            MUXResult       : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
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
            MUXControl      : in STD_LOGIC_VECTOR(1 downto 0);
            MUXResult       : out STD_LOGIC_VECTOR(31 downto 0)
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

begin

    PCEn <= (Branch and ZERO) or PCWrite;

    flopenr1: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => PCEn,
        D           => PCnext,
        Q           => PC
    );

    mux2_1: mux2 port map(
        Input1      => PC,
        Input2      => ALUOut,
        MUXControl  => IorD,
        MUXResult   => AdrInternal 
    );

    ADR <= AdrInternal;

    flopenr2: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => IRWrite,
        D           => RD,
        Q           => Instr
    );

    Opcode  <= Instr(31 downto 26);
    Funct   <= Instr(5 downto 0);
    A1      <= Instr(25 downto 21);
    A2      <= Instr(20 downto 16);

    mux2_2: mux2
    generic map(
        WIDTH       => 5
    )
    port map(
        Input1      => Instr(20 downto 16),
        Input2      => Instr(15 downto 11),
        MUXControl  => RegDst,
        MUXResult   => A3 
    );

    flopenr3: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => RD,
        Q           => Data
    );

    mux2_3: mux2 port map(
        Input1      => ALUOut,
        Input2      => Data,
        MUXControl  => MemtoReg,
        MUXResult   => WD3 
    );

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

    flopenr4: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => RD1,
        Q           => A
    );

    flopenr5: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => RD2,
        Q           => B
    );

    WD <= B;

    extension: sign_or_zero_extension port map(
        A           => Instr(15 downto 0),
        SIGNNEXT    => '1',
        Y           => SignImm
    );

    mux2_4: mux2 port map(
        Input1      => PC,
        Input2      => A,
        MUXControl  => ALUSrcA,
        MUXResult   => SrcA 
    );

    mux4_1: mux4 port map(
        Input1      => B,
        Input2      => x"00000004",
        Input3      => SignImm,
        Input4      => (SignImm(29 downto 0) & "00"),
        MUXControl  => ALUSrcB,
        MUXResult   => SrcB
    );

    alu_1: alu port map(
        SrcA => SrcA,
        SrcB => SrcB,
        ALUControl => ALUControl,
        Zero => Zero,
        ALUResult => ALUResult
    );

    flopenr6: flopenr port map(
        CLK         => CLK,
        Reset       => Reset,
        EN          => '1',
        D           => ALUResult,
        Q           => ALUOut
    );

    PCJump <= PC(31 downto 28) & Instr(25 downto 0) & "00";

    mux4_2: mux4 port map(
        Input1      => ALUResult,
        Input2      => ALUOut,
        Input3      => PCJump,
        Input4      => x"00000000",
        MUXControl  => PCSrc,
        MUXResult   => PCnext
    );

end struct;