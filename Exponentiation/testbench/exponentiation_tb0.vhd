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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity exponentiation_tb0 is
--  Port ( );
end exponentiation_tb0;

architecture behavior of exponentiation_tb0 is
constant T : time := 20 ps; 
constant A_C : integer := 51; 
constant B_C : integer := 3; 
constant N_C: integer := 55; 
signal clk : std_logic := '0'; 
signal reset_n : std_logic;
signal count: unsigned(7 downto 0);
signal valid_out: std_logic;
signal key : std_logic_vector(255 downto 0);
signal message, modulus : std_logic_vector(255 downto 0);
signal result: std_logic_vector(255 downto 0);
signal ready_out, ready_in: std_logic; 
signal valid_in: std_logic:='0';


begin
    UUT : entity work.exponentiation port map ( 
        ready_in => ready_in, 
        valid_in => valid_in, 
        ready_out => ready_out, 
        message => message, 
        key => key, 
        modulus => modulus, 
        result => result, 
        valid_out => valid_out, 
        clk => clk, 
        reset_n => reset_n,
        count => count
    );
    clk <= not clk after T/2;
    
    stimuli : process
    begin
        message <= (others => '0'), std_logic_vector(to_unsigned(B_C, 256)); -- after 5*T,(others => '0') after 10*T ;
        key <= std_logic_vector(to_unsigned(A_C, 256));
        modulus <= std_logic_vector(to_unsigned(N_C, 256));
        reset_n <= '0';

        wait for 5*T;
        reset_n <= '1';

        wait for 1*T;
        valid_in <= '1';

        wait for 4*T;
        valid_in <= '0';

        wait;
    end process;
end architecture;
