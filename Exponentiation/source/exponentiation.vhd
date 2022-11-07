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
		count                : out unsigned(7 downto 0);
        internal_message_out : out std_logic_vector(N - 1 downto 0)
	);
end entity;


architecture rtl of exponentiation is
    --type   multiplication_state_type is (single_multiplication, double_multiplication);
    type   message_state_type        is (idle, load_new_message);
    --signal multiplication_state       : multiplication_state_type := double_multiplication;
    --signal next_multiplication_state  : multiplication_state_type;
    signal message_state              : message_state_type               := idle;
    signal next_message_state         : message_state_type;
    signal internal_result            : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal factor_a                   : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal factor_b                   : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal start_condition            : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal multiplication_result      : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal multiplication_done        : std_logic;
    signal double_multiplication      : std_logic := '1';
    signal double_multiplication_done : std_logic := '0';
    signal counter                    : unsigned(7 downto 0) := (others => '1'); 
    signal internal_message           : std_logic_vector(255 downto 0);
    --signal load_new_message           : std_logic := '0';
    signal clear_multiplication_n     : std_logic := '0';
    --signal count_down_now             : std_logic := '0';
begin
    ----------------------------------------------------------------------------------
    -- Result changes when internal result changes on the rising edge of the clock
    ----------------------------------------------------------------------------------
    result <= internal_result;

    ----------------------------------------------------------------------------------
    -- These processes decides what values to send to the modular multiplier
    ----------------------------------------------------------------------------------
    factor_a        <= start_condition when counter = N - 1 else
                       internal_result;
    factor_b        <= internal_message when double_multiplication_done = '1' else
                       factor_a;
    start_condition <= internal_message when key(N - 1) = '1' else
                       std_logic_vector(to_unsigned(1, 256)); 

    ----------------------------------------------------------------------------------
    -- Desides whether to calculate a single or double multiplication
    ----------------------------------------------------------------------------------
    double_multiplication <= '1' when key(to_integer(counter)) = '1' else '0';

    ----------------------------------------------------------------------------------
    -- Valid result on falling edge of valid_out
    ----------------------------------------------------------------------------------
    valid_out <= '1' when counter = 0 else '0';

    ----------------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------------
    -- set_valid_out : process(counter) is
    -- begin
    --     valid_out <= '0';
    --     if counter = N - 1 and reset_n = '0' then
    --         valid_out <= '1';
    --     end if;
    -- end process;

    --------------------BLAKLEY CORE-------------------------------------
    
    M0: entity work.modular_multiplication 
        generic map (
            N => N
        )
        port map (
            factor_a => unsigned(factor_a), 
            factor_b => unsigned(factor_b), 
            std_logic_vector(result) => multiplication_result, 
            clk => clk, 
            reset_n => clear_multiplication_n, 
            modulus => unsigned(modulus), 
            valid_out => multiplication_done
        );
    
    --------------------SIGNAL MAPPING------------------------------------------------------
    

    --------------------DEBUGGING------------------------------------------------------
    internal_message_out <= internal_message;
    count                <= counter;


    ----------------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------------
    change_message_state : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            message_state <= idle;
        elsif rising_edge(clk) then
            message_state <= next_message_state;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------------
    message_state_machine : process(message_state, valid_in, counter, message) is
    begin
        case message_state is
            when idle =>
                if valid_in = '1' and counter = N - 1 then
                    ready_in           <= '1';
                    next_message_state <= load_new_message;
                else
                    ready_in           <= '0';
                    next_message_state <= idle;
                end if;
            when load_new_message =>
                ready_in           <= '0';
                internal_message   <= message; -- This makes a latch (by design)
                next_message_state <= idle; 
        end case;
    end process;

    ----------------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------------
    --change_multiplication_state : process(multiplication_done, reset_n) is
    --begin
    --    if reset_n = '0' then
    --        multiplication_state <= single_multiplication;
    --    elsif falling_edge(multiplication_done) then
    --        multiplication_state <= next_multiplication_state;
    --    end if;
    --end process;

    ----------------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------------
    --multiplication_state_machine : process(multiplication_state, double_multiplication) is
    --begin
    --    case multiplication_state is
    --        when single_multiplication =>
    --            if double_multiplication = '1' then
    --                next_multiplication_state <= double_multiplication;
    --            else
    --                next_multiplication_state <= single_multiplication;
    --            end if;
    --        when double_multiplication =>
    --            next_multiplication_state <= single_multiplication;
    --    end case;
    --end process;

    ----------------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------------
    --count_down : process(multiplication_done, double_multiplication, reset_n) is
    --begin
    --    if reset_n = '0' then
    --        counter <= (others => '1');
    --    elsif falling_edge(multiplication_done) and not double_multiplication then
    --        counter <= counter - 1;
    --    end if;
    --end process;

    process(multiplication_done, clk) is
    begin
        clear_multiplication_n <= '1';
        if falling_edge(multiplication_done) then
            clear_multiplication_n <= '0';
            internal_result <= multiplication_result;
            if double_multiplication = '1' and double_multiplication_done = '0' then
                double_multiplication_done <= '1';
            else
                counter <= counter - 1;
                double_multiplication_done <= '0';
            end if;
        end if;
    end process;
end architecture;

    ----------------------------------PROCESS CLK/RST-----------------------------------------NOT IN USE
    -- process(clk, reset_n) is
    -- begin
    --     if reset_n = '0' then
    --         internal_message <= (others => '0');
    --     elsif rising_edge(clk) then
    --         if ready_in = '1' and valid_in = '1' then
    --             internal_message <= message;
    --             ready_in <= '0';
    --             load_new_message <= '1';
    --         elsif load_new_message = '0' then
    --             ready_in <= '1';
    --         end if; 
    --     end if;
    -- end process;