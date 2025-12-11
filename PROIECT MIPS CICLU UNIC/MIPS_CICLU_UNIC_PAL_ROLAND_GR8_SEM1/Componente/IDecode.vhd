----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 03:08:03 PM
-- Design Name: 
-- Module Name: IDecode - Behavioral
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

entity IDecode is
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
end IDecode;

architecture Behavioral of IDecode is

signal WA: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
signal RA1, RA2: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

type reg_array is array(0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
signal reg_file: reg_array := ( others => X"00000000" );


begin


-- REG FILE
process(clk)
begin
   if rising_edge(clk) then
      if en = '1' then
        if RegWrite = '1' then
            reg_file(conv_integer(WA)) <= WD;
            reg_file(0) <= std_logic_vector(reg_file(0) + 1);
        end if;
      end if;
      if rst = '1' then
         reg_file(0) <=  X"00000000";
      end if;
   end if;
end process;

RD1 <= reg_file(conv_integer(RA1));
RD2 <= reg_file(conv_integer(RA2));

-- Restul codului

RA1 <= Instr(25 downto 21);
RA2 <= Instr(20 downto 16);

WA <= RA2 when RegDst = '0' else Instr(15 downto 11);

process(clk)
begin
  if ExtOp = '1' then
   if Instr(15) = '1' then
     Ext_Imm <= x"1111" & Instr(15 downto 0);
   else
     Ext_Imm <= x"0000" & Instr(15 downto 0);
   end if;
  else
   Ext_Imm <= x"0000" & Instr(15 downto 0);
  end if;
end process;

func <= Instr(5 downto 0);
sa <= Instr(10 downto 6);

end Behavioral;
