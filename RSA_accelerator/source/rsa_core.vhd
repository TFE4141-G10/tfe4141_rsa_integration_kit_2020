--------------------------------------------------------------------------------
-- Author       : Oystein Gjermundnes
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018-2019
-- Project      : RSA accelerator
-- License      : This is free and unencumbered software released into the
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose:
--   RSA encryption core template. This core currently computes
--   C = M xor key_n
--
--   Replace/change this module so that it implements the function
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rsa_core is
	generic (
		-- Users to add parameters here
		C_BLOCK_SIZE           : integer := 256;
		N : integer := 1
	);
	port (
		-----------------------------------------------------------------------------
		-- Clocks and reset
		-----------------------------------------------------------------------------
		clk                    :  in std_logic;
		reset_n                :  in std_logic;

		-----------------------------------------------------------------------------
		-- Slave msgin interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgin_valid             : in std_logic;
		-- Slave ready to accept a new message
		msgin_ready             : out std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgin_data              :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgin_last              :  in std_logic;

		-----------------------------------------------------------------------------
		-- Master msgout interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgout_valid            : out std_logic;
		-- Slave ready to accept a new message
		msgout_ready            :  in std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgout_last             : out std_logic;

		-----------------------------------------------------------------------------
		-- Interface to the register block
		-----------------------------------------------------------------------------
		key_e_d                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		key_n                   :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		rsa_status              : out std_logic_vector(31 downto 0)

	);
end rsa_core;



architecture rtl of rsa_core is

	-----------------------------------------------------------------------------
	-- Signals for multicore design
	-----------------------------------------------------------------------------
	
	signal msgin_valid_vector: std_logic_vector(N downto 0) := (0 => '1', others => '0');
	signal msgout_valid_vector:std_logic_vector(N downto 0) := (others => '0');
	signal msgin_ready_vector: std_logic_vector(N downto 0) := (others => '0');
    signal msgout_ready_vector: std_logic_vector(N downto 0) := (0 => '1', others => '0');
    signal msgout_last_vector:std_logic_vector(N downto 0) := (others => '0');
    
    type data_array is array(N downto 0) of std_logic_vector(255 downto 0); 
    signal msgout_data_array : data_array;
    type status_array is array(N downto 0) of std_logic_vector(31 downto 0); 
    signal rsa_status_array : status_array;
    signal rsa_status_0: std_logic_vector(31 downto 0); 
    signal rsa_status_1: std_logic_vector(31 downto 0); 
    signal msgout_signal_0: std_logic_vector(255 downto 0); 
    signal msgout_signal_1: std_logic_vector(255 downto 0); 
    signal msgin_last_vector: std_logic_vector(255 downto 0);
    
begin
--	i_exponentiation : entity work.exponentiation
--		generic map (
--			C_BLOCK_SIZE => C_BLOCK_SIZE
--		)
--		port map (
--			message      => msgin_data  ,
--			key          => key_e_d     ,
--			valid_in     => msgin_valid ,
--			ready_in     => msgin_ready ,
--			ready_out    => msgout_ready,
--			valid_out    => msgout_valid,
--			result       => msgout_data ,
--			modulus      => key_n       ,
--			clk          => clk         ,
--			last_message_in      => msgin_last  ,
--			last_message_out     => msgout_last ,
--			reset_n      => reset_n
--		);
--	rsa_status <= (others => '0');

generate_cores : for i in 0 to N generate
    u_rsa_exponentiation : entity work.exponentiation
generic map (
    C_BLOCK_SIZE => C_BLOCK_SIZE
)
port map (
    -----------------------------------------------------------------------------
    -- Clocks and reset
    -----------------------------------------------------------------------------
    clk                    => clk,
    reset_n                => reset_n,

    -----------------------------------------------------------------------------
    -- Slave msgin interface
    -----------------------------------------------------------------------------
    valid_in            => msgin_valid_vector(i),
    ready_in            => msgin_ready_vector(i),
    message             => msgin_data,
    last_message_in             => msgin_last_vector(i),

    -----------------------------------------------------------------------------
    -- Master msgout interface
    -----------------------------------------------------------------------------
    valid_out           => msgout_valid_vector(i),
    ready_out         => msgout_ready_vector(i),
    result            => msgout_data_array(i),
    last_message_out            => msgout_last_vector(i),

    -----------------------------------------------------------------------------
    -- Interface to the register block
    -----------------------------------------------------------------------------
    key                => key_e_d,
    modulus                  => key_n
    --rsa_status             => rsa_status_array(i)

    );

end generate;
	
	-----------------------------------------------------------------------------
	-- Multicore signal handeling
	-----------------------------------------------------------------------------
	msgout_data <= msgout_data_array(0) when msgout_ready_vector(0) = '1' else
	
--	generate_data_array : for i in 0 to N generate
--		msgout_data <= msgout_data_array(i) when msgout_ready_vector(i) = '1';
--	end generate;

	msgout_data_array(1) when msgout_ready_vector(1) = '1';
	-- msgout_data_array(2) when msgout_ready_vector(2) = '1' else
	-- msgout_data_array(3) when msgout_ready_vector(3) = '1' else
	-- msgout_data_array(4) when msgout_ready_vector(4) = '1' else
	-- msgout_data_array(N) when msgout_ready_vector(N) = '1';
	
	rsa_status <= rsa_status_array(0) when msgout_ready_vector(0) = '1' else
	rsa_status_array(1) when msgout_ready_vector(1) = '1'; --else
	--rsa_status_array(2) when msgout_ready_vector(2) = '1'; --else
--	rsa_status_array(3) when msgout_ready_vector(3) = '1' else
--	rsa_status_array(4) when msgout_ready_vector(4) = '1' else
--	rsa_status_array(5) when msgout_ready_vector(5) = '1';

	
	msgout_last <= msgout_last_vector(0) when msgout_ready_vector(0) = '1' else
	msgout_last_vector(1) when msgout_ready_vector(1) = '1';
	
	msgout_valid <= msgout_valid_vector(0) when msgout_ready_vector(0) = '1' else
	msgout_valid_vector(1) when msgout_ready_vector(1) = '1';
	
	--msgin_valid <= msgin_valid_vector(0) when msgout_ready_vector(0) = '1' else
	--msgin_valid_vector(1) when msgout_ready_vector(1) = '1';
	
	msgin_ready <= msgin_ready_vector(0) when msgin_valid_vector(0) = '1' else
	msgin_ready_vector(1) when msgin_valid_vector(1) = '1';
	
	
	
	
	-- msgin_valid <= msgin_valid_vector(0) when msgin_valid_vector(0) = '1' else
	-- msgin_valid_vector(1) when msgin_valid_vector(1) = '1';
	
	
	
	
	
	
	-----------------------------------------------------------------------------
	-- Multicore logic handeling
	-----------------------------------------------------------------------------
	
	core_select : process(clk, msgin_valid_vector, msgin_valid, msgin_last) is
	begin 
        if rising_edge(clk) then
            if msgin_valid = '1' and msgin_last = '0' then
                msgin_valid_vector <= std_logic_vector(shift_left(unsigned(msgin_valid_vector), 1));
            end if;
        end if;
	end process;
	

--	last_vector: process(msgin_last) is 
--	   begin
--	   if msgin_last = '1' then
--	      msgin_last_vector <= msgin_valid_vector;
--       end if;
--       end process;
	
	output_select : process(msgout_ready_vector, msgout_ready, msgout_last) is
	begin
	if rising_edge(clk) then
        if msgout_ready = '1' and msgout_last = '0' then 
           msgout_ready_vector <= std_logic_vector(shift_left(unsigned(msgout_ready_vector), 1));
        end if;
    end if;
	end process;
	

end rtl;
