----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2022 11:14:50 AM
-- Design Name: 
-- Module Name: RSA_tb - behavior
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_tb is
end entity;

architecture behavior of test_tb is
    constant T   : time    := 1 ns;

    signal   clk : std_logic := '0';
    signal   rst : std_logic := '0';
    signal   a   : unsigned(3 downto 0);
    signal   b   : unsigned(3 downto 0); 
    signal   c   : unsigned(3 downto 0);
begin
    clk <= not clk after T/2;

    DUT : entity work.test
        port map (
            clk => clk, 
            rst => rst, 
            a   => a,
            b   => b,
            c   => c
        );

    process
    begin
        rst <= '0';
        wait for 10*T;
        rst <= '1';
        wait;
    end process;
end architecture;