library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test is
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        a   : out unsigned(3 downto 0);
        b   : out unsigned(3 downto 0);
        c   : out unsigned(3 downto 0)
    );
end entity;

architecture rtl of test is
    signal i_a : unsigned(3 downto 0) := (others => '0');
    signal i_b : unsigned(3 downto 0) := (others => '0');
    signal i_c : unsigned(3 downto 0) := (others => '0');
begin
    a <= i_a;
    b <= i_b;
    c <= i_c;

    pipeline : process(clk, rst)
    begin
        if rst = '1' then
            i_a <= (others => '0');
            i_b <= (others => '0');
            i_c <= (others => '0');
        elsif rising_edge(clk) then
            i_a <= i_b + 1;
            i_b <= i_c;
            i_c <= i_a;
        end if;
    end process;
end architecture;