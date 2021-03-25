----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2021 03:07:29 PM
-- Design Name: 
-- Module Name: UART - Behavioral
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

entity UART is
    port(clk: in std_logic;
        reset: in std_logic;
        txStart: in std_logic;
        dataIn: in std_logic_vector (7 downto 0);
        dataOut: out std_logic_vector (7 downto 0);
        rx: in std_logic;
        tx: out std_logic);
end UART;

architecture Behavioral of UART is

begin

transmitator: entity WORK.uartTx port map(
        clk => clk,
        reset => reset,
        txStart => txStart,
        txData => dataIn,
        txOut => tx);
        
receptor: entity WORK.uartRx port map(
        clk => clk,
        reset => reset,
        rxIn => rx,
        rxData => dataOut);

end Behavioral;
