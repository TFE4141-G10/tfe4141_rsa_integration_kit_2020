----------------------------------------------------------------------------------
-- File: modular_multiplication_tb.vhd
-- Description: Testbench for the modular multiplication module
-- Create Date: 10/11/2022
-- Project Name: RSA_accelerator
-- Target Devices: PYNC-Z1
-- Dependencies: modular_multiplication.vhd
----------------------------------------------------------------------------------

library std;
use std.textio.all;
use std.env.finish;
use std.env.stop;

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
        expected_result : unsigned(C_BLOCK_SIZE - 1 downto 0);
        result          : unsigned(C_BLOCK_SIZE - 1 downto 0); 
        factor_a        : unsigned(C_BLOCK_SIZE - 1 downto 0); 
        factor_b        : unsigned(C_BLOCK_SIZE - 1 downto 0); 
        modulus         : unsigned(C_BLOCK_SIZE - 1 downto 0)
    ) is
    begin
        report LF & LF &
               "Checking (a*b)%n"                  & LF &
               "a: " & "0x" & to_hstring(factor_a) & LF &
               "b: " & "0x" & to_hstring(factor_b) & LF &
               "n: " & "0x" & to_hstring(modulus);

        if result /= expected_result then
            report "Result differs from the expected result"         & LF &
                   "Expected: " & "0x" & to_hstring(expected_result) & LF &
                   "Actual:   " & "0x" & to_hstring(result)
                   severity error;
            stop;
        end if;
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
        file     f_inputs          : text;
        file     f_expected        : text;
        variable f_line_inputs     : line;
        variable f_line_expected   : line;
        variable f_expected_result : unsigned(C_BLOCK_SIZE - 1 downto 0);
        variable f_factor_a        : unsigned(C_BLOCK_SIZE - 1 downto 0);
        variable f_factor_b        : unsigned(C_BLOCK_SIZE - 1 downto 0);
        variable f_modulus         : unsigned(C_BLOCK_SIZE - 1 downto 0);
    begin
        file_open(f_inputs, "inputs.txt", read_mode);
        file_open(f_expected, "expected_outputs.txt", read_mode);

        readline(f_inputs, f_line_inputs);
        read(f_line_inputs, f_modulus);
        readline(f_inputs, f_line_inputs); -- skip empty line

        modulus <= f_modulus;

        while not endfile(f_inputs) loop
            readline(f_inputs, f_line_inputs);
            read(f_line_inputs, f_factor_a);
            readline(f_inputs, f_line_inputs);
            read(f_line_inputs, f_factor_b);
            readline(f_inputs, f_line_inputs); -- skip empty line

            factor_a <= f_factor_a;
            factor_b <= f_factor_b;

            wait until valid_out = '1';
            wait until valid_out = '0';

            readline(f_expected, f_line_expected);
            read(f_line_expected, f_expected_result);

            check_result(f_expected_result, result_out, factor_a, factor_b, modulus);
        end loop;

        report LF & LF & "[TESTBENCH FINISHED]";
        file_close(f_inputs);
        file_close(f_expected);
        finish;
    end process;
end architecture;