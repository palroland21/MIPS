----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 03:48:46 PM
-- Design Name: 
-- Module Name: MainControl - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MainControl is
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
end MainControl;

architecture Behavioral of MainControl is

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
