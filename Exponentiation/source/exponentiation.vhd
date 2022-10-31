library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC;
		
		--debugging purposes binary
		count       : out unsigned(7 DOWNTO 0);
		
		--debugging purposes blakley
		a_blakley  : out std_logic_vector(255 downto 0);
		b_blakley  : out std_logic_vector(255 downto 0);
		n_blakley  : out std_logic_vector(255 downto 0);
		blakley_done: out std_logic
		
	);
end exponentiation;


architecture expBehave of exponentiation is
component modular_multiplication is
        Port (
            clk: in std_logic;
            reset_n: in std_logic;
            factor_a: in unsigned(255 downto 0);
            factor_b: in unsigned(255 downto 0);
            modulus: in unsigned(255 downto 0);
            valid_out: out std_logic;
            result: out unsigned(255 downto 0)
            );
	end component;
	
    signal internal_r: std_logic_vector(255 downto 0) := (others => '0');
    signal mux_factor_a: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux_factor_b: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux_start_condition: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux_in: std_logic_vector(255 downto 0) := (others => '0');
    signal s_blakley_done: std_logic;
    signal doublecalc: std_logic := '1';
    signal doubleclac_counter: std_logic := '0';
    signal counter: unsigned(7 downto 0) := (others => '1'); 
    signal s_message: std_logic_vector(255 downto 0);
    signal message_recived: std_logic := '0';
    signal clear: std_logic := '0';
    


begin
    -------------MUXES--------------------------------------
    mux_factor_a <= mux_start_condition when counter = 255 else
    internal_r;

    
    mux_factor_b <= s_message when doubleclac_counter = '1' else
    mux_factor_a;
    
    
    mux_start_condition <= s_message when key(255) = '1' else
    std_logic_vector(to_unsigned(1, 256));
    
    doublecalc <= '1' when key(to_integer(counter)) = '1' else
    '0';
    ------------------Flow controll-----------------------
    valid_out <= '1' when counter = 0 else
    '0';
    
    --ready_in <= '1' when counter = 255 else
    --'0';
    
    
    
    
    
    
    
    
    --------------------BLAKLEY CORE-------------------------------------
    
    M0: modular_multiplication port map (factor_a => unsigned(mux_factor_a), factor_b => unsigned(mux_factor_b), std_logic_vector(result) => mux_in, clk => clk, reset_n => clear, modulus => unsigned(modulus), valid_out => s_blakley_done);
    
    --------------------SIGNAL MAPPING------------------------------------------------------
    blakley_done <= s_blakley_done;
    result <= internal_r;
    count <= counter; 
    
    
    --------------TEST SIGNALS BLAKLEY-----------
    a_blakley <= mux_factor_a;
    b_blakley <= mux_factor_b;
    n_blakley <= modulus;
    
    
    
    ----------------------------------PROCESS CLK/RST-----------------------------------------NOT IN USE
    process(clk, reset_n) is
    begin
        if reset_n = '0' then
            internal_r <= (others => '0');
            --counter <= (others => '0');
            --doubleclac_counter <= '0';
            s_message <= (others => '0');
            
         elsif rising_edge(clk) then
            if ready_in = '1' and valid_in = '1' then
            s_message <= message;
            ready_in <= '0';
            message_recived <= '1';
            clear <= '1';
            
            elsif message_recived = '0' then
            ready_in <= '1';
            clear <= '0';
            
            elsif clear = '0' then 
                clear <= '1'; 
            
            --elsif counter = 255 then
            --ready_in <= '0';
         end if; 
            --mux1_mode <= '0';
            --mux2_mode <= '0';
        
        --elsif next_input = '1' and counter = 255 then
           --  next_input <= '0';
            -- mux1_mode <= '0';
            -- mux2_mode <= '1';
        
                      
             
       
        end if;
    end process;
    --------------------PROCESS DATA IN----------------------NOT IN USE
   -- process (data_valid) is
    --begin
    --if data_valid = '1' then
       -- mux1_mode <= '0';
    --else 
        -- mux1_mode <= '1';
    --end if;
    --end process;
   ------------------------------------PROCESS BLAKLEY DONE------------------------------------------------------------------
   process(s_blakley_done) is
   begin
        if falling_edge(s_blakley_done) then
            clear <= '0';
            internal_r <= mux_in;
            if doublecalc = '1' and doubleclac_counter = '0' then
                doubleclac_counter <= '1';
            elsif counter > 0 then
                counter <= counter - 1;
                doubleclac_counter <= '0';
            elsif counter = 0 then
                -- Wait and to do something
            end if;
        end if;
        
        
        --if doubleclac_counter = '1' then
          --  counter <= counter -1;
        --end if;
        
            --mux2_mode <= '0';
        --else 
            --mux2_mode <= '0';
            
         
            --if counter = 0 then 
              --  next_input <= '1';
                --internal_r <= mux_in;
            --else 
              --  next_input <= '0';
            --end if; 
   end process;
end expBehave;
