----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: test_env - Behavioral
-- Description: MIPS 32, Pipeline
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component ID is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           rd_MEM_WB: in STD_LOGIC_VECTOR(4 downto 0);
           RegWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0);
           rt : out STD_LOGIC_VECTOR(4 downto 0);
           rd : out STD_LOGIC_VECTOR(4 downto 0));
end component;

component UC is
    Port ( opcode : in STD_LOGIC_VECTOR(5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           EnableMem: out STD_LOGIC;
           isBGT: out STD_LOGIC;
           isBNE: out STD_LOGIC);
end component;

component EX is
     Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           rt : in STD_LOGIC_VECTOR(4 downto 0);
           rd : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           RegDst : in STD_LOGIC;
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC;
           rWA : out STD_LOGIC_VECTOR(4 downto 0);
           EnableMem: in STD_LOGIC;
           isBGT: in STD_LOGIC;
           isBNE: in STD_LOGIC);
end component;

component MEM is
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal rt, rd, rWa : STD_LOGIC_VECTOR(4 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 

signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

signal PCinc_IF_ID, Instruction_IF_ID: std_logic_vector(31 downto 0);
signal PCInc_ID_EX, RD1_ID_EX, RD2_ID_EX, Ext_imm_ID_EX: std_logic_vector(31 downto 0);
signal func_ID_EX : std_logic_vector(5 downto 0);
signal rt_ID_EX, rd_ID_EX : std_logic_vector(4 downto 0);
signal ALUOp_ID_EX: STD_LOGIC_VECTOR(2 downto 0);
signal sa_ID_EX: std_logic_vector(4 downto 0);
signal MemtoReg_ID_EX, RegWrite_ID_EX, MemWrite_ID_EX, Branch_ID_EX, ALUSrc_ID_EX, RegDst_ID_EX : std_logic;
signal BranchAddress_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM : std_logic_vector(31 downto 0);
signal rd_EX_MEM : std_logic_vector(4 downto 0);
signal zero_EX_MEM, MemtoReg_EX_MEM, RegWrite_EX_MEM, MemWrite_EX_MEM, Branch_EX_MEM : std_logic;
signal MemData_MEM_WB, ALURes_MEM_WB : std_logic_vector(31 downto 0);
signal rd_MEM_WB : std_logic_vector(4 downto 0);
signal MemtoReg_MEM_WB, RegWrite_MEM_WB : std_logic;
signal EnableMem, isBGT, isBNE: std_logic;
signal EnableMem_ID_EX, isBGT_ID_EX, isBNE_ID_EX: std_logic;
signal Enable_EX_MEM: std_logic;

begin

    monopulse : MPG port map(en, btn(0), clk);
    
    inst_IFetch : IFetch port map(clk, btn(1), en, BranchAddress_EX_MEM, JumpAddress, Jump, PCSrc, Instruction, PCp4);
    inst_ID : ID port map(clk, en, Instruction_IF_ID(25 downto 0), WD, rd_MEM_WB, RegWrite_MEM_WB, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa, rt, rd);
    inst_UC : UC port map(Instruction_IF_ID(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite, EnableMem, isBGT, isBNE);
    inst_EX : EX port map(PCinc_ID_EX, RD1_ID_EX, RD2_ID_EX, Ext_imm_ID_EX, func_ID_EX, sa_ID_EX, rt_ID_EX, rd_ID_EX,
                         ALUSrc_ID_EX, ALUOp_ID_EX, RegDst_ID_EX, BranchAddress, ALURes, Zero, rWA,
                          EnableMem_ID_EX, isBGT_ID_EX, isBNE_ID_EX);
    inst_MEM : MEM port map(clk, Enable_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM, MemWrite_EX_MEM, MemData, ALURes1);

    with MemtoReg_MEM_WB select
        WD <= MemData_MEM_WB when '1',
              ALURes_MEM_WB when '0',
              (others => 'X') when others;

    PCSrc <= Zero_EX_MEM and Branch_EX_MEM;
    JumpAddress <= PCinc_IF_ID(31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";

    process(clk)
    begin
        if rising_edge(clk) then  
            if en='1' then
                -- IF_ID
                PCinc_IF_ID <= PCp4;
                Instruction_IF_ID <= Instruction;
                
                -- ID_EX
                PCInc_ID_EX <= PCInc_IF_ID;
                RD1_ID_EX <= RD1;
                RD2_ID_EX <= RD2;
                Ext_imm_ID_EX <= Ext_imm;
                sa_ID_EX <= sa;
                func_ID_EX <= func;
                rt_ID_EX <= rt;
                rd_ID_EX <= rd;
                MemtoReg_ID_EX <= MemtoReg;
                RegWrite_ID_EX <= RegWrite;
                MemWrite_ID_EX <= MemWrite;
                
                EnableMem_ID_EX <= EnableMem;
                isBGT_ID_EX <= isBGT;
                isBNE_ID_EX <= isBNE;
                
                Branch_ID_EX <= Branch;
                ALUSrc_ID_EX <= ALUSrc;
                ALUOp_ID_EX <= ALUOp;
                RegDst_ID_EX <= RegDst;
                
                -- EX_MEM
                Enable_EX_MEM <= EnableMem_ID_EX;
                BranchAddress_EX_MEM <= BranchAddress;
                Zero_EX_MEM <= Zero;
                ALURes_EX_MEM <= ALURes;
                RD2_EX_MEM <= RD2_ID_EX;
                rd_EX_MEM <= rWa;
                MemtoReg_EX_MEM <= MemtoReg_ID_EX;
                RegWrite_EX_MEM <= RegWrite_ID_EX;
                MemWrite_EX_MEM <= MemWrite_ID_EX;
                Branch_EX_MEM <= Branch_ID_EX;
                
                -- MEM_WB
                MemData_MEM_WB <= MemData;
                ALURes_MEM_WB <= ALURes1;
                rd_MEM_WB <= rd_EX_MEM;
                MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
                RegWrite_MEM_WB <= RegWrite_EX_MEM;
            end if;
        end if;
    end process;
    
    with sw(7 downto 5) select
        digits <= Instruction when "000", 
                 PCp4 when "001",
                 RD1_ID_EX when "010",
                 RD2_ID_EX when "011",
                 Ext_Imm_ID_EX when "100",
                 ALURes when "101",
                 MemData when "110",
                 WD when "111",
                 (others => 'X') when others; 

    display : SSD port map(clk, digits, an, cat);
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;