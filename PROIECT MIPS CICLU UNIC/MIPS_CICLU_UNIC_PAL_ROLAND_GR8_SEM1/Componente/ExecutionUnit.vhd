----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2025 10:37:00 AM
-- Design Name: 
-- Module Name: ExecutionUnit - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ExecutionUnit is
Port(
    PCinc : in std_logic_vector(31 downto 0);
    isBGT: in std_logic;
    isBNE: in std_logic;
    RD1 : in std_logic_vector(31 downto 0);
    RD2 : in std_logic_vector(31 downto 0);
    Ext_Imm :std_logic_vector(31 downto 0);
    sa :in std_logic_vector(4 downto 0);
    func : in std_logic_vector(5 downto 0);
    ALUSrc : in std_logic;
    ALUOp : in std_logic_vector(2 downto 0);
    BranchAddress: out std_logic_vector(31 downto 0);
    ALURes : out std_logic_vector(31 downto 0);
    Zero : out std_logic
);
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
signal ALUCtrl : std_logic_vector(2 downto 0);
signal ALUIn2 :std_logic_vector(31 downto 0);
signal Shifted_ExtImm: std_logic_vector(31 downto 0);
signal result: std_logic_vector(31 downto 0);

begin

-- MUX pt intrarea 2 de la ALU
ALUIn2 <= RD2 when ALUSrc = '0' else Ext_Imm;  

-- ALU Control
process(ALUOp,func)
begin
     case ALUOp is
        when "000" =>
            case func is
                when "000000" => ALUCtrl <= "000";
                when "000001" => ALUCtrl <= "001"; 
                when "000011" => ALUCtrl <= "011";
                when "000100" => ALUCtrl <= "100"; 
                when "000101" => ALUCtrl <= "101"; 
                when "000110" => ALUCtrl <= "110"; 
                when "000111" => ALUCtrl <= "111"; 
                when others => ALUCtrl <= (others =>'X');
            end case;
         when "001" => ALUCtrl <= "000"; -- +
         when "010" => ALUCtrl <= "001"; -- -
         when "101" => ALUCtrl <= "100"; -- &
         when "110" => ALUCtrl <= "101"; -- |
         when others => ALUCtrl <= (others =>'X');
         end case;
end process;
       
-- ALU
process(ALUCtrl,RD1,ALUIn2,sa)
begin
  case ALUCtrl is
      when "000" => result <= RD1 + ALUIn2;
      when "001" => result <= RD1 - ALUIn2;
      when "100" => result <= RD1 and ALUIn2;
   -- when "110" => result <= RD1 or ALUIn2;
      when others => result <= X"00000000";
  end case;
end process;
   
Shifted_ExtImm <= Ext_Imm(29 downto 0) & "00";

Zero <= '1' when (result = X"00000000" and isBGT = '0' and isBNE = '0') else   -- BEQ
        '1' when (result(31) = '1' and isBGT = '1' and isBNE = '0') else       -- BGT
        '1' when (result = X"00000001" and isBNE = '1') else '0';              -- BNE 
            
ALURes <= result;

BranchAddress <= PCinc + Shifted_ExtImm;  

 
end Behavioral;
