----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2025 10:59:57 AM
-- Design Name: 
-- Module Name: MEM - Behavioral
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

entity MEM is
    Port(
        clk : in std_logic;
        enable :in std_logic;
        ALURes_in : in std_logic_vector(31 downto 0);
        RD2: in std_logic_vector(31 downto 0);
        MemWrite : in std_logic;
        MemData : out std_logic_vector(31 downto 0);
        ALURes_out : out std_logic_vector(31 downto 0)
    );
end MEM;

architecture Behavioral of MEM is
type ram_type is array(0 to 63) of std_logic_vector(31 downto 0);
signal RAM : ram_type := (
    X"00000000", -- $zero ( Aici va fi salvat rezultatul)
    X"00000006", -- nr de elemente
    X"00000007", -- $t3
    X"00000000", -- $t4
    X"00000005", -- $t6
    X"00000000", -- $t5
    X"00000000", -- $t7
    X"00000001", -- inceput de sir
    X"00000007",
    X"00000006",
    X"00000005",
    X"00000002",
    X"00000008",
    others => X"00000000");
    
begin

process(clk)
begin
  if rising_edge(clk) then 
      if enable = '1' then
        if MemWrite='1' then 
           RAM(conv_integer(ALURes_in))<= RD2;
           MemData <= RD2;
         else
           MemData <= RAM(conv_integer(ALURes_in));
         end if; 
      end if;
  end if;
end process;
       
ALURes_out <= ALURes_in;    
 
end Behavioral;

