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
    constant T            : time      := 20 ps; 
    constant C_BLOCK_SIZE : natural   := 256;

    signal   clk          : std_logic := '0';
    signal   reset_n      : std_logic := '0';
    signal   valid_out    : std_logic;
    signal   factor_a     : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   factor_b     : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   modulus      : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   result       : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   result_out   : unsigned(C_BLOCK_SIZE - 1 downto 0);
begin
    clk <= not clk after T/2;

    DUT : entity work.modular_multiplication
        generic map (
            C_BLOCK_SIZE        => C_BLOCK_SIZE
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

    result_process : process(valid_out) is
    begin
        if falling_edge(valid_out) then
            result_out <= result;
        end if;
    end process;

    process
    begin
        reset_n  <= '1';
        factor_a <= to_unsigned(9, C_BLOCK_SIZE);
        factor_b <= to_unsigned(9, C_BLOCK_SIZE);
        modulus  <= to_unsigned(55, C_BLOCK_SIZE);
        -- factor_a <= 0x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01";
        -- factor_b <= 0x"08f9baf32e8505cbc9a28fed4d5791dce46508c3d1636232bf91f5d0b6632a9f";
        -- modulus  <= 0x"0000000000000000000000000000000000000000000000000000000000010001";
        -- answer <= (0x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01" * 0x"08f9baf32e8505cbc9a28fed4d5791dce46508c3d1636232bf91f5d0b6632a9f") mod 0x"0000000000000000000000000000000000000000000000000000000000010001";
        wait until valid_out = '1';
        wait until valid_out = '0';

        wait for 2*T;
        reset_n  <= '0';
        wait for 0.9*T;
        reset_n  <= '1';
--        factor_a <= to_unsigned(9, C_BLOCK_SIZE);
--        factor_b <= to_unsigned(9, C_BLOCK_SIZE);
--        modulus  <= to_unsigned(55, C_BLOCK_SIZE);
        wait;
    end process;
end architecture;