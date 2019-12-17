
-------------------------------------------------------------------------------
--
-- FIB ADC-DAC App3
-- 
-- Used VHDL-Template for FIB Top
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.reset_gen_pkg.all;
use work.id_info_pkg.all;
use work.clk_divider_pkg.all;
use work.linear_function_interpolator_pkg.all;
use work.resize_tools_pkg.all;

--use work.inout_driver02_pkg.all;


entity fib_adcdac_app3_top is
  generic(
    no_of_tadi_channels            : integer                       := 3;   -- 1 for 100%,
    -- 2 for twice 50%,
    -- 3 for once 50% and twice 25%,
    -- 4 for 4 times 25%
    tadi_function_patten : std_logic_vector (1 downto 0) := "10";  -- channel
                                        -- direction selection:
    -- use 1 for up and 0 for down bit 1 for alpha und bit 2 for beta
    high_speed_high_low_swap        : boolean                       := true;
    clk_freq_in_hz       : real                          := 50.0E6;
    reset_clocks         : integer                       := 5000;
    firmware_id          : integer                       := 10;  --ID of the firmware (is displayed first)
    firmware_version     : integer                       := 5  --Version of the firmware (is displayed after)
    );

  port (
    --trigger signals
    trig1_in  : in  std_logic;
    trig2_out : out std_logic;
    trig1_out : out std_logic;
    trig2_in  : in  std_logic;

    --clk's
    clk0 : in std_logic;
    clk1 : in std_logic;

    --rf in
    hf1_in : in std_logic;
    hf2_in : in std_logic;

    --uC-Link signals
    uC_Link_D         : in  std_logic_vector(7 downto 0);  --dds_data
    uC_Link_A         : out std_logic_vector(7 downto 0);  --dds_addr
    nuC_Link_ACK_R    : in  std_logic;
    nuC_Link_ACK_W    : out std_logic;
    nuC_Link_MRQ_R    : in  std_logic;
    nuC_Link_MRQ_W    : out std_logic;
    nuC_Link_RnW_R    : in  std_logic;
    nuC_Link_RnW_W    : out std_logic;
    nuC_Link_STROBE_R : in  std_logic;
    nuC_Link_STROBE_W : out std_logic;

    --static uC-Link signals
    uC_Link_DIR_D, uC_Link_DIR_A : out std_logic;
    nuC_Link_EN_CTRL_A           : out std_logic;
    uC_Link_EN_DA                : out std_logic;

    --piggy signals
    Piggy_Clk1  : out std_logic;        --dds_clk
    Piggy_RnW1  : out std_logic;        --dds_wr
    Piggy_RnW2  : out std_logic;        --dds_vout_comp
    Piggy_Strb2 : out std_logic;        --dds_rst
    Piggy_Strb1 : out std_logic;        --dds_update_o
    Piggy_Ack1  : out std_logic;        --dds_fsk
    Piggy_Ack2  : out std_logic;        --dds_sh_key

    --backplane signals
    A2nSW8      : in  std_logic;
    A3nSW9      : in  std_logic;
    A0nSW10     : in  std_logic;
    A1nSW11     : in  std_logic;
    Sub_A0nIW6  : in  std_logic;
    Sub_A1nIW7  : in  std_logic;
    Sub_A2nIW4  : in  std_logic;
    Sub_A3nIW5  : in  std_logic;
    Sub_A4nSW14 : in  std_logic;
    Sub_A5nSW15 : in  std_logic;
    Sub_A6nSW12 : in  std_logic;
    Sub_A7nSW13 : in  std_logic;
    nResetnSW0  : in  std_logic;
    SW1         : in  std_logic;
    nDSnSW2     : in  std_logic;
    BClocknSW3  : in  std_logic;
    RnWnSW4     : in  std_logic;
    SW5         : in  std_logic;
    A4nSW6      : in  std_logic;
    SW7         : in  std_logic;
    NEWDATA     : in  std_logic;
    FC_Str      : in  std_logic;
    FC0         : in  std_logic;
    FC1         : in  std_logic;
    FC2         : in  std_logic;
    FC3         : in  std_logic;
    FC4         : in  std_logic;
    FC5         : in  std_logic;
    VG_A3nFC6   : in  std_logic;
    FC7         : in  std_logic;
    SD          : in  std_logic;
    nDRQ2       : out std_logic;

    VG_SK0nSWF6 : in std_logic;
    VG_SK1nSWF5 : in std_logic;
    VG_SK2nSWF4 : in std_logic;
    VG_SK3nSWF3 : in std_logic;
    VG_SK4nSWF2 : in std_logic;
    VG_SK5nSWF1 : in std_logic;
    VG_SK6nSWF0 : in std_logic;
    VG_SK7      : in std_logic;

    VG_ID0nRes  : in std_logic;
    VG_ID1nIW3  : in std_logic;
    VG_ID2nIW2  : in std_logic;
    VG_ID3nIW1  : in std_logic;
    VG_ID4nIW0  : in std_logic;
    VG_ID5      : in std_logic;
    VG_ID6      : in std_logic;
    VG_ID7nSWF7 : in std_logic;

    D0nIW14 : inout std_logic;
    D1nIW15 : inout std_logic;
    D2nIW12 : inout std_logic;
    D3nIW13 : inout std_logic;
    D4nIW10 : inout std_logic;
    D5nIW11 : inout std_logic;
    D6nIW8  : inout std_logic;
    D7nIW9  : inout std_logic;

    --static backplane-buffer signals
    BBA_DIR : out std_logic;
    BBB_DIR : out std_logic;
    BBC_DIR : out std_logic;
    BBD_DIR : out std_logic;
    BBE_DIR : out std_logic;
    BBG_DIR : out std_logic;
    BBH_DIR : out std_logic;
    nBB_EN  : out std_logic;

    --static backplane open-collector outputs
    DRDY     : out std_logic;
    SRQ3     : out std_logic;
    DRQ      : out std_logic;
    INTERL   : out std_logic;
    DTACK    : out std_logic;
    nDRDY2   : out std_logic;
    SEND_EN  : out std_logic;
    SEND_STR : out std_logic;

    --dsp-link signals (read)
    DSP_CRDY_W : out std_logic;
    DSP_CREQ_W : out std_logic;
    DSP_CACK_R : in  std_logic;
    DSP_CSTR_R : in  std_logic;

    DSP_D_R0 : in std_logic;
    DSP_D_R1 : in std_logic;
    DSP_D_R2 : in std_logic;
    DSP_D_R3 : in std_logic;
    DSP_D_R4 : in std_logic;
    DSP_D_R5 : in std_logic;
    DSP_D_R6 : in std_logic;
    DSP_D_R7 : in std_logic;

    --dsp-link signals (write)          
    DSP_CRDY_R : in  std_logic;
    DSP_CREQ_R : in  std_logic;
    DSP_CACK_W : out std_logic;
    DSP_CSTR_W : out std_logic;

    DSP_D_W0 : out std_logic;
    DSP_D_W1 : out std_logic;
    DSP_D_W2 : out std_logic;
    DSP_D_W3 : out std_logic;
    DSP_D_W4 : out std_logic;
    DSP_D_W5 : out std_logic;
    DSP_D_W6 : out std_logic;
    DSP_D_W7 : out std_logic;

    DSP_DIR_D      : out std_logic;
    DSP_DIR_STRACK : out std_logic;
    DSP_DIR_REQRDY : out std_logic;

    -- leds
    led1 : out std_logic;
    led2 : out std_logic;
    led3 : out std_logic;
    led4 : out std_logic;

    -- only for debug
    piggy_io : out std_logic_vector(7 downto 0);

    --adressing pins via FC
    VG_A4 : in std_logic;               --FC(0)
    VG_A1 : in std_logic;               --FC(1)
    VG_A2 : in std_logic;               --only modulbus 
    VG_A0 : in std_logic;               --only modulbus 

    --rs232
    rs232_rx_i : in  std_logic;
    rs232_tx_o : out std_logic;

    --flash device
    eeprom_data : in  std_logic;
    eeprom_dclk : out std_logic;
    eeprom_ncs  : out std_logic;
    eeprom_asdi : out std_logic;

    --Jumper:
    Testpin_J60 : out std_logic;

    --TCXO
    TCXO1_CNTRL : out std_logic;
    TCXO2_CNTRL : out std_logic;

    --mixed signal port
    nGPIO1_R  : in  std_logic;
    nGPIO1_W  : out std_logic;
    nGPIO2_R  : in  std_logic;
    nGPIO2_W  : out std_logic;
    nI2C_SCL  : out std_logic;
    nI2C_SDA  : out std_logic;
    nSPI_EN   : out std_logic;
    nSPI_MISO : in  std_logic;
    nSPI_MOSI : out std_logic;
    nSPI_SCK  : out std_logic;

    --optical links
    opt1_los : in  std_logic;
    opt1_rx  : in  std_logic;
    opt1_tx  : out std_logic;
    opt2_los : in  std_logic;
    opt2_rx  : in  std_logic;
    opt2_tx  : out std_logic
    );
end entity fib_adcdac_app3_top;

architecture arch_fib_adcdac_app3_top of fib_adcdac_app3_top is

  component fib_pll
    port (
      inclk0 : in  std_logic := '0';
      c0     : out std_logic;
      c1     : out std_logic;
      e0     : out std_logic);
  end component;

  constant ADR_CH1_LOW_BYTE  : std_logic_vector(3 downto 0) := "0000";
  constant ADR_CH1_HIGH_BYTE : std_logic_vector(3 downto 0) := "0001";
  constant ADR_CH2_LOW_BYTE  : std_logic_vector(3 downto 0) := "0010";
  constant ADR_CH2_HIGH_BYTE : std_logic_vector(3 downto 0) := "0011";

  -- common signals
  signal clk     : std_logic;
  signal rst     : std_logic;
  signal clk_lag : std_logic;
  signal pll_lag : std_logic;

  -- LED signals
  signal led_id_inf_i : std_logic_vector(3 downto 0);
  signal led_id_inf_o : std_logic_vector(3 downto 0);

  signal bus_alpha_to   : std_logic_vector (7 downto 0);
  signal bus_alpha_from : std_logic_vector (7 downto 0);

  signal bus_beta_to   : std_logic_vector (7 downto 0);
  signal bus_beta_from : std_logic_vector (7 downto 0);

--  signal internal_rnw_alpha_i : std_logic;
--  signal internal_rnw_beta_i  : std_logic;

  signal alpha_adr : std_logic_vector (3 downto 0);
  signal beta_adr  : std_logic_vector (3 downto 0);

  type short_state_type is (SHORT_HIGH, SHORT_LOW);
  signal short_state : short_state_type;
  signal lag_state   : short_state_type;

  signal data_from_adc              : std_logic_vector (13 downto 0);
  signal data_from_adc1             : std_logic_vector (13 downto 0);
  signal data_from_adc2             : std_logic_vector (13 downto 0);
  signal data_from_adc_synched      : std_logic_vector (13 downto 0);
  signal data_from_adc_synched_inv  : std_logic_vector (13 downto 0);
  signal data_from_adc1_synched     : std_logic_vector (13 downto 0);
  signal data_from_adc1_synched_inv : std_logic_vector (13 downto 0);
  signal data_from_adc2_synched     : std_logic_vector (13 downto 0);
  signal data_from_adc2_synched_inv : std_logic_vector (13 downto 0);

  signal data_to_dac : std_logic_vector (13 downto 0);

  signal data_to_dac_synched : std_logic_vector (13 downto 0);

  signal adr_alpha : std_logic_vector (3 downto 0);
  signal adr_beta  : std_logic_vector (3 downto 0);

  signal interpolator_data_i : std_logic_vector (13 downto 0);
  signal interpolator_data_o : std_logic_vector (13 downto 0);

  type major_byte_order_type is (HIGH_50, LOW_50);
  type minor_byte_order_type is (FIRST_25_HIGH, FIRST_25_LOW, SECOND_25_HIGH, SECOND_25_LOW);
  signal major_byte_order_state     : major_byte_order_type;
  signal minor_byte_order_state     : minor_byte_order_type;
  signal major_byte_order_lag_state : major_byte_order_type;
  signal minor_byte_order_lag_state : minor_byte_order_type;

begin

  fib_pll_1 : fib_pll
    port map (
      inclk0 => clk0,
      c0     => clk,
--      c1     => pll_lag,
      c1     => open,
      e0     => open);

--  clk <= hf1_in; clk <= clk0;
  
--  clk <= hf1_in;  
--  clk_lag <= clk when use_clock_lag = false else pll_lag;
  clk_lag <= clk;

  reset_gen_inst : reset_gen
    generic map(
      reset_clks => reset_clocks
      )
    port map (
--      clk_i => hf1_in,
      clk_i => clk0,
      rst_o => rst
      );

  id_info_inst : id_info
    generic map (
      clk_freq_in_hz     => 200.0E6,
      display_time_in_ms => 500.0,
      firmware_id        => firmware_id,
      firmware_version   => firmware_version,
      led_cnt            => 4
      )
    port map (
      clk_i => clk,
      rst_i => rst,
      led_i => led_id_inf_i,
      led_o => led_id_inf_o
      );

  blinker1 : clk_divider
    generic map (
      clk_divider_width => 24)
    port map (
      clk_div_i => x"EEFFFF",
      rst_i     => rst,
      clk_i     => clk,
      clk_o     => led_id_inf_i (3));


  linear_function_interpolator_inst : linear_function_interpolator
    generic map(
      interpolator_data_in_wordsize  => 14,
      interpolator_data_out_wordsize => 14,
      ram_adr_wordsize_a             => 11,
      ram_adr_wordsize_b             => 10,
      ram_dat_wordsize_a             => 8,
      ram_dat_wordsize_b             => 16,
      use_altera_lpm                 => false,
      interpolator_internal_wordsize => 14
      )
    port map (
      adr_a     => (others => '0'),
      dat_a     => (others => '0'),
      wren_a    => '0',
      q_a       => open,
      clk_a     => clk,
      clk_b     => clk,
      data_o    => interpolator_data_o,
      data_i    => interpolator_data_i,
      rst_i     => rst,
      end_value => (others => '0')
      );


  Testpin_J60 <= clk_lag;

  --led signal mapping
  led4 <= led_id_inf_o(0);
  led3 <= led_id_inf_o(1);
  led2 <= led_id_inf_o(2);
  led1 <= led_id_inf_o(3);

--  led_id_inf_i (0) <= '0';
--  led_id_inf_i (1) <= '1';
  led_id_inf_i (2) <= '0';

  --static backplane buffer settings
  BBA_DIR <= '0';
  BBB_DIR <= '0';
  BBC_DIR <= '0';
  BBD_DIR <= '0';
  BBE_DIR <= '0';
  BBG_DIR <= '0';
  BBH_DIR <= '0';
  nBB_EN  <= '1';                       --backplane buffers switched off!

  --static backplane open-collector output settings
  DRDY     <= '0';
  SRQ3     <= '0';
  DRQ      <= '0';
  INTERL   <= '0';
  DTACK    <= '0';
  nDRDY2   <= '0';
  SEND_EN  <= '0';
  SEND_STR <= '0';

  --static uC-Link buffer settings

  uC_Link_DIR_D      <= '0';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  uC_Link_DIR_A      <= '1';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  nuC_Link_EN_CTRL_A <= '1';            --EN: '1'=disabled, '0'=enabled
  uC_Link_EN_DA      <= '0';            --EN: '1'=disabled, '0'=enabled !!

  --static DSP-Link buffer settings
  DSP_D_W0 <= '0';
  DSP_D_W1 <= '0';
  DSP_D_W2 <= '0';
  DSP_D_W3 <= '0';
  DSP_D_W4 <= '0';
  DSP_D_W5 <= '0';
  DSP_D_W6 <= '0';
  DSP_D_W7 <= '0';

  --DSP-Link Direction:
  --DSP_DIR_D='1', DSP_DIR_STRACK='1', DSP_DIR_REQRDY='0' -> Dataflow *to* FPGA
  --DSP_DIR_D='0', DSP_DIR_STRACK='0', DSP_DIR_REQRDY='1' -> Dataflow *from* FPGA
  DSP_DIR_D      <= '1';                --DIR: '1'=to FPGA, '0'=from FPGA
  DSP_DIR_STRACK <= '1';                --DIR: '1'=to FPGA, '0'=from FPGA
  DSP_DIR_REQRDY <= '0';                --DIR: '1'=to FPGA, '0'=from FPGA

  -----------------------------------------------------------------------------

  Piggy_Ack1 <= '1';                    -- OE Signal von FAB

  Piggy_Clk1 <= clk;

  Piggy_Strb1 <= '1';
  Piggy_Strb2 <= '1';
--  internal_rnw_alpha_i <= '1';
--  internal_rnw_beta_i  <= '1';
  Piggy_RnW1  <= '0';                   -- alpha rnw
  Piggy_RnW2  <= '1';                   -- beta rnw

  Piggy_Ack2 <= not rst;                -- nRST signal von FAB

--
--  process(clk)
--  begin
--    if clk'event and clk = '1' then  -- rising clock edge
--      data_to_dac               <= data_from_adc_synched_inv;
--    end if;
--  end process;

--  process(clk)
--  begin
--    if clk'event and clk = '1' then  -- rising clock edge
--        if adr_alpha = "0000" then
--          adr_alpha <= "0001";
--        else
--          adr_alpha <= "0000";
--        end if;
--    end if;
--  end process;

  piggy_io (7 downto 4) <= adr_alpha;
  piggy_io (3 downto 0) <= adr_beta;

  -----------------------------------------------------------------------------

  once_100_percent_gen : if no_of_tadi_channels = 1 generate
  begin

  end generate once_100_percent_gen;

  -- **** **** **** **** --

  twice_50_percent_gen : if no_of_tadi_channels = 2 generate
  begin

    -----------------------------------------------------------------------------

    -- Interconnection

    data_from_adc_synched_inv <= data_from_adc_synched;

    -----------------------------------------------------------------------------

    p_short : process (clk, rst)
    begin  -- process p_send_mls
      if rst = '1' then                 -- asynchronous reset (active high)
        short_state         <= SHORT_LOW;
        adr_alpha           <= "0000";
        adr_beta            <= "0000";
        data_to_dac_synched <= (others => '0');
      elsif clk'event and clk = '1' then               -- rising clock edge
        case short_state is
          when SHORT_LOW =>
            uC_Link_A   <= data_to_dac_synched (7 downto 0);
            adr_alpha   <= "0000";
            adr_beta    <= "0000";
            short_state <= SHORT_HIGH;
          when SHORT_HIGH =>
            uC_Link_A(5 downto 0) <= data_to_dac_synched (13 downto 8);
            uC_Link_A(7 downto 6) <= (others => '0');  --(others => data_to_dac (13));
            adr_alpha             <= "0001";
            adr_beta              <= "0001";
            short_state           <= SHORT_LOW;
            data_to_dac_synched   <= data_to_dac;
          when others => null;
        end case;
      end if;
    end process p_short;

    p_lag : process (clk_lag, rst)
    begin  -- process p_send_mls
      if rst = '1' then                 -- asynchronous reset (active high)
        data_from_adc <= (others => '0');
        if high_speed_high_low_swap = true then
          lag_state     <= SHORT_LOW;
        else 
          lag_state     <= SHORT_HIGH;
        end if;
      elsif clk_lag'event and clk_lag = '1' then  -- rising clock edge
        case lag_state is
          when SHORT_LOW =>
            data_from_adc (7 downto 0) <= uC_Link_D;
            lag_state                  <= SHORT_HIGH;
          when SHORT_HIGH =>
            data_from_adc (13 downto 8) <= uC_Link_D(5 downto 0);
            data_from_adc_synched       <= data_from_adc;
            lag_state                   <= SHORT_LOW;
          when others => null;
        end case;
      end if;
    end process p_lag;

  end generate twice_50_percent_gen;

  -- **** **** **** **** --

  once_50_twice_25_percent_gen : if no_of_tadi_channels = 3 generate
  begin

--    data_from_adc1_synched_inv <= conv_std_logic_vector(-1 * conv_integer(data_from_adc1_synched), 14);
--    data_from_adc2_synched_inv <= conv_std_logic_vector(-1 * conv_integer(data_from_adc2_synched), 14);

--    data_to_dac <= std_logic_vector(signed(data_from_adc1_synched) + signed(data_from_adc2_synched));

    data_to_dac <= resize_to_msb_trunc(std_logic_vector(signed(data_from_adc1_synched) * signed(data_from_adc2_synched)),14);

--    data_to_dac <= std_logic_vector(signed(data_from_adc1_synched));
--    data_to_dac <= std_logic_vector(signed(data_from_adc2_synched));

--    p_dac : process (clk, rst)
--    begin  -- process p_send_mls
--      if rst = '1' then                   -- asynchronous reset (active high)
--        data_to_dac <= (others =>'0');
--      elsif clk'event and clk = '1' then  -- rising clock edge
--        data_to_dac <= std_logic_vector(to_signed(to_integer(signed(data_to_dac)) + 100, 14));
--      end if;
--    end process p_dac;

    p_short : process (clk, rst)
    begin  -- process p_send_mls
      if rst = '1' then                   -- asynchronous reset (active high)
        major_byte_order_state <= LOW_50;
        minor_byte_order_state <= FIRST_25_LOW;
        adr_alpha              <= "0000";
        adr_beta               <= "0000";
        data_to_dac_synched    <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge

        case minor_byte_order_state is
        when FIRST_25_LOW =>
          adr_beta               <= ADR_CH2_LOW_BYTE;
          minor_byte_order_state <= FIRST_25_HIGH;
        when FIRST_25_HIGH =>
          adr_beta               <= ADR_CH2_HIGH_BYTE;
          minor_byte_order_state <= SECOND_25_LOW;
        when SECOND_25_LOW =>
          adr_beta               <= ADR_CH1_LOW_BYTE;
          minor_byte_order_state <= SECOND_25_HIGH;
        when SECOND_25_HIGH =>
          adr_beta               <= ADR_CH1_HIGH_BYTE;
          minor_byte_order_state <= FIRST_25_LOW;
        end case;
        
        case major_byte_order_state is
          when LOW_50 =>
            uC_Link_A <= data_to_dac_synched (7 downto 0);
            adr_alpha <= ADR_CH1_LOW_BYTE;
            major_byte_order_state <= HIGH_50;
          when HIGH_50 =>
            uC_Link_A(5 downto 0) <= data_to_dac_synched (13 downto 8);
            uC_Link_A(7 downto 6) <= (others => '0');  --(others => data_to_dac (13));
            adr_alpha             <= ADR_CH1_HIGH_BYTE;
            data_to_dac_synched    <= data_to_dac;
            major_byte_order_state <= LOW_50;
          when others => null;
        end case;
      end if;
    end process p_short;

    p_lag : process (clk_lag, rst)
    begin  -- process p_send_mls
      if rst = '1' then                 -- asynchronous reset (active high)
        data_from_adc1             <= (others => '0');
        data_from_adc2             <= (others => '0');
        if high_speed_high_low_swap = true then
          minor_byte_order_lag_state <= SECOND_25_HIGH;
        else 
          minor_byte_order_lag_state <= FIRST_25_LOW;
        end if;
      elsif clk_lag'event and clk_lag = '1' then  -- rising clock edge
        case minor_byte_order_lag_state is
          when FIRST_25_LOW =>
            data_from_adc2_synched       <= data_from_adc2;
            data_from_adc1 (7 downto 0) <= uC_Link_D;
            minor_byte_order_lag_state  <= FIRST_25_HIGH;

          when FIRST_25_HIGH =>
            data_from_adc1 (13 downto 8) <= uC_Link_D(5 downto 0);
            data_from_adc2_synched       <= data_from_adc2;
            minor_byte_order_lag_state   <= SECOND_25_LOW;

          when SECOND_25_LOW =>
            data_from_adc1_synched       <= data_from_adc1;            
            data_from_adc2 (7 downto 0) <= uC_Link_D;
            minor_byte_order_lag_state  <= SECOND_25_HIGH;

          when SECOND_25_HIGH =>
            data_from_adc2 (13 downto 8) <= uC_Link_D(5 downto 0);
            minor_byte_order_lag_state   <= FIRST_25_LOW;
          when others => null;
        end case;
      end if;
    end process p_lag;

  end generate once_50_twice_25_percent_gen;
  -------------------------------------------------------------------------------
end architecture arch_fib_adcdac_app3_top;
