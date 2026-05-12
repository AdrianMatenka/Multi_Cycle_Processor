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
        -- Register Enables
        IRWrite         : out STD_LOGIC;
        MemWrite        : out STD_LOGIC;
        PCWrite         : out STD_LOGIC;
        Branch          : out STD_LOGIC;
        RegWrite        : out STD_LOGIC;
        -- ALU Decoder
        ALUControl      : out STD_LOGIC_VECTOR(2 downto 0)
    );
end;

architecture struct of control_unit is
    component main_controller
        port(
            -- Inputs
            CLK             : in STD_LOGIC;
            Reset           : in STD_LOGIC;
            Opcode          : in STD_LOGIC_VECTOR(5 downto 0);
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
            ALUOp           : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component alu_decoder
        port(
            ALUOp        : in STD_LOGIC_VECTOR(1 downto 0);
            Funct        : in STD_LOGIC_VECTOR(5 downto 0);
            ALUControl   : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    signal aluop_sig : STD_LOGIC_VECTOR(1 downto 0);
begin

    main_controller_inst: main_controller port map(
        CLK      => CLK,
        Reset    => Reset,
        Opcode   => Opcode,
        MemtoReg => MemtoReg,
        RegDst   => RegDst,
        IorD     => IorD,
        PCSrc    => PCSrc,
        ALUSrcB  => ALUSrcB,
        ALUSrcA  => ALUSrcA,
        IRWrite  => IRWrite,
        MemWrite => MemWrite,
        PCWrite  => PCWrite,
        Branch   => Branch,
        RegWrite => RegWrite,
        ALUOp    => aluop_sig
    );

    alu_decoder_inst: alu_decoder port map(
        ALUOp      => aluop_sig,
        Funct      => Funct,
        ALUControl => ALUControl
    );

end struct;