----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: EX - Behavioral
-- Description: Execute Unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

entity EX is
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
end EX;

architecture Behavioral of EX is

signal ALUCtrl : std_logic_vector(2 downto 0);
signal ALUIn2 :std_logic_vector(31 downto 0);
signal Shifted_ExtImm: std_logic_vector(31 downto 0);
signal result: std_logic_vector(31 downto 0);

begin

-- MUX pt intrarea 2 de la ALU
ALUIn2 <= RD2 when ALUSrc = '0' else Ext_Imm;  
rWA <= rd when RegDst = '1' else rt;

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

BranchAddress <= PCp4 + Shifted_ExtImm;  

 
end Behavioral;
