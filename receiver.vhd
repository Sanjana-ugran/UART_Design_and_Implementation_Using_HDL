library ieee;
use ieee.std_logic_1164.all;

entity UART_Receiver is
    port (
        RxD     : in std_logic;
        BclkX8  : in std_logic;
        sysclk  : in std_logic;
        rst_b   : in std_logic;
        RDRF    : in std_logic;
        RDR     : out std_logic_vector(7 downto 0);
        setRDRF : out std_logic;
        setOE   : out std_logic;
        setFE   : out std_logic
    );
end UART_Receiver;

architecture behavioral of UART_Receiver is

    type state_type is (IDLE, START_BIT, DATA_BITS, PARITY, STOP_BIT);
    signal state : state_type := IDLE;

    signal shift_reg : std_logic_vector(7 downto 0);
    signal bit_cnt : integer := 0;
    signal sample_cnt : integer := 0;

begin

    process(BclkX8)
    begin
        if rising_edge(BclkX8) then

            case state is

                when IDLE =>
                    if RxD = '0' then
                        sample_cnt <= 0;
                        state <= START_BIT;
                    end if;

                when START_BIT =>
                    if sample_cnt = 3 then
                        if RxD = '0' then
                            sample_cnt <= 0;
                            bit_cnt <= 0;
                            state <= DATA_BITS;
                        else
                            state <= IDLE;
                        end if;
                    else
                        sample_cnt <= sample_cnt + 1;
                    end if;

                when DATA_BITS =>
                    if sample_cnt = 7 then
                        shift_reg(bit_cnt) <= RxD;
                        if bit_cnt = 7 then
                            state <= STOP_BIT;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;
                        sample_cnt <= 0;
                    else
                        sample_cnt <= sample_cnt + 1;
                    end if;

                when STOP_BIT =>
                    if RxD = '1' then
                        RDR <= shift_reg;
                        setRDRF <= '1';
                    else
                        setFE <= '1';
                    end if;
                    state <= IDLE;

            end case;

        end if;
    end process;

end behavioral;
