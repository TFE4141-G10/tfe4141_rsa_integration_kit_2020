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
use ieee.std_logic_1164.all;



entity modulo is
    generic(
        c_block_size : natural := 256
    );
    port(
        numerator : in  unsigned(c_block_size - 1 downto 0);
        modulus   : in  std_logic_vector(c_block_size - 1 downto 0);
        result    : out unsigned(c_block_size - 1 downto 0)
    );
end entity;

architecture rtl of modulo is

begin
    
    result <= numerator - shift_left(unsigned(modulus), 1) when numerator >= shift_left(unsigned(modulus), 1) else
              numerator - unsigned(modulus)                when numerator >= unsigned(modulus)                else
              numerator;
--    process(numerator, modulus) is
--    begin
--        if numerator >= shift_left(modulus, 1) then
--            result <= numerator - shift_left(modulus, 1);
--        elsif numerator >= modulus then
--            result <= numerator - modulus;
--        else
--            result <= numerator;
--        end if;
--    end process;
end architecture;