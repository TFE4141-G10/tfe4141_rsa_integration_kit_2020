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
    constant T          : time      := 20 ps; 
    constant c_block_size        : natural   := 256;
    signal   clk        : std_logic := '0';
    signal   reset_n    : std_logic := '0';
    signal   valid_out  : std_logic;
    signal   factor_a   : unsigned(c_block_size - 1 downto 0);
    signal   factor_b   : unsigned(c_block_size - 1 downto 0);
    signal   modulus    : unsigned(c_block_size - 1 downto 0);
    signal   result     : unsigned(c_block_size - 1 downto 0);
    signal   result_out : unsigned(c_block_size - 1 downto 0);
    signal   counter    : natural range 0 to c_block_size - 1 := c_block_size - 1;
    signal answer : unsigned(c_block_size -1 downto 0);
begin
    clk <= not clk after T/2;

    DUT : entity work.modular_multiplication
        generic map (
            c_block_size        => c_block_size
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

    counter_process : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            counter <= c_block_size - 1;
        elsif rising_edge(clk) then
            counter <= counter - 1;
        end if;
    end process;

    result_process : process(valid_out) is
    begin
        if falling_edge(valid_out) then
            result_out <= result;
        end if;
    end process;

    process
    begin
        reset_n  <= '1';
        factor_a <= 0x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01";
        factor_b <= 0x"08f9baf32e8505cbc9a28fed4d5791dce46508c3d1636232bf91f5d0b6632a9f";
        modulus  <= 0x"0000000000000000000000000000000000000000000000000000000000010001";
        answer <= (0x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01" * 0x"08f9baf32e8505cbc9a28fed4d5791dce46508c3d1636232bf91f5d0b6632a9f") mod 0x"0000000000000000000000000000000000000000000000000000000000010001";
        wait for 5112 ps;
        reset_n  <= '0';
--        factor_a <= to_unsigned(9, N);
--        factor_b <= to_unsigned(9, N);
--        modulus  <= to_unsigned(55, N);
        wait for 10 ps;
        reset_n  <= '1';
        wait;
    end process;
end architecture;