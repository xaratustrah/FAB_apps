library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity digital_short is
  generic (
    clk_freq_in_hz : real := 200000000.0;  --system clock frequency
    delay_in_ns    : real := 25.0);        -- 25.0

  port (
    rst_i : in std_logic;               -- reset in
    clk_i : in std_logic;               -- clock in

    rnw_o    : out std_logic;
    strobe_o : out std_logic;
    ack_i    : in  std_logic;

    ext_driver_dir : out std_logic;

    adr_o : out std_logic_vector (5 downto 0);

    en_write_to_bus : out std_logic;

    data_to_bus   : out std_logic_vector (15 downto 0);
    data_from_bus : in  std_logic_vector (15 downto 0)
    );

end digital_short;

architecture digital_short_arch of digital_short is

  --limits the integer to a minimal value of one (for timing counters)
  function limit_to_minimal_value(x : integer; min : integer) return integer is
  begin
    if x > min then
      return x;
    else
      return 1;
    end if;
  end limit_to_minimal_value;

  signal delay_in_ticks : integer := limit_to_minimal_value(integer(clk_freq_in_hz * delay_in_ns / 1000000000.0) - 2, 0);
-- 3 clock cycles are needed for the state machine

  constant FAB_ADC_ADR : std_logic_vector (5 downto 0) := "000011";  -- Address of the ADC2 channel
  constant FAB_DAC_ADR : std_logic_vector (5 downto 0) := "000100";  -- Address of the DAC1 channel

  signal delay_cnt : integer range 0 to delay_in_ticks;

  type state_type is (READ_PRE1_STATE, READ_PRE2_STATE, READ_PRE3_STATE, READ_STATE, WRITE_PRE1_STATE, WRITE_PRE2_STATE, WRITE_PRE3_STATE, WRITE_STATE, WAIT_STATE);  -- States

  signal state           : state_type;
  signal return_to_state : state_type;

  signal local_data : std_logic_vector (15 downto 0);  -- data read from or written to fab

begin  -- digital_short_arch


  -- purpose: Read from ADC on FAB and write it back in FAB's DAC

  process (clk_i, rst_i, ack_i, state)

  begin  -- process p_shorting

    if rst_i = '1' then                 -- asynchronous reset (active high)

      -- in reset case, all drivers as input
      strobe_o        <= '0';
      rnw_o           <= '1';
      en_write_to_bus <= '0';
      ext_driver_dir  <= '0';
      state           <= READ_PRE1_STATE;
      return_to_state <= READ_PRE1_STATE;
      delay_cnt       <= delay_in_ticks;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      case state is

        when READ_PRE1_STATE =>
          strobe_o        <= '0';
          en_write_to_bus <= '0';
          adr_o           <= FAB_ADC_ADR;
          state           <= READ_PRE2_STATE;

        when READ_PRE2_STATE =>
          ext_driver_dir <= '0';
          state          <= READ_PRE3_STATE;

        when READ_PRE3_STATE =>
          strobe_o        <= '1';
          rnw_o           <= '1';
          state           <= WAIT_STATE;
          return_to_state <= READ_STATE;
          
        when READ_STATE =>
          local_data <= data_from_bus;
          state      <= WRITE_PRE1_STATE;

        when WRITE_PRE1_STATE =>
          strobe_o <= '0';
          rnw_o    <= '0';
          adr_o    <= FAB_DAC_ADR;
          state    <= WRITE_PRE2_STATE;

        when WRITE_PRE2_STATE =>
          ext_driver_dir <= '1';
          state          <= WRITE_PRE3_STATE;
          
        when WRITE_PRE3_STATE =>
          en_write_to_bus <= '1';
          strobe_o        <= '1';
          state           <= WRITE_STATE;
          
        when WRITE_STATE =>
          data_to_bus     <= local_data;
          state           <= WAIT_STATE;
          return_to_state <= READ_PRE1_STATE;

        when WAIT_STATE =>
          if delay_cnt = 0 then
            state     <= return_to_state;
            delay_cnt <= delay_in_ticks;
          else
            delay_cnt <= delay_cnt - 1;
          end if;
          
        when others => null;
      end case;
      
    end if;
  end process;

end digital_short_arch;
