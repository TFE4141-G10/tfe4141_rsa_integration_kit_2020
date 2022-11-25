----------------------------------------------------------------------------------
-- File: modulo.vhd
-- Description: Calculates the modulo, result = numerator % modulus.
-- Create Date: 20/10/2022
-- Design Name: modulo
-- Module Name: modulo
-- Project Name: RSA_accelerator
-- Target Devices: PYNC-Z1
-- Dependencies: modulo.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modulo is
    generic(
        C_BLOCK_SIZE : natural := 256
    );
    port(
        numerator    : in  unsigned(C_BLOCK_SIZE + 1 downto 0); -- 2 bit wider because of left shift and addition
        modulus      : in  unsigned(C_BLOCK_SIZE - 1 downto 0);
        result       : out unsigned(C_BLOCK_SIZE - 1 downto 0)
    );
end entity;

architecture rtl of modulo is
    signal internal_result : unsigned(C_BLOCK_SIZE + 1 downto 0) := (others => '0'); -- need to match signal lengths
begin
    result          <= internal_result(C_BLOCK_SIZE - 1 downto 0);
    internal_result <= numerator - ('0' & modulus & '0')  when numerator >= ('0' & modulus & '0') else
                       numerator - modulus                when numerator >= ("00" & modulus)      else
                       numerator;
end architecture;