library ieee;
use ieee.std_logic_1164.all;

entity UART_Transmitter is
    port (
        Bclk     : in std_logic;
        sysclk   : in std_logic;
        rst_b    : in std_logic;
        TDRF     : in std_logic;
        loadTDR  : in std_logic;
        DBUS     : in std_logic_vector(7 downto 0);
        setTDRF  : out std_logic;
        TxD      : out std_logic
    );
end UART_Transmitter;

architecture behavioral of UART_Transmitter is

    type state_type is (IDLE, START_BIT, DATA_BITS, PARITY, STOP_BIT);
    signal state : state_type := IDLE;

    signal shift_reg : std_logic_vector(7 downto 0);
    signal bit_cnt   : integer := 0;

begin

    process(Bclk)
    begin
        if rising_edge(Bclk) then
            case state is

                when IDLE =>
                    TxD <= '1';
                    if loadTDR = '1' then
                        shift_reg <= DBUS;
                        bit_cnt <= 0;
                        state <= START_BIT;
                        setTDRF <= '1';
                    else
                        setTDRF <= '0';
                    end if;

                when START_BIT =>
                    TxD <= '0';
                    state <= DATA_BITS;

                when DATA_BITS =>
                    TxD <= shift_reg(bit_cnt);
                    if bit_cnt = 7 then
                        state <= STOP_BIT;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;

                when STOP_BIT =>
                    TxD <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;

            end case;
        end if;
    end process;

end behavioral;
