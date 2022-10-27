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
		reset_n 	: in STD_LOGIC
	);
end exponentiation;


architecture expBehave of exponentiation is
begin
component modularmultiplication is
        Port (
            clk: in std_logic;
            reset_n: in std_logic;
            a: in std_logic_vector(255 downto 0);
            b: in std_logic_vector(255 downto 0);
            n: in std_logic_vector(255 downto 0);
            blakley_valid: out std_logic;
            r: out std_logic_vector(255 downto 0)
            );
	end component;
	
    signal internal_r: std_logic_vector(255 downto 0) := (others => '0');
    signal internal_a: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux1: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux2: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux3: std_logic_vector(255 downto 0) := (others  => '0');
    signal mux_in: std_logic_vector(255 downto 0) := (others => '0');
    signal s_blakley_valid: std_logic;
    signal doublecalc: bit:='1';
    signal doubleclac_counter: bit:= '0';
    signal counter: unsigned(7 downto 0) := (others => '1'); 
    
    


begin
    -------------MUXES--------------------------------------
    mux1 <= mux3 when counter = 255 else
    internal_r;

    
    mux2 <= message when doubleclac_counter = '1' else
    mux1;
    
    
    mux3 <= message when key(255) = '1' else
    std_logic_vector(to_unsigned(1, 256));
    
    doublecalc <= '1' when key(to_integer(counter)) = '1' else
    '0';
    
    valid_out <= '1' when counter = 0 else
    '0';
    
    
    
    
    --------------------BLAKLEY CORE-------------------------------------
    
    A1: modularmultiplication port map (a => mux1, b => mux2, r => mux_in, clk => clk, reset => reset, n => n, blakley_valid => s_blakley_valid);
    
    --------------------SIGNAL MAPPING------------------------------------------------------
    blakley_done <= s_blakley_valid;
    result <= internal_r;
    count <= counter; 
    
    
    --------------TEST SIGNALS BLAKLEY-----------
    a_blakley <= mux1;
    b_blakley <= mux2;
    n_blakley <= modulus;
    
    
    
    ----------------------------------PROCESS CLK/RST-----------------------------------------NOT IN USE
    process(clk, reset_n) is
    begin
        if reset = '1' then
            --internal_r <= (others => '0');
            --counter <= (others => '0');
            --mux1_mode <= '0';
            --mux2_mode <= '0';
        
        --elsif next_input = '1' and counter = 255 then
           --  next_input <= '0';
            -- mux1_mode <= '0';
            -- mux2_mode <= '1';
        
                      
             
       
        end if;
    end process;
    --------------------PROCESS DATA IN----------------------NOT IN USE
    process (data_valid) is
    begin
    if data_valid = '1' then
       -- mux1_mode <= '0';
    else 
        -- mux1_mode <= '1';
    end if;
    end process;
   ------------------------------------PROCESS BLAKLEY DONE------------------------------------------------------------------
   process(s_blakley_valid, clk) is
   begin
        if s_blakley_valid = '1' and falling_edge(clk) then
            internal_r <= mux_in;
            if doublecalc = '1' and doubleclac_counter = '0' then
                doubleclac_counter <= '1';
            else
                counter <= counter - 1;
                doubleclac_counter <= '0';
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
