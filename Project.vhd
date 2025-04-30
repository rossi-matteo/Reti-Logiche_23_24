library ieee;
use ieee.std_logic_1164.all;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_done  : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture structural of project_reti_logiche is
    signal mux_data : std_logic_vector(7 downto 0);
    signal register_data : std_logic_vector(7 downto 0);
    signal data_mux_control : std_logic;
    signal addr_ctrl : std_logic;
    signal data_ctrl : std_logic;
    signal data_addr : std_logic_vector(15 downto 0);
    signal credibility_addr : std_logic_vector(15 downto 0);
    signal current_k : std_logic_vector(9 downto 0);
    signal current_k_bit_extended : std_logic_vector(15 downto 0);
    signal current_value_done : std_logic;
    signal credibility_data : std_logic_vector(7 downto 0);
    signal done : std_logic;
    signal register_ctrl : std_logic;

     component parallel_parallel_register is
         generic ( N: integer := 8); 
              port(    
                 in1 : in std_logic_vector(N-1 downto 0);
                 clk, rst, start: in std_logic;
                 out1 : out std_logic_vector(N-1 downto 0)
              );
     end component;
     
     component mux is 
         generic ( N: integer );
         port(
           in1, in2 : in std_logic_vector(N-1 downto 0);
           ctrl: in std_logic;
           out1 : out std_logic_vector(N-1 downto 0)
          );
     end component;
     
     component adder is
       generic ( N: integer := 16); 
       port(
         in1, in2: in std_logic_vector(N-1 downto 0);
         out1 : out std_logic_vector(N-1 downto 0)
       );
     end component;
     
     component k_counter is
         port(
             i_current_value_done: in std_logic;
             i_start: in std_logic;
             i_clk: in std_logic;
             i_rst: in std_logic;
             o_current_k: out std_logic_vector(9 downto 0)
         );
     end component;
     
     component fsm_state_control is
       port(
           in_update:  in std_logic;
           i_start: in std_logic;
           k_module_end: in std_logic;
           clk:  in std_logic;
           rst:  in std_logic;
           o_data_credibility: out std_logic_vector(7 downto 0);
           o_data_ctrl: out std_logic;
           o_addr_ctrl: out std_logic;
           o_register_ctrl: out std_logic;
           o_curr_value_done: out std_logic;
           o_mem_en: out std_logic;
           o_mem_we: out std_logic;
           o_done: out std_logic
       );
     end component;
     
     begin
        data_mux : mux
            generic map(8)
            port map(in1 => register_data, in2 => i_mem_data, ctrl => register_ctrl, out1 => mux_data);
                    
        data_mux_control <= '0' when i_mem_data = "00000000" else '1';
   
        data_register : parallel_parallel_register
            port map(in1 => mux_data, clk => i_clk, rst => i_rst, start => i_start, out1 => register_data);   
        
        mem_addr_mux : mux
            generic map(16)
            port map(in1 => data_addr, in2 => credibility_addr, ctrl => addr_ctrl, out1 => o_mem_addr);
            
        mem_addr_adder : adder
            port map(in1 => i_add, in2 => current_k_bit_extended, out1 => data_addr);
            --DEVE ESSERE RADDOPPIATO IL VALORE DI CURRENT_K_BIT_EXTENDED
        current_k_bit_extended <= "00000" & current_k & "0";
            
        credibility_addr_adder : adder
        port map(in1 => data_addr, in2 => "0000000000000001", out1 => credibility_addr);

        mem_data_mux : mux
            generic map(8)
            port map(in1 => register_data, in2 => credibility_data, ctrl => data_ctrl, out1 => o_mem_data);
            
        k_counter_module : k_counter
            port map(i_current_value_done => current_value_done, i_start => i_start, i_clk => i_clk, i_rst => i_rst, o_current_k => current_k);
            
        done <= '1' when current_k = i_k else '0';
        
        fsm_controller : fsm_state_control
            port map( in_update => data_mux_control,
                      i_start => i_start,
                      k_module_end => done,
                      clk => i_clk,
                      rst => i_rst,
                      o_data_credibility => credibility_data,
                      o_data_ctrl => data_ctrl,
                      o_addr_ctrl => addr_ctrl,
                      o_register_ctrl => register_ctrl,
                      o_curr_value_done => current_value_done,
                      o_mem_en => o_mem_en,
                      o_mem_we => o_mem_we,
                      o_done => o_done
            );

end structural;

---------------------------------------------------------------
-- MUX with Generic N bit Operands
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mux is 
    generic ( N: integer );
    port(
      in1, in2 : in std_logic_vector(N-1 downto 0);
      ctrl: in std_logic;
      out1 : out std_logic_vector(N-1 downto 0)
     );
end mux;

architecture dataflow of mux is
begin
  out1 <= in1 when ctrl = '0' else 
          in2;       
end dataflow;


---------------------------------------------------------------
-- PARALLEL-PARALLEL Register N bit
---------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity parallel_parallel_register is
     generic ( N: integer := 8); 
     port(	
        in1 : in std_logic_vector(N-1 downto 0);
	    clk, rst : in std_logic;
	    start: in std_logic;
	    out1 : out std_logic_vector(N-1 downto 0)
     );
end parallel_parallel_register;

architecture behavioral of parallel_parallel_register is
begin
  process(clk, rst, start)
  begin
    if rst = '1' or start = '0' then
      out1 <= (others => '0');
    elsif rising_edge(clk) then 
      out1 <= in1;
    end if;
  end process;	
end behavioral;


---------------------------------------------------------------
-- Adder 2 Operands N bit  -- Check Overflow per eventuali Testbench?
---------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adder is
  generic ( N: integer := 16); 
  port(
    in1, in2: in std_logic_vector(N-1 downto 0);
    out1 : out std_logic_vector(N-1 downto 0)
  );
end adder;

architecture dataflow of adder is
  signal sum : SIGNED(N-1 downto 0);
  signal msb : std_logic;
begin
  sum <=  SIGNED(in1) + SIGNED(in2);
  out1 <= std_logic_vector(sum);
  msb <= std_logic(sum(N-1)); 
end dataflow;

---------------------------------------------------------------
-- k_counter Module (10 Bit)
---------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity k_counter is
    port(
        i_current_value_done: in std_logic;
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        o_current_k: out std_logic_vector(9 downto 0)
    );
end k_counter;

architecture structural of k_counter is

    component parallel_parallel_register is
         generic ( N: integer := 8); 
         port(	
            in1 : in std_logic_vector(N-1 downto 0);
            clk, rst, start : in std_logic;
            out1 : out std_logic_vector(N-1 downto 0)
         );
    end component;
    
    signal sig_out_current_k : std_logic_vector(9 downto 0);
    signal current_k : std_logic_vector(9 downto 0);

    begin 
        k_register : parallel_parallel_register
        generic map(10)
        port map(in1 => current_k,
                 clk => i_clk,
                 rst => i_rst,
                 start => i_start,
                 out1 => sig_out_current_k
                 );  
                 
        o_current_k <= sig_out_current_k;  
		
        current_k <= (others => '0') when (i_start = '0' or i_rst = '1')
                                     else std_logic_vector( unsigned(sig_out_current_k) + 1) when (i_current_value_done = '1' and unsigned(sig_out_current_k) /= 1023) 
                                     else sig_out_current_k;  
        
end structural;

---------------------------------------------------------------
-- FSM_state_control
---------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_state_control is
  port(
      in_update:  in std_logic;
      i_start: in std_logic;
      k_module_end: in std_logic;
      clk:  in std_logic;
      rst:  in std_logic;
      o_data_credibility: out std_logic_vector(7 downto 0);
      o_data_ctrl: out std_logic;
      o_addr_ctrl: out std_logic;
      o_register_ctrl : out std_logic;
      o_curr_value_done: out std_logic;
      o_mem_en: out std_logic;
      o_mem_we: out std_logic;
      o_done: out std_logic
  );
end fsm_state_control;

architecture FSM of fsm_state_control is
  type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8);
  -- SO: IDLE (init) - RST
  -- S1: REQ_MEM_READ_VALUE
  -- S2: MEM_READ_VALUE
  -- S3: UPDATE_REGISTER_VALUE
  -- S4: UPDATE_CREDIBILITY_REGISTER
  -- S5: MEM_WRITE_DATA
  -- S6: MEM_WRITE_CREDIBILITY
  -- S7: UPDATE_K_REGISTER
  -- S8: DONE
  signal credibility_counter : std_logic_vector(4 downto 0);
  signal sig_credibility_value : std_logic_vector(4 downto 0);
  signal next_state, current_state: state_type;
  
  component parallel_parallel_register is
           generic ( N: integer := 8); 
           port(    
              in1 : in std_logic_vector(N-1 downto 0);
              clk, rst, start: in std_logic;
              out1 : out std_logic_vector(N-1 downto 0)
           );
      end component;
      
begin
credibility_counter_register : parallel_parallel_register
    generic map(5)
    port map(in1 => credibility_counter,
             clk => clk,
             rst => rst,
             start => i_start,
             out1 => sig_credibility_value
             );  

  state_reg: process(clk, rst)
  begin
    if rst='1' then
      current_state <= S0;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;
  
  delta: process(current_state, i_start, k_module_end, in_update)
  begin
    case current_state is
      when S0 =>
        if i_start='1' then
          next_state <= S1;
        else
          next_state <= S0;
        end if;
      when S1 =>
          if k_module_end = '1' then
          next_state <= S8; --Early Termination Condition if i_k = 0
          else
          next_state <= S2;
          end if;
      when S2 => 
          next_state <= S3;
      when S3 =>
          next_state <= S4;
      when S4 =>
        if in_update = '1' then
          next_state <= S6;
        else
          next_state <= S5;
        end if;
      when S5 =>
          next_state <= S6;
      when S6 =>
          next_state <= S7;          
      when S7 =>
          if k_module_end = '1' then
            next_state <= S8;
          else
            next_state <= S1;
          end if;
      when S8 =>
          if i_start = '1' then
            next_state <= S8;
          else
            next_state <= S0;
          end if;  
    end case;
  end process;

  lambda: process(current_state, in_update)
  begin
    case current_state is
      when S0 => --IDLE(init) - RST
        credibility_counter <= "00000";
        o_data_credibility <= "00000000";
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '0';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';
        o_done <= '0';
      when S1 => --REQ_MEM_READ_VALUE
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '1';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';
        o_done <= '0';
      when S2 => --MEM_READ_VALUE
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '0';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';
        o_done <= '0';
      when S3 => --UPDATE_REGISTER_VALUE
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= in_update;
        o_mem_en    <= '0';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';
        o_done <= '0';
      when S4 => --UPDATE_CREDIBILITY_REGISTER
      
        if in_update = '1' then --Timing Loop?
            credibility_counter <= "11111";
        elsif in_update = '0' and sig_credibility_value /= "00000" then
           credibility_counter <= std_logic_vector(unsigned(sig_credibility_value) - 1);
        else 
            credibility_counter <= "00000";
        end if;
        
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '0';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';
        o_done <= '0';
      when S5 => --MEM_WRITE_DATA
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '1';
        o_mem_we    <= '1';
        o_curr_value_done <= '0';   
        o_done <= '0'; 
      when S6 => --MEM_WRITE_CREDIBILITY
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '1';
        o_addr_ctrl <= '1';
        o_register_ctrl <= '0';
        o_mem_en    <= '1';
        o_mem_we    <= '1';
        o_curr_value_done <= '1'; 
        o_done <= '0';
      when S7 =>  --UPDATE_K_REGISTER
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '0';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';  
        o_done <= '0';
      when S8 => --DONE
        credibility_counter <= sig_credibility_value;
        o_data_credibility <= "000" & sig_credibility_value;
        o_data_ctrl <= '0';
        o_addr_ctrl <= '0';
        o_register_ctrl <= '0';
        o_mem_en    <= '0';
        o_mem_we    <= '0';
        o_curr_value_done <= '0';  
        o_done <= '1';                                      
    end case;
  end process;                                       
end FSM;