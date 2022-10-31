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

entity modular_multiplication_tb is
end entity;

architecture behavior of modular_multiplication_tb is
    constant T         : time      := 20 ps; 
    constant N         : natural   := 256;
    signal   clk       : std_logic := '0';
    signal   reset_n   : std_logic := '0';
    signal   valid_out : std_logic;
    signal   factor_a  : unsigned(N - 1 downto 0);
    signal   factor_b  : unsigned(N - 1 downto 0);
    signal   modulus   : unsigned(N - 1 downto 0);
    signal   result    : unsigned(N - 1 downto 0);
    signal   counter   : natural range 0 to N - 1;
begin
    counter_process : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            counter <= N - 1;
        elsif rising_edge(clk) then
            counter <= counter - 1;
        end if;
    end process;


    DUT : entity work.modular_multiplication
        generic map (
            N         => N
        )
        port map (
            clk       => clk, 
            reset_n   => reset_n, 
            valid_out => valid_out,
            factor_a  => factor_a, 
            factor_b  => factor_b, 
            modulus   => modulus, 
            result    => result
        );

    clk <= not clk after T/2;

    process
    begin
        -- counter <= N - 1;
        reset_n  <= '1';
        factor_a <= to_unsigned(56, N);
        factor_b <= to_unsigned(83, N);
        modulus  <= to_unsigned(55, N);
        wait for 5122 ps;
            -- counter <= N - 1;
        factor_a <= to_unsigned(63, N);
        factor_b <= to_unsigned(83, N);
        modulus  <= to_unsigned(55, N);
        wait;
    end process;
end architecture;