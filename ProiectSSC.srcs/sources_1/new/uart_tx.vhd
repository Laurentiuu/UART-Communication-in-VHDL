----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/31/2020 06:17:57 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

entity uartTx is
    generic(rate: integer := 115_200); --debitul binar(115 200 biti pe sec)
    port(clk: in std_logic;
        reset: in std_logic;
        txStart: in std_logic;
        txData: in std_logic_vector (7 downto 0);
        txOut: out std_logic
        );
end uartTx;

architecture Behavioral of uartTx is

constant clk_freq: INTEGER:=100_000_000;
constant tBit: INTEGER:=clk_freq/rate;-- durata unui singur bit

type state is (idle, start, send, stop);
signal st: state;

signal localClk: std_logic:= '0'; --pentru esantionarea corecta a bitilor unui caracter

signal startDetected: std_logic := '0';
signal startReset: std_logic := '0';

signal dataIndex: integer:= 0;
signal dataIndexReset: std_logic := '1';

signal data: std_logic_vector(7 downto 0) := (others=>'0');

begin

--proces care genereaza o frecventa locala, care permite masurarea intervalului
--de timp corespunzator unui bit
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

 --registru care memoreaza datele si le transmite atunci cand butonul e apasat
sendData: process(clk)
    begin
        if clk'event and clk='1' then
            if reset ='1' or startReset = '1' then
                startDetected <= '0';
            else    --incep numararea
                if txStart = '1' and startDetected = '0' then
                    startDetected <= '1';
                    data <= txData;
                end if;
            end if;
        end if;
end process;

--procesul care numara bitii
indexCounter: process(clk)
    begin
        if clk'event and clk='1' then
            if reset = '1' or dataIndexReset = '1' then
                dataIndex <= 0;
            elsif localClk = '1' then
                dataIndex <= dataIndex + 1;
            end if;
        end if;
end process;


control: process(clk)
    begin
        if clk'event and clk='1' then
            if reset = '1' then
                st <= idle;
                dataIndexReset <= '1';
                startReset <= '1';
                txOut <= '1';
            elsif localClk = '1' then   --controlul se face pe clk-ul local
                case st is
                    when idle =>
                        dataIndexReset <= '1';
                        startReset <= '0';
                        txOut <= '1';
                            if startDetected = '1' then
                                st <= start;
                            end if;
                    when start =>
                        dataIndexReset <= '0';   -- activez numararea bitilor
                        txOut <= '0';        --trimit '0' ca si bit de start(primul bit)
                        st <= send;
                    when send =>
                        txOut <= data(dataIndex);   -- trimit cate un bit de 8 ori la frecventa locala
                                                    --(adica bitii de la 1 la 9)
                        if dataIndex = 7 then
                            dataIndexReset <= '1';  --opresc numararea bitilor
                            st <= STOP;
                        end if;
                    when stop =>    
                        txOut <= '1';     -- trimit 1 ca si bit de stop(al 10-lea bit)
                        startReset <= '1'; -- se pregateste pentru citirea urmatorului octet
                        st <= idle;
                    when others =>
                        st <= idle;
                end case;
            end if;
        end if;
end process;

end Behavioral;
