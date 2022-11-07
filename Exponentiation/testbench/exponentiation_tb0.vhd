----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2022 11:52:38 AM
-- Design Name: 
-- Module Name: exponentiation_tb0 - Behavioral
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

entity exponentiation_tb0 is
end entity;

architecture behavior of exponentiation_tb0 is
    constant T                    : time := 20 ps;
    signal   clk                  : std_logic := '0'; 
    signal   reset_n              : std_logic;
    signal   count                : unsigned(7 downto 0);
    signal   valid_out            : std_logic;
    signal   message              : std_logic_vector(255 downto 0); 
    signal   key                  : std_logic_vector(255 downto 0);
    signal   modulus              : std_logic_vector(255 downto 0);
    signal   result               : std_logic_vector(255 downto 0);
    signal   ready_out            : std_logic; 
    signal   ready_in             : std_logic; 
    signal   valid_in             : std_logic :='0';
    signal   internal_message_out : std_logic_vector(255 downto 0);
begin
    UUT : entity work.exponentiation port map ( 
        ready_in             => ready_in, 
        valid_in             => valid_in, 
        ready_out            => ready_out, 
        message              => message, 
        key                  => key, 
        modulus              => modulus, 
        result               => result, 
        valid_out            => valid_out, 
        clk                  => clk, 
        reset_n              => reset_n,
        count                => count,
        internal_message_out => internal_message_out
    );

    clk <= not clk after T/2;
    
    stimuli : process
    begin
        message <= std_logic_vector(to_unsigned(51, 256));
        key     <= std_logic_vector(to_unsigned( 3, 256));
        modulus <= std_logic_vector(to_unsigned(55, 256));
        reset_n <= '0';

        wait for 4.5*T;

        reset_n  <= '1';
        valid_in <= '1';

        wait for T;

        valid_in <= '0';

        wait for T;

        message <= std_logic_vector(to_unsigned( 9, 256));
        key     <= std_logic_vector(to_unsigned( 3, 256));
        modulus <= std_logic_vector(to_unsigned(55, 256));

        wait until valid_out = '1';
        
        assert result = std_logic_vector(to_unsigned(46, 256)) report "Test 1 failed" severity error;
        
        -- reset_n <= '0';

        -- wait for T;

        -- reset_n <= '1';
        -- valid_in <= '1';

        -- wait for T;

        -- valid_in <= '0';

        -- wait until valid_out = '1';

        -- assert result = std_logic_vector(to_unsigned(14, 256)) report "Test 2 failed" severity error;
        -- reset_n <= '0';

        -- wait for T;
    end process;
end architecture;
