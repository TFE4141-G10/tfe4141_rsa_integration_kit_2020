----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2022 03:15:41 PM
-- Design Name: 
-- Module Name: Blakley - Behavioral
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

entity modular_multiplication is
    generic(
        C_block_size : integer := 256
    );
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        valid_out    : out std_logic;
        factor_a     : in  unsigned(C_block_size - 1 downto 0);
        factor_b     : in  unsigned(C_block_size - 1 downto 0);
        modulus      : in  unsigned(C_block_size - 1 downto 0);
        result       : out unsigned(C_block_size - 1 downto 0)
    );
end entity;

architecture rtl of modular_multiplication is
    signal internal_addition : unsigned(C_block_size + 1 downto 0) := (others => '0');
    signal internal_modulo   : unsigned(C_block_size + 1 downto 0) := (others => '0');
    signal internal_result   : unsigned(C_block_size + 1 downto 0) := (others => '0');
    signal internal_factor_b : unsigned(C_block_size - 1 downto 0);
    signal counter           : unsigned(7 downto 0);
begin
    ----------------------------------------------------------------------------------
    -- Internal calculations for the modular multiplication
    ----------------------------------------------------------------------------------
    internal_factor_b <= factor_b when factor_a(to_integer(counter)) = '1' else (others => '0');
    internal_addition <= shift_left(internal_result, 1) + internal_factor_b;    
    result            <= internal_result(c_block_size -1 downto 0);
    
    ----------------------------------------------------------------------------------
    -- When the counter is equal to 0, it means that the calculation has iterated 
    -- through the whole number, and the result is valid on falling edge of valid_out.
    ----------------------------------------------------------------------------------
    valid_out         <= '1' when counter = 0 else 
                         '0';

    ----------------------------------------------------------------------------------
    -- count_down: This process decrements the counter by 1 every clock cycle.
    ----------------------------------------------------------------------------------
    count_down : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            counter <= (others => '1');
        elsif rising_edge(clk) then
            counter <= counter - 1;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    -- pipeline: This process defines the pipelines in the rtl.
    ----------------------------------------------------------------------------------
    pipeline : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            internal_result   <= (others => '0');
            -- internal_addition <= (others => '0');
        elsif rising_edge(clk) then
            -- internal_addition <= shift_left(internal_result, 1) + internal_factor_b;
            internal_result   <= internal_modulo;    
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    -- i_modulo: This instance performs modulo operation.
    ----------------------------------------------------------------------------------
    i_modulo : entity work.modulo
        generic map (
            C_block_size => C_block_size
        )
        port map (
            numerator    => internal_addition, 
            modulus      => modulus, 
            result       => internal_modulo
        );
end architecture;