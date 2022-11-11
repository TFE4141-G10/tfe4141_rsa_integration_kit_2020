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
    type   message_state_type        is (uninitialized, idle, load_new_message);
    constant T                    : time := 20 ps;
    signal   clk                  : std_logic := '0'; 
    signal   reset_n              : std_logic;
    signal   valid_out            : std_logic;
    signal   message              : std_logic_vector(255 downto 0); 
    signal   key                  : std_logic_vector(255 downto 0);
    signal   modulus              : std_logic_vector(255 downto 0);
    signal   result               : std_logic_vector(255 downto 0);
    signal   ready_out            : std_logic; 
    signal   ready_in             : std_logic; 
    signal   valid_in             : std_logic :='0';
    signal   expected_result      : unsigned(255 downto 0);
begin
    UUT : entity work.exponentiation port map ( 
        clk                  => clk, 
        reset_n              => reset_n,
        ready_in             => ready_in, 
        valid_in             => valid_in, 
        ready_out            => ready_out,
        valid_out            => valid_out,  
        message              => message, 
        key                  => key, 
        modulus              => modulus, 
        result               => result
    );

    clk <= not clk after T/2;
    
    stimuli : process
    begin
        message         <= x"0a23232323232323232323232323232323232323232323232323232323232323";
        key             <= x"0000000000000000000000000000000000000000000000000000000000010001";
        modulus         <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
        expected_result <= x"85EE722363960779206A2B37CC8B64B5FC12A934473FA0204BBAAF714BC90C01";

        --message   <= std_logic_vector(to_unsigned(51, 256));
        --key       <= std_logic_vector(to_unsigned(3, 256));
        --modulus   <= std_logic_vector(to_unsigned(55, 256));
        
        -- message   <= (255 => '0', others => '1');
        -- key       <= std_logic_vector(to_unsigned(15, 256));
        -- modulus   <= std_logic_vector(to_unsigned(2, 256));

        reset_n   <= '1';
        valid_in  <= '1';
        ready_out <= '1';

        wait for T;

        valid_in  <= '0';
        ready_out <= '1';

        -- wait for T;

        -- message   <= std_logic_vector(to_unsigned( 9, 256));
        -- key       <= std_logic_vector(to_unsigned( 3, 256));
        -- modulus   <= std_logic_vector(to_unsigned(55, 256));

        wait until valid_out = '1';
        -- wait for 3*T;

        -- ready_out <= '1';
        -- valid_in  <= '1';

        -- wait for 2*T;

        -- ready_out <= '0';
        -- valid_in  <= '0';
        -- reset_n   <= '0';

        -- wait for T;

        -- reset_n   <= '1';

        -- wait;

        

        -- assert result = std_logic_vector(to_unsigned(46, 256)) report "Test 1 failed" severity error;


        
        --reset_n <= '0';

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