----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2021 03:16:30 PM
-- Design Name: 
-- Module Name: modulPrincipal - Behavioral
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

entity modulPrincipal is
    port(clk: in std_logic;
        reset: in std_logic;   --buton jos
        sendData: in std_logic;    --buton mijloc
        dataIn: in std_logic_vector (7 downto 0);  --swich-urile
        dataOut: out std_logic_vector (7 downto 0); --led-urile
        rx: in std_logic;
        tx: out std_logic); --tx
end modulPrincipal;

architecture Behavioral of modulPrincipal is

signal enableTx : std_logic;

begin

transmitator: entity WORK.UART port map(
        clk => clk,
        reset => reset,
        txStart => enableTx,
        dataIn => dataIn,
        dataOut => dataOut,
        rx => rx,
        tx => tx);
buton: entity WORK.debounce port map(
        clk => clk,
        rst => reset,
        qIn => sendData,
        qOut => enableTx);

end Behavioral;
