----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2021 06:04:00 PM
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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

entity uartRx is
    generic(rate: integer := 115_200); --debitul binar(115 200 biti pe sec)
    port(clk: in std_logic;
        reset: in std_logic;
        rxIn: in std_logic;
        rxData: out std_logic_vector (7 downto 0));
end uartRx;

architecture Behavioral of uartRx is

constant clk_freq: INTEGER:=100_000_000;
constant tBit: INTEGER:=(clk_freq/rate)/16;-- durata unui singur bit
--impart la 16 pentru o viteza cat mai mare
type state is (idle, start, send, stop);
signal st: state;

signal localClk: std_logic:= '0'; --pentru esantionarea corecta a bitilor unui caracter
signal data: std_logic_vector(7 downto 0) := (others=>'0');

begin

localClkGenerator: process(clk)
    variable count: integer:= (tBit - 1);
    begin
        if clk'event and clk='1' then
            if reset = '1' then
                localClk <= '0';
                count := (tBit - 1);
            else
                if count = 0 then
                    localClk <= '1';
                    count := (tBit - 1);
                else
                    localClk <= '0';
                    count := count - 1;
                end if;
            end if;
        end if;
end process;


control: process(clk)
    variable durationCount: integer := 0;
    variable dataIndex: integer:= 0;
    begin
        if clk'event and clk='1' then
            if (reset = '1') then
                st <= idle;
                data <= (others => '0');
                rxData <= (others => '0');
                durationCount := 0;
                dataIndex := 0;
            else
                if (localClk = '1') then     -- frecventa e de 16 ori mai rapida(am impartit la 16 tBit-ul)
                    case st is
                        when idle =>
                            data <= (others => '0');    -- curat "registrul" in care se incarca datele primite
                            durationCount := 0;              -- resetez numararea bitilor
                            dataIndex := 0;
                            if (rxIn = '0') then             -- daca primesc bitul de start('0') incep numararea bitilor
                                st <= start;
                            end if;
                        when start =>
                            if (rxIn = '0') then             -- verific daca exista bitul de start
                                if (durationCount = 7) then   -- astept pana la jumatatea unui ciclu de ceas(adica localClk)
                                    st <= send;
                                    durationCount := 0;
                                else
                                    durationCount := durationCount + 1;
                                end if;
                            else
                                st <= idle;                  -- bitul de start nu e prezent, merg in starea de start
                            end if;
                        when send =>
                            if (durationCount = 15) then  --astept pana la un singur ciclu de ceas(lui localClk)
                                data(dataIndex) <= rxIn;     -- completez in "registrul" in care se primesc datele, bitul primit
                                durationCount := 0;
                                if (dataIndex = 7) then     -- cand s-au completat "registrul cu toti cei 8 biti, merg in starea de stop
                                    st <= stop;
                                    durationCount := 0;
                                else
                                    dataIndex := dataIndex + 1;
                                end if;
                            else
                                durationCount := durationCount + 1;
                            end if;

                        when stop =>
                            if (durationCount = 15) then      -- astept pana la terminarea unui ciclu de ceas(localClk)
                                rxData <= data;     -- afisez datele primite
                                st <= idle;
                            else
                                durationCount := durationCount + 1;
                            end if;
                        when others =>
                            st <= idle;
                    end case;
                end if;
            end if;
        end if;
end process ;
  
end Behavioral;
