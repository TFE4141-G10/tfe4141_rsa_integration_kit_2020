----------------------------------------------------------------------------------
-- File: modular_multiplication.vhd
-- Description: Calculates the modular multiplication, result = a*b % modulus, 
--              using the Blakley algorithm.
--              Used in exponentiation algorithm for RSA decryption/encryption
-- Create Date: 10/11/2022
-- Design Name: modular_multiplication
-- Module Name: modular_multiplication
-- Project Name: RSA_accelerator
-- Target Devices: PYNC-Z1
-- Dependencies: modulo.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modular_multiplication is
    generic(
        C_BLOCK_SIZE : integer := 256
    );
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        valid_out    : out std_logic;
        factor_a     : in  unsigned(C_BLOCK_SIZE - 1 downto 0);
        factor_b     : in  unsigned(C_BLOCK_SIZE - 1 downto 0);
        modulus      : in  unsigned(C_BLOCK_SIZE - 1 downto 0);
        result       : out unsigned(C_BLOCK_SIZE - 1 downto 0)
    );
end entity;

architecture rtl of modular_multiplication is
    signal internal_factor_b   : unsigned(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal internal_left_shift : unsigned(C_BLOCK_SIZE - 0 downto 0) := (others => '0'); -- 1 bit wider because of left shift
    signal internal_addition   : unsigned(C_BLOCK_SIZE + 1 downto 0) := (others => '0'); -- 2 bits wider because of addition
    signal internal_modulo     : unsigned(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal internal_result     : unsigned(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal counter             : unsigned(7 downto 0);
    signal counter_is_reset    : std_logic;
    signal internal_valid_out  : std_logic;
    signal is_start            : std_logic := '1';
begin
    ----------------------------------------------------------------------------------
    -- Internal calculations for the modular multiplication
    ----------------------------------------------------------------------------------
    internal_factor_b   <= factor_b when factor_a(to_integer(counter)) = '1' else (others => '0');
    internal_left_shift <= internal_result & '0'; -- left shift by 1 bit
    internal_addition   <= ('0' & internal_left_shift) + ("00" & internal_factor_b);    
    result              <= internal_result;
    
    ----------------------------------------------------------------------------------
    -- When the counter is equal to 0, it means that the last calculation is under way 
    -- and the result is valid on rising edge of valid_out.
    ----------------------------------------------------------------------------------
    counter_is_reset <= '1' when counter = 0 else '0';
    valid_out        <= internal_valid_out;

    ----------------------------------------------------------------------------------
    -- Sets internal_valid_out to '1' when counter is reset and but not on the start
    ----------------------------------------------------------------------------------
    set_internal_valid_out : process (clk, reset_n, counter_is_reset, is_start) is
    begin
        if reset_n = '0' then
            internal_valid_out <= '0';
        elsif rising_edge(clk) then
            if counter_is_reset = '1' and is_start = '0' then
                internal_valid_out <= '1';
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    -- Ensures that valid_out cannot be '1' on the start even though counter is 255
    ----------------------------------------------------------------------------------
    set_start_flag : process (clk, counter_is_reset, is_start) is
    begin
        if rising_edge(clk) then
            if counter_is_reset = '0' and is_start = '1' then
                is_start <= '0';
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    -- count_down: This process decrements the counter by 1 every clock cycle.
    ----------------------------------------------------------------------------------
    count_down : process(clk, reset_n, counter) is
    begin
        if reset_n = '0' then
            counter <= (others => '1');
        elsif rising_edge(clk) then
            counter <= counter - 1;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    -- pipeline: This process defines the pipelines in the rtl.
    ----------------------------------------------------------------------------------
    pipeline : process(clk, reset_n, internal_modulo) is
    begin
        if reset_n = '0' then
            internal_result   <= (others => '0');
            -- internal_addition <= (others => '0');
        elsif rising_edge(clk) then
            -- internal_addition <= shift_left(internal_result, 1) + internal_factor_b;
            internal_result   <= internal_modulo;    
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    -- i_modulo: This instance performs modulo operation.
    ----------------------------------------------------------------------------------
    i_modulo : entity work.modulo
        generic map (
            C_BLOCK_SIZE => C_BLOCK_SIZE
        )
        port map (
            numerator    => internal_addition, 
            modulus      => modulus, 
            result       => internal_modulo
        );
end architecture;