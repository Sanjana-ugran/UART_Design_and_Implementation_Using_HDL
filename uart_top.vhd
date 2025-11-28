library ieee;
use ieee.std_logic_1164.all;

entity UART is
    port (
        SCI_sel : in std_logic;
        R_W     : in std_logic;
        clk     : in std_logic;
        RxD     : in std_logic;
        ADDR    : in std_logic_vector(1 downto 0);
        DBUS    : inout std_logic_vector(7 downto 0);
        SCI_IRQ : out std_logic;
        TxD     : out std_logic
    );
end UART;

architecture behavioral of UART is

    component UART_Receiver
        port (
            RxD      : in std_logic;
            BclkX8   : in std_logic;
            sysclk   : in std_logic;
            rst_b    : in std_logic;
            RDRF     : in std_logic;
            RDR      : out std_logic_vector(7 downto 0);
            setRDRF  : out std_logic;
            setOE    : out std_logic;
            setFE    : out std_logic
        );
    end component;

    component UART_Transmitter
        port (
            Bclk      : in std_logic;
            sysclk    : in std_logic;
            rst_b     : in std_logic;
            TDRF      : in std_logic;
            loadTDR   : in std_logic;
            DBUS      : in std_logic_vector(7 downto 0);
            setTDRF   : out std_logic;
            TxD       : out std_logic
        );
    end component;

    component clk_divider
        port (
            sysclk : in std_logic;
            rst_b  : in std_logic;
            Sel    : in std_logic_vector(2 downto 0);
            BclkX8 : out std_logic;
            Bclk   : out std_logic
        );
    end component;

    signal RDR     : std_logic_vector(7 downto 0);
    signal SCSR    : std_logic_vector(7 downto 0);
    signal SCCR    : std_logic_vector(7 downto 0);
    signal TDRF    : std_logic;
    signal RDRF    : std_logic;
    signal OE      : std_logic;
    signal FE      : std_logic;
    signal TIE     : std_logic;
    signal RIE     : std_logic;
    signal BaudSel : std_logic_vector(2 downto 0);
    signal setTDRF, setRDRF, setOE, setFE, loadTDR, loadSCCR : std_logic;
    signal clrRDRF, Bclk, BclkX8, SCI_Read, SCI_Write : std_logic;

begin

    RCVR : UART_Receiver
        port map (RxD, BclkX8, clk, '1', RDRF, RDR, setRDRF, setOE, setFE);

    XMIT : UART_Transmitter
        port map (Bclk, clk, '1', TDRF, loadTDR, DBUS, setTDRF, TxD);

    CLKDTV : clk_divider
        port map (clk, '1', BaudSel, BclkX8, Bclk);

    process (clk)
    begin
        if rising_edge(clk) then
            if loadSCCR = '1' then
                TIE <= DBUS(7);
                RIE <= DBUS(6);
                BaudSel <= DBUS(2 downto 0);
            end if;
        end if;
    end process;

    SCI_IRQ <= '1' when
        ((RIE = '1' and (RDRF = '1' or OE = '1')) or
         (TIE = '1' and TDRF = '1'))
        else '0';

    SCSR <= TDRF & RDRF & "0000" & OE & FE;
    SCCR <= TIE & RIE & "000" & BaudSel;

    SCI_Read  <= '1' when (SCI_sel = '1' and R_W = '0') else '0';
    SCI_Write <= '1' when (SCI_sel = '1' and R_W = '1') else '0';

    clrRDRF  <= '1' when (SCI_Read = '1' and ADDR = "00") else '0';
    loadTDR  <= '1' when (SCI_Write = '1' and ADDR = "00") else '0';
    loadSCCR <= '1' when (SCI_Write = '1' and ADDR = "01") else '0';

    DBUS <= RDR  when (SCI_Read = '1' and ADDR = "00") else
             SCSR when (SCI_Read = '1' and ADDR = "01") else
             SCCR when (SCI_Read = '1' and ADDR = "10") else
             (others => 'Z');

end behavioral;
