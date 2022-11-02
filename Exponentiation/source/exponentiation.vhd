library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	generic (
		N : integer := 256
	);
	port (
		--input controll
		valid_in	: in  std_logic;
		ready_in	: out std_logic;

		--input data
		message 	: in  std_logic_vector(N - 1 downto 0);
		key 		: in  std_logic_vector(N - 1 downto 0);

		--ouput controll
		ready_out	: in  std_logic;
		valid_out	: out std_logic;

		--output data
		result 		: out std_logic_vector(N - 1 downto 0);

		--modulus
		modulus 	: in  std_logic_vector(N - 1 downto 0);

		--utility
		clk 		: in  std_logic;
		reset_n 	: in  std_logic;
		
		--debugging purposes binary
		count       : out unsigned(7 DOWNTO 0)
	);
end entity;


architecture rtl of exponentiation is
    type multiplication_state_type is (single_multiplication, double_multiplication);
    type message_state_type     is (message_received, message_not_received);
    signal calculation_state      : multiplication_state_type := double_multiplication;
    signal next_calculation_state : multiplication_state_type;
    signal message_state          : message_state_type     := message_not_received;
    signal next_message_state     : message_state_type;
    signal internal_result        : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal factor_a               : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal factor_b               : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal start_condition        : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal mux_in                 : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal multiplication_done    : std_logic;
    --signal doublecalc             : std_logic := '1';
    --signal doubleclac_counter     : std_logic := '0';
    signal counter                : unsigned(7 downto 0) := (others => '1'); 
    signal internal_message       : std_logic_vector(255 downto 0);
    --signal message_received       : std_logic := '0';
    signal clear_multiplication   : std_logic := '0';


begin
    -------------MUXES--------------------------------------
    factor_a        <= start_condition when counter = N - 1 else
                       internal_result;
    factor_b        <= internal_message when calculation_state = double_multiplication else
                       factor_a;
    start_condition <= internal_message when key(N - 1) = '1' else
                       std_logic_vector(to_unsigned(1, 256)); 
    -- doublecalc <= '1' when key(to_integer(counter)) = '1' else '0';
    ------------------Flow controll-----------------------
    valid_out <= '1' when counter = 0 else '0';
    
    --------------------BLAKLEY CORE-------------------------------------
    
    M0: entity work.modular_multiplication 
        generic map (
            N => N
        )
        port map (
            factor_a => unsigned(factor_a), 
            factor_b => unsigned(factor_b), 
            std_logic_vector(result) => mux_in, 
            clk => clk, 
            reset_n => clear_multiplication, 
            modulus => unsigned(modulus), 
            valid_out => multiplication_done
        );
    
    --------------------SIGNAL MAPPING------------------------------------------------------
    result        <= internal_result;
    count         <= counter;


    change_message_state : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            message_state <= message_not_received;
        elsif rising_edge(clk) then
            message_state <= next_message_state;
        end if;
    end process;

    message_state_machine : process(message_state, ready_in, valid_in, message) is
    begin
        case message_state is
            when message_not_received =>
                ready_in           <= '1';
                next_message_state <= message_received;
            when message_received =>
                if ready_in = '1' and valid_in = '1' then
                    ready_in           <= '0';
                    internal_message   <= message;
                    next_message_state <= message_not_received;
                else
                    
                    next_message_state <= message_received;
                end if;     
        end case;
    end process;


    change_calculation_state : process(multiplication_done) is
    begin
        clear_multiplication <= '1';
        if falling_edge(multiplication_done) then
            clear_multiplication <= '0';
            internal_result      <= mux_in;
            calculation_state    <= next_calculation_state;
        end if;
    end process;

    calculation_state_machine : process(calculation_state, counter) is
    begin
        case calculation_state is
            when single_multiplication =>
                if key(to_integer(counter)) = '1' then
                    next_calculation_state <= double_multiplication;
                else
                    next_calculation_state <= single_multiplication;
                    counter <= counter - 1;
                end if; 
            when double_multiplication =>
                next_calculation_state <= single_multiplication;
        end case;
    end process;
end architecture;


 ------------------------------------PROCESS BLAKLEY DONE------------------------------------------------------------------
    -- process(multiplication_done, clk) is
    -- begin
    --      if falling_edge(multiplication_done) then
    --          clear_multiplication <= '0';
    --          internal_result <= mux_in;
    --          if doublecalc = '1' and doubleclac_counter = '0' then
    --              doubleclac_counter <= '1';
    --          else
    --              counter <= counter - 1;
    --              doubleclac_counter <= '0';
    --          end if;
    --      else 
    --          clear_multiplication <= '1';
    --      end if;
    -- end process;

        
    ----------------------------------PROCESS CLK/RST-----------------------------------------NOT IN USE
    -- process(clk, reset_n) is
    -- begin
    --     if reset_n = '0' then
    --         internal_message <= (others => '0');
    --     elsif rising_edge(clk) then
    --         if ready_in = '1' and valid_in = '1' then
    --             internal_message <= message;
    --             ready_in <= '0';
    --             message_received <= '1';
    --         elsif message_received = '0' then
    --             ready_in <= '1';
    --         end if; 
    --     end if;
    -- end process;