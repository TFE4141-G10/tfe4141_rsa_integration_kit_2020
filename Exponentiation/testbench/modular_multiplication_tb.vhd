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
library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

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

    ----------------------------------------------------------------------------------
    -- brief: Calculates (factor_a * factor_b) mod modulus and compares it to result
    -- param: result, from modular multiplication
    -- param: factor_a
    -- param: factor_b
    -- param: modulus
    ----------------------------------------------------------------------------------
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
    ----------------------------------------------------------------------------------
    -- Instance of a modular multiplication core using the Blakley algorithm
    ----------------------------------------------------------------------------------
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

    ----------------------------------------------------------------------------------
    -- get_result: Checks if the result is valid and stores that result
    ----------------------------------------------------------------------------------
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

    ----------------------------------------------------------------------------------
    -- set_stimuli_from_file: Reads the stimuli from a file and sets the signals. The
    -- result is checked after a valid result is received
    ----------------------------------------------------------------------------------
    set_stimuli_from_file : process is
        file     f_inputs   : text;
        variable f_line     : line;
        variable f_factor_a : unsigned(C_BLOCK_SIZE - 1 downto 0);
        variable f_factor_b : unsigned(C_BLOCK_SIZE - 1 downto 0);
        variable f_modulus  : unsigned(C_BLOCK_SIZE - 1 downto 0);
    begin
        file_open(f_inputs, "C:\Users\espen\Repositories\TFE4141\tfe4141_rsa_integration_kit_2020\Exponentiation\testbench\inputs.txt", read_mode);

        readline(f_inputs, f_line);
        read(f_line, f_modulus);
        readline(f_inputs, f_line); -- skip empty line

        modulus <= f_modulus;

        while not endfile(f_inputs) loop
            readline(f_inputs, f_line);
            read(f_line, f_factor_a);
            readline(f_inputs, f_line);
            read(f_line, f_factor_b);
            readline(f_inputs, f_line); -- skip empty line

            factor_a <= f_factor_a;
            factor_b <= f_factor_b;

            wait until valid_out = '1';
            wait until valid_out = '0';
            check_result(result_out, factor_a, factor_b, modulus);
        end loop;

        file_close(f_inputs);
        finish;
    end process;
end architecture;