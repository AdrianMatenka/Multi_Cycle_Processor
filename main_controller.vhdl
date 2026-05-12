library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_controller is
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
end;

architecture struct of main_controller is
    type statetype is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
    signal state, nextstate: statetype;
begin
    process (CLK, Reset) begin

        if (Reset) then state <= S0;
        elsif rising_edge(CLK) then
            state <= nextstate;
        end if;

    end process;

    process(all)
    begin

        case state is
            -- Fetch
            when S0 =>  nextstate <= S1;
            -- Decode
            when S1 =>  if (Opcode = "100011" or Opcode = "101011") then 
                                nextstate <= S2;        -- LW or SW
                        elsif Opcode = "000000" then 
                                nextstate <= S6;        -- R-type
                        elsif Opcode = "000100" then 
                                nextstate <= S8;        -- BEQ
                        elsif Opcode = "001000" then 
                                nextstate <= S9;        -- ADDI
                        elsif Opcode = "000010" then 
                                nextstate <= S11;        -- J
                        end if;
            -- MemAdr
            when S2 =>  if Opcode = "100011" then 
                                nextstate <= S3;        -- LW
                        else 
                                nextstate <= S5;        -- SW
                        end if;
            -- MemRead
            when S3 =>  nextstate <= S4;
            -- MemWriteback
            when S4 =>  nextstate <= S0;
            -- MemWrite
            when S5 =>  nextstate <= S0;
            -- Execute
            when S6 =>  nextstate <= S7;     
            -- ALU Writeback
            when S7 =>  nextstate <= S0;    
            -- Branch
            when S8 =>  nextstate <= S0;  
            -- ADDI Execute
            when S9 =>  nextstate <= S10;  
            -- ADDI Writeback
            when S10 =>  nextstate <= S0; 
            -- Jump
            when S11 =>  nextstate <= S0; 

            when others => nextstate <= S0;
        end case;

    end process;

    -- Multiplexer Selects
    MemtoReg    <= '1' when state = S4 else '0';    
    RegDst      <= '1' when state = S7 else '0';      
    IorD        <= '1' when (state = S3 or state = S5) else '0';
    PCSrc       <= "10" when state = S11 else "01" when state = S8 else "00";  
    ALUSrcB     <= "01" when state = S0 else "11" when state = S1 else "10" when (state = S2 or state = S9) else "00";  
    ALUSrcA     <= '1' when (state = S2 or state = S6 or state = S8 or state = S9) else '0';

    -- Register Enables
    IRWrite     <= '1' when state = S0 else '0';
    MemWrite    <= '1' when state = S5 else '0';    
    PCWrite     <= '1' when (state = S0 or state = S11) else '0';
    Branch      <= '1' when state = S8 else '0';
    RegWrite    <= '1' when (state = S4 or state = S7 or state = S10) else '0';

    -- ALU Decoder
    ALUOp       <= "10" when state = S6 else "01" when state = S8 else "00";     

end struct;