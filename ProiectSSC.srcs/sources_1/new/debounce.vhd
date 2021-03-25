----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/31/2020 10:41:27 PM
-- Design Name: 
-- Module Name: debounce - Behavioral
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

entity debounce is
    port (clk : in std_logic;
        rst : in std_logic;
        qIn : in std_logic;
        qOut : out std_logic);
end debounce;

architecture Behavioral of debounce is
signal Q1, Q2, Q3 : std_logic;

begin

process(Clk)
begin
   if clk'event and clk = '1' then
      if (rst = '1') then
         Q1 <= '0';
         Q2 <= '0';
         Q3 <= '0';
      else
         Q1 <= qIn;
         Q2 <= Q1;
         Q3 <= Q2;
      end if;
   end if;
end process;

qOut <= Q1 and Q2 and (not Q3);

end Behavioral;
