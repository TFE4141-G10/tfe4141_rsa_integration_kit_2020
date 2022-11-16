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
        C_BLOCK_SIZE : natural := 256
    );
    port(
        numerator : in  unsigned(C_BLOCK_SIZE + 1 downto 0); -- 2 bit wider because of left shift and addition
        modulus   : in  unsigned(C_BLOCK_SIZE - 1 downto 0);
        result    : out unsigned(C_BLOCK_SIZE - 1 downto 0)
    );
end entity;

architecture rtl of modulo is
begin
    result <= numerator - shift_left(modulus, 1) when numerator >= shift_left(modulus, 1) else
              numerator - modulus                when numerator >= modulus                else
              numerator;
end architecture;