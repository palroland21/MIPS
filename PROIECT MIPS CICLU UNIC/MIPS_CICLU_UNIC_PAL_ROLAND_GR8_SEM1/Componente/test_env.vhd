----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2025 10:30:06 AM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
Port ( clk : in STD_LOGIC;
       btn : in STD_LOGIC_VECTOR (4 downto 0);
       sw  : in STD_LOGIC_VECTOR (15 downto 0);
       led : out STD_LOGIC_VECTOR (15 downto 0);
       an  : out STD_LOGIC_VECTOR (7 downto 0);
       cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG
  Port ( en: out std_logic;
         input: in std_logic;
         clock: in std_logic
         );
end component;

component SSD is
  Port (clk: in std_logic;
        digits: in std_logic_vector(31 downto 0);
        an: out std_logic_vector(7 downto 0);
        cat: out std_logic_vector(6 downto 0) );
end component;

component IFetch is
  Port ( clk: in std_logic;
         rst: in std_logic;
         enable: in std_logic;
         jump_addr: in std_logic_vector(31 downto 0);
         branch_addr: in std_logic_vector(31 downto 0);
         pc_src: in std_logic;
         jump: in std_logic;
         pc: out std_logic_vector(31 downto 0);
         instruction: out std_logic_vector(31 downto 0);
         PC_branch: out std_logic_vector(31 downto 0)
        );
end component;

component IDecode is
  Port ( 
  clk: in STD_LOGIC;
  en: in STD_LOGIC;
  rst: in STD_LOGIC;
  Instr: in STD_LOGIC_VECTOR(25 downto 0);
  WD: in STD_LOGIC_VECTOR(31 downto 0);
  RegWrite: in STD_LOGIC;
  RegDst: in STD_LOGIC;
  ExtOp: in STD_LOGIC;
  RD1: out STD_LOGIC_VECTOR(31 downto 0);
  RD2: out STD_LOGIC_VECTOR(31 downto 0);
  Ext_Imm:  out STD_LOGIC_VECTOR(31 downto 0);
  func: out STD_LOGIC_VECTOR(5 downto 0);
  sa: out STD_LOGIC_VECTOR(4 downto 0)
  );
end component;

component MainControl is
  Port ( opcode: in std_logic_vector(5 downto 0);
         RegDst: out std_logic;
         ExtOp: out std_logic;
         ALUSrc: out std_logic;
         Branch: out std_logic;
         Jump: out std_logic;
         ALUOp: out std_logic_vector(2 downto 0);
         MemWrite: out std_logic;
         MemtoReg: out std_logic;
         RegWrite: out std_logic;
         EnableMem: out std_logic;
         isBGT: out std_logic;
         isBNE: out std_logic
  );
end component;

component ExecutionUnit is
Port(
    PCinc : in std_logic_vector(31 downto 0);
    isBGT: in std_logic;
    isBNE: in std_logic;
    RD1 : in std_logic_vector(31 downto 0);
    RD2 : in std_logic_vector(31 downto 0);
    Ext_Imm :std_logic_vector(31 downto 0);
    func : in std_logic_vector(5 downto 0);
    sa :in std_logic_vector(4 downto 0);
    ALUSrc : in std_logic;
    ALUOp : in std_logic_vector(2 downto 0);
    BranchAddress: out std_logic_vector(31 downto 0);
    ALURes : out std_logic_vector(31 downto 0);
    Zero : out std_logic
);
end component;

component MEM is
    Port(
        clk : in std_logic;
        enable :in std_logic;
        ALURes_in : in std_logic_vector(31 downto 0);
        RD2: in std_logic_vector(31 downto 0);
        MemWrite : in std_logic;
        MemData : out std_logic_vector(31 downto 0);
        ALURes_out : out std_logic_vector(31 downto 0)
    );
end component;

signal Instruction, PCinc, PC_branch, RD1, RD2, WD, Ext_Imm, Ext_func, Ext_sa: STD_LOGIC_VECTOR(31 downto 0);
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData: std_logic_vector(31 downto 0);
signal func: STD_LOGIC_VECTOR(5 downto 0);
signal sa: STD_LOGIC_VECTOR(4 downto 0);
signal digits: STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, zero, PCSrc: STD_LOGIC;

-- main control
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite, EnableMem, isBGT, isBNE: STD_LOGIC;
signal ALUOp: std_logic_vector(2 downto 0);

begin

 -- buttons: reset, enable
 monopulse1: MPG port map(en, btn(0), clk);
 monopulse2: MPG port map(rst, btn(1), clk);
 
 -- main unit
 inst_IF: IFetch port map(clk, rst, en, JumpAddress, BranchAddress, PCSrc, Jump, PCinc, Instruction, PC_branch);
 inst_ID: IDecode port map(clk, en, rst, Instruction(25 downto 0), WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_Imm, func, sa); 
 inst_MC: MainControl port map(Instruction(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite, EnableMem, isBGT, isBNE);
 inst_EX: ExecutionUnit port map(PC_branch, isBGT, isBNE, RD1, RD2, Ext_Imm, func, sa, ALUSrc, ALUOp, BranchAddress, ALURes, zero);
 inst_MEM: MEM port map(clk, EnableMem, ALURes, RD2, MemWrite, MemData, ALURes1);
 
 -- WriteBack unit
 with MemtoReg select
    WD <= MemData when '1',
          ALURes1 when '0',
          ( others => '0') when others;
      
 
 -- Branch control
PCSrc <= Zero and Branch;
 
 -- Jump Address
JumpAddress <= PCinc(31 downto 28) & Instruction(25 downto 0) & "00";
 
 -- SSD display MUX
 with sw(7 downto 5) select
    digits <= Instruction when "000",
              PCinc when "001",
              RD1 when "010",
              RD2 when "011",
              Ext_Imm when "100",
              ALURes when "101",
              MemData when "110",
              WD when "111",
              (others => '0') when others;
              
 display: SSD port map(clk, digits, an, cat);

-- main controls on the leds
led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;
