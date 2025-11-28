library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
    port (
        sysclk : in std_logic;
        rst_b  : in std_logic;
        Sel    : in std_logic_vector(2 downto 0);
        BclkX8 : out std_logic;
        Bclk   : out std_logic
    );
end clk_divider;

architecture baudgen of clk_divider is

    signal ctr1 : unsigned(3 downto 0) := (others => '0');
    signal ctr2 : unsigned(7 downto 0) := (others => '0');
    signal ctr3 : unsigned(2 downto 0) := (others => '0');
    signal clkdiv13 : std_logic;

begin

    process(sysclk)
    begin
        if rising_edge(sysclk) then
            if ctr1 = 12 then
                ctr1 <= (others => '0');
            else
                ctr1 <= ctr1 + 1;
            end if;
        end if;
    end process;

    clkdiv13 <= std_logic(ctr1(3));

    process(clkdiv13)
    begin
        if rising_edge(clkdiv13) then
            ctr2 <= ctr2 + 1;
        end if;
    end process;

    BclkX8 <= std_logic(ctr2(to_integer(unsigned(Sel))));

    process(BclkX8)
    begin
        if rising_edge(BclkX8) then
            ctr3 <= ctr3 + 1;
        end if;
    end process;

    Bclk <= std_logic(ctr3(2));

end baudgen;
