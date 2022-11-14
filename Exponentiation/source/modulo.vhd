----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.10.2022 17:48:15
-- Design Name: 
-- Module Name: modulo - behavior
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
use ieee.numeric_std.all;

entity modulo is
    generic(
        C_block_size : natural := 256
    );
    port(
        numerator : in  unsigned(C_block_size + 1 downto 0);
        modulus   : in  unsigned(C_block_size - 1 downto 0);
        result    : out unsigned(C_block_size + 1 downto 0)
    );
end entity;

architecture rtl of modulo is

    signal mod_cast : unsigned(c_block_size + 1 downto 0) := (1 => '1', others => '0');

    begin
        mod_cast(c_block_size -1 downto 0) <= modulus;
        result <= numerator mod mod_cast;
end architecture;

-- architecture rtl of modulo is
-- begin
--     result <= numerator - shift_left(modulus, 1) when numerator >= shift_left(modulus, 1) else
--               numerator - modulus                when numerator >= modulus                else
--               numerator;
-- --    process(numerator, modulus) is
-- --    begin
-- --        if numerator >= shift_left(modulus, 1) then
-- --            result <= numerator - shift_left(modulus, 1);
-- --        elsif numerator >= modulus then
-- --            result <= numerator - modulus;
-- --        else
-- --            result <= numerator;
-- --        end if;
-- --    end process;
-- end architecture;