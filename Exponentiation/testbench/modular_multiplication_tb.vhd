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
    constant T            : time      := 10 ns; 
    constant C_BLOCK_SIZE : natural   := 256;

    signal   clk          : std_logic := '0';
    signal   reset_n      : std_logic := '0';
    signal   valid_out    : std_logic;
    signal   factor_a     : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   factor_b     : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   modulus      : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   result       : unsigned(C_BLOCK_SIZE - 1 downto 0);
    signal   result_out   : unsigned(C_BLOCK_SIZE - 1 downto 0);

    file     f_inputs     : text open read_mode is "inputs.txt";

    procedure check_result (
        result   : unsigned(C_BLOCK_SIZE - 1 downto 0); 
        factor_a : unsigned(C_BLOCK_SIZE - 1 downto 0); 
        factor_b : unsigned(C_BLOCK_SIZE - 1 downto 0); 
        modulus  : unsigned(C_BLOCK_SIZE - 1 downto 0)
    ) is
        variable expected_result : unsigned(C_BLOCK_SIZE - 1 downto 0);
    begin
        report LF & LF &
               "Checking (a*b)%n"                  & LF &
               "a: " & "0x" & to_hstring(factor_a) & LF &
               "b: " & "0x" & to_hstring(factor_b) & LF &
               "n: " & "0x" & to_hstring(modulus);

        expected_result := (factor_a*factor_b) mod modulus;
        assert result = expected_result 
            report "Result differs from the expected result"         & LF &
                   "Expected: " & "0x" & to_hstring(expected_result) & LF &
                   "Actual:   " & "0x" & to_hstring(result)
            severity error;
    end procedure;
begin
    DUT : entity work.modular_multiplication
        generic map (
            C_BLOCK_SIZE => C_BLOCK_SIZE
        )
        port map (
            clk          => clk, 
            reset_n      => reset_n, 
            valid_out    => valid_out,
            factor_a     => factor_a, 
            factor_b     => factor_b, 
            modulus      => modulus, 
            result       => result
        );

    clk <= not clk after T/2;

    get_result : process(clk) is
    begin
        if rising_edge(clk) then
            reset_n <= '1';
            if valid_out = '1' then
                reset_n    <= '0';
                result_out <= result;
            end if;
        end if;
    end process;

    process is
    begin
        
    end process;

    set_stimuli : process is
    begin
        -- factor_a <= 0x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01";
        -- factor_b <= 0x"08f9baf32e8505cbc9a28fed4d5791dce46508c3d1636232bf91f5d0b6632a9f";
        -- modulus  <= 0x"0000000000000000000000000000000000000000000000000000000000010001";
        -- answer <= (0x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01" * 0x"08f9baf32e8505cbc9a28fed4d5791dce46508c3d1636232bf91f5d0b6632a9f") mod 0x"0000000000000000000000000000000000000000000000000000000000010001";
        factor_a <= to_unsigned(9, C_BLOCK_SIZE);
        factor_b <= to_unsigned(9, C_BLOCK_SIZE);
        modulus  <= to_unsigned(55, C_BLOCK_SIZE);

        wait until valid_out = '1';
        wait until valid_out = '0';
        check_result(result_out, factor_a, factor_b, modulus);

        file_close(f_inputs);
        wait;
    end process;
end architecture;