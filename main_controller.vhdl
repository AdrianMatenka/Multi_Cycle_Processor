----------------------------------------------------------------------------------
-- Author: Adrian Mateńka
-- Date: 16.05.2026
-- Project Name: MIPS Multi-Cycle Processor
-- Module Name: main_controller - struct
-- Description: Main Finite State Machine (FSM) Controller for the multi-cycle 
--              MIPS processor. It decodes the instruction Opcode/Funct fields 
--              and coordinates control signals across multiple execution steps.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_controller is
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
end;

architecture struct of main_controller is
    -- Enumerated type specifying all FSM states for the multi-cycle execution
    type statetype is ( S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11,
                        S12, S13, S14, S15, S16, S17, S18, S19);
    signal state, nextstate: statetype;
begin
    -- Sequential process for FSM state transitions
    process (CLK, Reset) begin

        if (Reset) then state <= S0;
        elsif rising_edge(CLK) then
            state <= nextstate;
        end if;

    end process;

    -- Combinational process defining next state logic based on Opcode and Funct
    process(all)
    begin

        case state is
            -- Fetch Step
            when S0 =>  nextstate <= S1;
            -- Decode Step
            when S1 =>  if (Opcode = "100011" or Opcode = "101011" or Opcode = "100100") then 
                                nextstate <= S2;        -- LW or SW or LBU
                        elsif Opcode = "000000" then
                            if Funct = "001000" then
                                nextstate <= S16;       -- JR (Jump Register)
                            else
                                nextstate <= S6;        -- R-type
                            end if;
                        elsif Opcode = "000100" then 
                                nextstate <= S8;        -- BEQ
                        elsif Opcode = "001000" then 
                                nextstate <= S9;        -- ADDI
                        elsif Opcode = "000010" then 
                                nextstate <= S11;       -- J (Jump)
                        elsif Opcode = "001101" then    
                                nextstate <= S12;       -- ORI
                        elsif Opcode = "001110" then
                                nextstate <= S14;       -- XORI
                        elsif Opcode = "000101" then
                                nextstate <= S19;       -- BNE
                        end if;
            -- Memory Address Computation Step
            when S2 =>  if Opcode = "100011" then 
                                nextstate <= S3;        -- LW execution flow
                        elsif Opcode = "101011" then 
                                nextstate <= S5;        -- SW execution flow
                        else
                                nextstate <= S17;       -- LBU execution flow
                        end if;
            -- Memory Read Step (LW)
            when S3 =>      nextstate <= S4;
            -- Memory Writeback Step (LW)
            when S4 =>      nextstate <= S0;
            -- Memory Write Step (SW)
            when S5 =>      nextstate <= S0;
            -- Execute Step (R-Type)
            when S6 =>      nextstate <= S7;     
            -- ALU Writeback Step (R-Type)
            when S7 =>      nextstate <= S0;    
            -- Branch Step (BEQ)
            when S8 =>      nextstate <= S0;  
            -- ADDI Execute Step
            when S9 =>      nextstate <= S10;  
            -- ADDI Writeback Step
            when S10 =>     nextstate <= S0; 
            -- Jump Step (J)
            when S11 =>     nextstate <= S0; 
            -- Ori Execute Step
            when S12 =>     nextstate <= S13;
            -- Ori Writeback Step
            when S13 =>     nextstate <= S0;
            -- Xori Execute Step
            when S14 =>     nextstate <= S15;
            -- Xori Writeback Step
            when S15 =>     nextstate <= S0;
            -- Jump Register Execute Step (JR)
            when S16 =>     nextstate <= S0;
            -- LBU Memory Read Byte Step
            when S17 =>     nextstate <= S18;
            -- LBU Memory Writeback Byte Step
            when S18 =>     nextstate <= S0;
            -- BNE Execute Step
            when S19 =>     nextstate <= S0;

            when others =>  nextstate <= S0;
        end case;

    end process;

    -- Multiplexer Select Output Logic
    MemtoReg    <= '1' when (state = S4 or state = S18) else '0';    
    RegDst      <= '1' when state = S7 else '0';      
    IorD        <= '1' when (state = S3 or state = S5 or state = S17) else '0';
    PCSrc       <= "11" when state = S16 else "10" when state = S11 
                    else "01" when (state = S8 or state = S19) else "00";  
    ALUSrcB     <= "01" when state = S0 else "11" when state = S1 else "10" 
                    when (state = S2 or state = S9 or state = S12 or state = S14) 
                    else "00";  
    ALUSrcA     <= '1' when (state = S2 or state = S6 or state = S8 or state = S9 
                    or state = S12 or state = S14 or state = S19) else '0';
    LoadByte    <= '1' when state = S18 else '0';

    -- Register Enable Output Logic
    IRWrite     <= '1' when state = S0 else '0';
    MemWrite    <= '1' when state = S5 else '0';    
    PCWrite     <= '1' when (state = S0 or state = S11 or state = S16) else '0';
    Branch      <= "10" when state = S19 else "01" when state = S8 else "00";
    RegWrite    <= '1' when (state = S4 or state = S7 or state = S10 
                    or state = S13 or state = S15 or state = S18) else '0';

    -- ALU Decoder Operation Code Selection
    ALUOp       <= "100" when state = S14 else "011" when state = S12 
                    else "010" when state = S6 else "001" when 
                    (state = S8 or state = S19) else "000";     

end struct;