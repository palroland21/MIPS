----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2025 02:34:18 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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

entity IFetch is
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
end IFetch;

architecture Behavioral of IFetch is

signal MUX1: std_logic_vector(31 downto 0) := (others => '0');
signal PC_p4: std_logic_vector(31 downto 0) := (others => '0');

type tROM is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
signal ROM: tROM := (
    -- INITIALIZARE VALORI
    B"100011_00000_00001_0000000000000000",  -- X"8c01_0000"  --> lw $t1, $zero     -- Incarc un 0 pt a putea face comparatii
    B"100011_00000_00010_0000000000000000",  -- X"8c02_0000"  --> lw $t2, len       -- Lungimea sirului se afla in MEM[0]
    B"100011_00000_00011_0000000000000000",  -- X"8c03_0000"  --> lw $t3, indexSir  -- index de inceput(7)
    B"100011_00000_00100_0000000000000000",  -- X"8c04_0000"  --> lw $t4, 0         -- SumaFinala
    B"100011_00000_00110_0000000000000000",  -- X"8c06_0000"  --> lw $t6, 5         -- pt comparare
    
    -- LOOP_START:
    B"000100_00001_00010_0000000000001100", -- X"1022_000b"  --> beq $t2, $zero, END  -- Comparam: len == 0
    
    -- LOAD sir[i]
    B"100011_00011_00101_0000000000000000",  -- X"8c65_0000"  --> lw $t5, 0($t3)      -- Load la urmatoarea valoare
    
    -- Comparare cu 5
    B"100101_00110_00101_0000000000000100", -- X"94c5_0004"  --> bgt $t5, $t6, check_par
    B"001000_00011_00011_0000000000000001", -- X"2063_0001"  --> addi $t3, $t3, 1         -- sir[next] 
    B"110000_00010_00010_0000000000000001", -- X"c042_0001"  --> subi $t2, $t2, 1         -- decrementez nr de elemente
    B"000010_00000000000000000000000101",   -- X"0800_0005"  --> j LOOP_START             -- reiau procesul
    
    -- check_par
    B"001100_00101_00111_0000000000000001",  -- X"30a7_0001"  --> andi $t7, $t5, 1   ==> $t7 <- $t5 AND 1 (rez = '0' => PAR)
    B"000101_00111_00001_0000000000000010",  -- X"14e0_0002"  --> bne $t7, $t1(zero), skip_add    -- daca nu e par, sar peste adunare
    B"000000_00100_00101_00100_00000_100000", -- X"0085_2020" -->  add $t4, $t4, $t5              -- adunarea
    
   -- -- skip_add:
    B"001000_00011_00011_0000000000000001", -- X"2063_0001"  --> addi $t3, $t3, 1         -- sir[next] 
    B"110000_00010_00010_0000000000000001", -- X"c042_0001"  --> subi $t2, $t2, 1         -- decrementez nr de elemente
    B"000010_00000000000000000000000101",   -- X"0800_0005"  --> j LOOP_START             -- reiau procesul
    
     -- END
    B"101011_00001_00100_0000000000000000", -- X"ac24_0000"  --> sw $t4, 0($t1)           -- salvare in MEM rezultatul final
    
       
    others => (others => '0')
    );
    

begin

process(clk)
begin
   if rising_edge(clk) then
      if rst = '1' then
         PC_p4 <= X"00000000";
      elsif enable = '1' then
         if pc_src = '0' and jump = '0' then
            PC_p4 <= PC_p4 + X"00000004";
         elsif pc_src = '1' and jump = '0' then
            PC_p4 <= branch_addr;
         elsif jump = '1' then
            PC_p4 <= jump_addr;
         end if;
      end if;
   end if;
end process;


Instruction <= ROM(conv_integer(PC_p4(31 downto 2)));

 -- MUX1 <= PC_p4 when pc_src = '0' else branch_addr;
 -- PC_int <= MUX1 when jump = '0' else jump_addr;

pc <= PC_p4;
PC_branch <= PC_p4;

end Behavioral;
