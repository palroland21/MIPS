----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: UC - Behavioral
-- Description: 
--      Main Control Unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
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
end UC;

architecture Behavioral of UC is
begin

process(opcode)
begin
   RegDst <= '0';
   ExtOp <= '0';
   ALUSrc <= '0';
   Branch <= '0';
   Jump <= '0';
   ALUOp <= "000";
   MemWrite <= '0';
   MemtoReg <= '0';
   RegWrite <= '0';
   EnableMem <= '0';
   isBGT <= '0';
   isBNE <= '0';
    
   case opcode is
     -- ADD
     when "000000" => ALUOp <= "001"; RegDst <= '1'; RegWrite <= '1';
     -- ADDI
     when "001000" => ALUOp <= "001"; ExtOp <= '1'; ALUSrc <= '1'; RegWrite <= '1';
     -- LW
     when "100011" => ALUOp <= "001"; ExtOp <= '1'; ALUSrc <= '1'; MemtoReg <= '1'; RegWrite <= '1'; EnableMem <= '1';
     -- SW
     when "101011" => ALUOp <= "001"; ExtOp <= '1'; ALUSrc <= '1'; MemWrite <= '1'; EnableMem <= '1';
     -- BEQ
     when "000100" => ALUOp <= "010"; ExtOp <= '1'; Branch <= '1';
     -- BNE
     when "000101" =>  ALUOp <= "010"; ExtOp <= '1'; Branch <= '1'; isBNE <= '1';
     -- ANDI
     when "001100" => ALUOp <= "101"; ALUSrc <= '1'; RegWrite <= '1';
     -- ORI
     when "001101" => ALUOp <= "110"; ALUSrc <= '1'; RegWrite <= '1';
     -- J
     when "000010" => ALUOp <= "000"; Jump <= '1';
     -- SUBI
     when "110000" => ALUOp <= "010"; ExtOp <= '1'; ALUSrc <= '1'; RegWrite <= '1';
     -- BGT
     when "100101" => ALUOp <= "010"; ExtOp <= '1'; Branch <= '1'; isBGT <= '1';
     -- BLEZ
     when "000110" => ALUOp <= "010"; ExtOp <= '1'; Branch <= '1';
     when others => ALUOp <= "000";
    end case;
end process;

end Behavioral;