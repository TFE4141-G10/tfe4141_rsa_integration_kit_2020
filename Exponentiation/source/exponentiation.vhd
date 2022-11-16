library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	generic (
		C_BLOCK_SIZE : integer := 256
	);
	port (
		--input controll
		valid_in	: in  std_logic;
		ready_in	: out std_logic;

		--input data
		message 	: in  std_logic_vector(C_BLOCK_SIZE - 1 downto 0);
		key 		: in  std_logic_vector(C_BLOCK_SIZE - 1 downto 0);

		--ouput controll
		ready_out	: in  std_logic;
		valid_out	: out std_logic := '0';

		--output data
		result 		: out std_logic_vector(C_BLOCK_SIZE - 1 downto 0);

		--modulus
		modulus 	: in  std_logic_vector(C_BLOCK_SIZE - 1 downto 0);

		--utility
		clk 		: in  std_logic;
		reset_n 	: in  std_logic;
		--last controll
		last_message_in : in std_logic;
		last_message_out: out std_logic
	);
end entity;


architecture rtl of exponentiation is
    type   message_state_type        is (uninitialized, idle, load_new_message);
    signal message_state              : message_state_type                          := uninitialized;
    signal next_message_state         : message_state_type                          := uninitialized;
    signal internal_result            : std_logic_vector(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal factor_a                   : std_logic_vector(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal factor_b                   : std_logic_vector(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal start_condition            : std_logic_vector(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal multiplication_result      : std_logic_vector(C_BLOCK_SIZE - 1 downto 0) := (others => '0');
    signal multiplication_done        : std_logic;
    signal double_multiplication      : std_logic := '1';
    signal double_multiplication_done : std_logic := '0';
    signal counter                    : unsigned(7 downto 0) := (others => '1'); 
    signal internal_message           : std_logic_vector(255 downto 0);
    signal clear_multiplication_n     : std_logic := '0';
    signal internal_valid_out         : std_logic := '0';
    signal last_multiplication        : std_logic := '0';
    signal exponentiation_done        : std_logic := '0';
    signal result_sent_out            : std_logic := '0';
    signal internal_last_message_out  : std_logic := '0';
begin
    ----------------------------------------------------------------------------------
    -- A single multiplication core is used for both multiplication operations in the
    -- Blakley algorithm
    ----------------------------------------------------------------------------------    
    modular_multiplication_core: entity work.modular_multiplication 
        generic map (
            C_BLOCK_SIZE             => C_BLOCK_SIZE
        )
        port map (
            factor_a                 => unsigned(factor_a), 
            factor_b                 => unsigned(factor_b), 
            std_logic_vector(result) => multiplication_result, 
            clk                      => clk, 
            reset_n                  => clear_multiplication_n, 
            modulus                  => unsigned(modulus), 
            valid_out                => multiplication_done
        );
    
    ----------------------------------------------------------------------------------
    -- Result changes when internal result changes on the rising edge of the clock
    ----------------------------------------------------------------------------------
    result <= internal_result;
    
    ----------------------------------------------------------------------------------
    -- Valid result when counter wraps around to 255, and can be aquired during the
    -- whole 255 counter period. Need last_multiplication to not give valid_out in start
    ----------------------------------------------------------------------------------
    last_multiplication <= '1' when counter = 0 else '0';
    internal_valid_out  <= '1' when exponentiation_done = '1' and result_sent_out = '0' else '0';
    valid_out           <= internal_valid_out;

    check_if_exponentiation_done : process(last_multiplication, result_sent_out, internal_last_message_out) is
    begin
        if result_sent_out = '1' then
            exponentiation_done <= '0';
        elsif falling_edge(last_multiplication) then
            exponentiation_done <= '1';
            last_message_out    <= internal_last_message_out;
        end if;
    end process;

    detect_if_result_sent : process(clk, ready_out, internal_valid_out) is
    begin
        result_sent_out <= '0';
        if rising_edge(clk) and ready_out = '1' and internal_valid_out = '1' then
            result_sent_out <= '1';
        end if;
    end process;
 
    ----------------------------------------------------------------------------------
    -- These processes decides what values to send to the modular multiplier
    ----------------------------------------------------------------------------------
    factor_a        <= start_condition when counter = C_BLOCK_SIZE - 1 else
                       internal_result;
    factor_b        <= internal_message when double_multiplication_done = '1' else
                       factor_a;
    start_condition <= internal_message when key(C_BLOCK_SIZE - 1) = '1' else
                       std_logic_vector(to_unsigned(1, 256)); 

    ----------------------------------------------------------------------------------
    -- Desides whether to calculate a single or double multiplication
    ----------------------------------------------------------------------------------
    double_multiplication <= '1' when key(to_integer(counter)) = '1' else '0';

    ----------------------------------------------------------------------------------
    -- Changes message state every clock cycle
    ----------------------------------------------------------------------------------
    change_message_state : process(clk, reset_n) is
    begin
        if reset_n = '0' then
            message_state <= uninitialized;
        elsif rising_edge(clk) then
            message_state <= next_message_state;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    -- FSM for aquiring new message. It has three states:
    -- 1. Uninitialized: Used to initialize the core to a valid condition first time
    --    the core is used
    -- 2. Idle: Used when a calculation is underway and the core is not ready to accept
    --    a new message
    -- 3. Load new message: Used when the core is ready to accept a new message
    ----------------------------------------------------------------------------------
    message_state_machine : process(message_state, valid_in, internal_valid_out, internal_last_message_out, ready_out, message) is
    begin
        case message_state is
            when uninitialized =>
                if internal_last_message_out = '0' then
                    ready_in <= '1';
                end if;
                if valid_in = '1' then
                    internal_last_message_out <= last_message_in;
                    internal_message   <= message;
                    next_message_state <= idle;
                else
                    next_message_state <= uninitialized;
                end if;
            when idle =>
                ready_in <= '0';
                if valid_in = '1' and internal_valid_out = '1' then
                    next_message_state <= load_new_message;
                else
                    next_message_state <= idle;
                end if;
            when load_new_message =>

                if ready_out = '1' then
                    internal_message   <= message;
                    next_message_state <= uninitialized;
                else
                    next_message_state <= load_new_message;
                end if;
            when others =>
                ready_in           <= '0';
                next_message_state <= idle;
        end case;
    end process;

    -- DOES NOT WORK YET:
    -- message_state_machine : process(message_state, valid_in, internal_valid_out, ready_out, message) is
    --     begin
    --         case message_state is
    --             when uninitialized =>
    --                 if valid_in = '1' then
    --                     internal_last_message_out <= last_message_in;
    --                     internal_message   <= message;
    --                     next_message_state <= idle;
    --                 else
    --                     next_message_state <= uninitialized;
    --                 end if;
    --             when idle =>
    --                 if valid_in = '1' and internal_valid_out = '1' then
    --                     next_message_state <= load_new_message;
    --                 else
    --                     next_message_state <= idle;
    --                 end if;
    --             when load_new_message =>
    --                 if ready_out = '1' then
    --                     internal_message   <= message;
    --                     next_message_state <= uninitialized;
    --                 else
    --                     next_message_state <= load_new_message;
    --                 end if;
    --             when others =>
    --                 next_message_state <= idle;
    --         end case;
    --     end process;
    
    --     ready_in <= '1' when message_state = uninitialized and internal_last_message_out = '0' else '0';


    ----------------------------------------------------------------------------------
    -- FSM for the double multiplication. It has two states:
    -- 1. Single multiplication: Used when the counter is not at the position where
    --    a double multiplication is needed
    -- 2. Double multiplication: Used when the counter is at the position where a double
    --    multiplication is needed
    ----------------------------------------------------------------------------------
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