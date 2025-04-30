-- TB EXAMPLE PFRL 2023-2024

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity start_after_done_no_rst is
end start_after_done_no_rst;

architecture project_tb_arch of start_after_done_no_rst is
    constant CLOCK_PERIOD : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);
    signal tb_k   : std_logic_vector(9 downto 0);

    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;

    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

    constant SCENARIO_LENGTH_1 : integer := 10;
	constant SCENARIO_LENGTH_2 : integer := 35;
	constant SCENARIO_LENGTH_3 : integer := 33;
	constant SCENARIO_LENGTH_4 : integer := 10;
	constant SCENARIO_LENGTH_5 : integer := 16;
    type scenario_type_1 is array (0 to SCENARIO_LENGTH_1*2-1) of integer;
	type scenario_type_2 is array (0 to SCENARIO_LENGTH_2*2-1) of integer;
	type scenario_type_3 is array (0 to SCENARIO_LENGTH_3*2-1) of integer;
	type scenario_type_4 is array (0 to SCENARIO_LENGTH_4*2-1) of integer;
	type scenario_type_5 is array (0 to SCENARIO_LENGTH_5*2-1) of integer;

	signal scenario_input_1 : scenario_type_1 := (51, 0, 0, 0, 57, 0, 24, 0, 0, 0, 0, 0, 126, 0, 0, 0, 192, 0, 0, 0);
    signal scenario_full_1  : scenario_type_1 := (51, 31, 51, 30, 57, 31, 24, 31, 24, 30, 24, 29, 126, 31, 126, 30, 192, 31, 192, 30);
	signal scenario_input_2 : scenario_type_2 := (51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    signal scenario_full_2  : scenario_type_2 := (51, 31, 51, 30, 51, 29, 51, 28, 51, 27, 51, 26, 51, 25, 51, 24, 51, 23, 51, 22, 51, 21, 51, 20, 51, 19, 51, 18, 51, 17, 51, 16, 51, 15, 51, 14, 51, 13, 51, 12, 51, 11, 51, 10, 51, 9, 51, 8, 51, 7, 51, 6, 51, 5, 51, 4, 51, 3, 51, 2, 51, 1, 51, 0, 51, 0, 51, 0, 51, 0);
    signal scenario_input_3 : scenario_type_3 := (0, 0, 255, 0, 0, 0, 0, 0, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111, 0, 0, 0, 0, 0, 0, 0, 181, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 246, 0, 124, 0, 0, 0, 93, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    signal scenario_full_3  : scenario_type_3 := (0, 0, 255, 31, 255, 30, 255, 29, 137, 31, 137, 30, 137, 29, 137, 28, 137, 27, 137, 26, 137, 25, 137, 24, 137, 23, 111, 31, 111, 30, 111, 29, 111, 28, 181, 31, 181, 30, 181, 29, 181, 28, 181, 27, 181, 26, 246, 31, 124, 31, 124, 30, 93, 31, 93, 30, 93, 29, 93, 28, 93, 27, 93, 26, 93, 25);
	signal scenario_input_4 : scenario_type_4 := (255, 0, 0, 0, 0, 0, 143, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
    signal scenario_full_4  : scenario_type_4 := (255, 31, 255, 30, 255, 29, 143, 31, 143, 30, 143, 29, 143, 28, 143, 27, 143, 26, 143, 25);
	signal scenario_input_5 : scenario_type_5 := (255, 0, 91, 0, 161, 0, 155, 0, 178, 0, 11, 0, 83, 0, 27, 0, 57, 0, 129, 0, 39, 0, 243, 0, 158, 0, 173, 0, 134, 0, 58, 0);
    signal scenario_full_5  : scenario_type_5 := (255, 31, 91, 31, 161, 31, 155, 31, 178, 31, 11, 31, 83, 31, 27, 31, 57, 31, 129, 31, 39, 31, 243, 31, 158, 31, 173, 31, 134, 31, 58, 31);
	
    signal memory_control : std_logic := '0';
    
    constant SCENARIO_ADDRESS_1 : integer := 100;
	constant SCENARIO_ADDRESS_2 : integer := 1000;
	constant SCENARIO_ADDRESS_3 : integer := 532;
	constant SCENARIO_ADDRESS_4 : integer := 19;
	constant SCENARIO_ADDRESS_5 : integer := 944;

    component project_reti_logiche is
        port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
    UUT : project_reti_logiche
    port map(
                i_clk   => tb_clk,
                i_rst   => tb_rst,
                i_start => tb_start,
                i_add   => tb_add,
                i_k     => tb_k,
                
                o_done => tb_done,
                
                o_mem_addr => exc_o_mem_addr,
                i_mem_data => tb_i_mem_data,
                o_mem_data => exc_o_mem_data,
                o_mem_we   => exc_o_mem_we,
                o_mem_en   => exc_o_mem_en
    );

    -- Clock generation
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Process related to the memory
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                    init_o_mem_en,  init_o_mem_we,   exc_o_mem_addr,
                                    exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        -- This is necessary for the testbench to work: we swap the memory
        -- signals from the component to the testbench when needed.
    
        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en   <= init_o_mem_en;
        tb_o_mem_we   <= init_o_mem_we;

        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en   <= exc_o_mem_en;
            tb_o_mem_we   <= exc_o_mem_we;
        end if;
    end process;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    create_scenario : process
    begin
        wait for 50 ns;

        -- Signal initialization and reset of the component
        tb_start <= '0';
        tb_add <= (others=>'0');
        tb_k   <= (others=>'0');
        tb_rst <= '1';
        
        -- Wait some time for the component to reset...
        wait for 50 ns;
        
        tb_rst <= '0';
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        for i in 0 to SCENARIO_LENGTH_1*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_1+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_1(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
		
		for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_2(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
		
		for i in 0 to SCENARIO_LENGTH_3*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_3(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
		
		for i in 0 to SCENARIO_LENGTH_4*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_4+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_4(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
		
		for i in 0 to SCENARIO_LENGTH_5*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_5+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_5(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_1, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_1, 10));
        
        tb_start <= '1';
		
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		
		wait for 5 ns;
        
        tb_start <= '0';
        
        wait for 20 ns;
		
		tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_2, 10));
        
        tb_start <= '1';
		
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		
		wait for 5 ns;
        
        tb_start <= '0';
        
        wait for 20 ns;
		
		tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_3, 10));
        
        tb_start <= '1';
		
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		
		wait for 5 ns;
        
        tb_start <= '0';
        
        wait for 20 ns;
		
		tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_4, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_4, 10));
        
        tb_start <= '1';
		
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		
		wait for 5 ns;
        
        tb_start <= '0';
        
        wait for 20 ns;
		
		tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_5, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_5, 10));
        
        tb_start <= '1';
		
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		
		wait for 5 ns;
        
        tb_start <= '0';

        wait;
        
    end process;

    -- Process without sensitivity list designed to test the actual component.
    test_routine : process
    begin

        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
        wait until tb_rst = '0';

        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        
        wait until rising_edge(tb_start);
		
		while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_1*2-1 loop
            assert RAM(SCENARIO_ADDRESS_1+i) = std_logic_vector(to_unsigned(scenario_full_1(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_1(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_1+i)))) severity failure;
        end loop;
		
		wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            assert RAM(SCENARIO_ADDRESS_2+i) = std_logic_vector(to_unsigned(scenario_full_2(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_2(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_2+i)))) severity failure;
        end loop;
		
		wait until rising_edge(tb_start);
		
		while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_3*2-1 loop
        end loop;
		
		wait until rising_edge(tb_start);
		
		while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_4*2-1 loop
            assert RAM(SCENARIO_ADDRESS_4+i) = std_logic_vector(to_unsigned(scenario_full_4(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_4(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_4+i)))) severity failure;
        end loop;
		
		wait until rising_edge(tb_start);
		
		while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_5*2-1 loop
            assert RAM(SCENARIO_ADDRESS_5+i) = std_logic_vector(to_unsigned(scenario_full_5(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_5(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_5+i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);

        assert false report "Simulation Ended! TEST PASSATO (EXAMPLE)" severity failure;
    end process;

end architecture;
