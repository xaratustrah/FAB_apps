-------------------------------------------------------------------------------
--
-- Test Programm barrier bucket signal gerenrator.
-- S. Sanjari
-- 
-------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.reset_gen_pkg.all;
use work.clk_divider_pkg.all;
use work.sawtooth_pkg.all;
use work.fub_multi_spi_master_pkg.all;
use work.fub_vga_pkg.all;
use work.fub_mux_2_to_1_pkg.all;

use work.fub_mls_tx_pkg.all;
use work.dds_synthesizer_pkg.all;
use work.fub_io_expander_pkg.all;
use work.seq_reset_gen_pkg.all;

use work.localtypes.all;
use work.sine_lut_bbsg_pkg.all;

entity fab_bbsg_top is

  generic(
    function_generator    : integer                          := BBS_GEN;
    vga_default_gain      : std_logic_vector (3 downto 0)    := "0001";
    spi_clk_perid_in_ns   : real                             := 1000.0;
    spi_setup_delay_in_ns : real                             := 1000.0;
    -- default value is x"1100", 11 for setting the switches and 00 for
    -- switching all converters on
    default_io_data       : std_logic_vector(15 downto 0)    := x"1100";
    default_setup_data    : std_logic_vector (64-1 downto 0) := x"0A200B20000001C3";
    reset_clks            : integer                          := 20;
    clk_freq_in_hz        : real                             := 500.0E6);

  port (

--clk's

    hf_clk_i    : in  std_logic;
    hdc_clk_i   : in  std_logic;
    xco_clk_i   : in  std_logic;
    piggy_clk_o : out std_logic;
    piggy_clk_i : in  std_logic;


-- ram signals

    ramd : inout std_logic_vector (15 downto 0);
    rama : out   std_ulogic_vector (18 downto 0);

    ram_nwe  : out std_logic;
    ram_nlub : out std_logic;

-- SPI signals

    spi_sclk : out std_logic;
    spi_mosi : out std_logic;
    spi_miso : in  std_logic;

    ncs_expander : out std_logic;
    ncs_eeprom   : out std_logic;
    ncs_vga1     : out std_logic;
    ncs_vga2     : out std_logic;

    -- adc and dac signals

    adc1d : in  std_logic_vector (13 downto 0);
    adc2d : in  std_logic_vector (13 downto 0);
    dac1d : out std_logic_vector (13 downto 0);
    dac2d : out std_logic_vector (13 downto 0);

    adc1clk : out std_logic;
    adc2clk : out std_logic;

    dac1clk : out std_logic;
    dac2clk : out std_logic;

-- High density connector signals

    hdc_diff1n_io : out std_logic;
    hdc_diff1p_io : out std_logic;
    hdc_diff2n_io : out std_logic;
    hdc_diff2p_io : out std_logic;
    hdc_diff3n_io : out std_logic;
    hdc_diff3p_io : out std_logic;
    hdc_diff4n_io : out std_logic;
    hdc_diff4p_io : out std_logic;
    hdc_diff5n_io : out std_logic;
    hdc_diff5p_io : out std_logic;

-- Piggy Connector

    dat_alpha_i  : in  std_logic_vector (7 downto 0);
    adr_alpha_i  : in  std_logic_vector (4 downto 0);
    str_alpha_i  : in  std_logic;
    busy_alpha_o : out std_logic;

    dat_beta_o  : inout std_logic_vector (7 downto 0);
    adr_beta_o  : in    std_logic_vector (4 downto 0);
    str_beta_o  : in    std_logic;
    busy_beta_i : in    std_logic;

    ucl_rnw                : in  std_logic;
    ucl_str                : in  std_logic;
    piggy_rst_o            : out std_logic;
    ucl_ack_fpga_init_conf : out std_logic

    );


end fab_bbsg_top;

architecture fab_bbsg_top_arch of fab_bbsg_top is
  -- internal components

  component pll0
    port (
      inclk0 : in  std_logic := '0';
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic);
  end component;

  --internal variables

  constant clk_divider_width_toplevel : integer := 16;

  signal global_rst : std_logic;        -- internal global reset signal

  signal por_rst : std_logic;           -- signal from the POR generator

  signal dac1clk_local : std_logic;     -- local dac1clk for writing to it.
  signal dac2clk_local : std_logic;     -- local dac2clk for writing to it.


  signal clk100 : std_logic;
  signal clk200 : std_logic;
  signal clk500 : std_logic;
  signal clk    : std_logic;

  signal mosi : std_logic;
  signal miso : std_logic;
  signal sclk : std_logic;
  signal ss   : std_logic_vector (9 downto 0);

  signal str_for_vga1 : std_logic;
  signal str_for_vga2 : std_logic;

  -- internal FUB connections

  constant width_for_spi_fub : integer := 3;  -- berechnet sich aus der
                                              -- Anzahl der Vorhandenen SPI Teilnehmer

  signal fubA_data : std_logic_vector (7 downto 0);
  signal fubA_addr : std_logic_vector (width_for_spi_fub - 1 downto 0);
  signal fubA_strb : std_logic;
  signal fubA_busy : std_logic;

  signal fubB_data : std_logic_vector (7 downto 0);
  signal fubB_addr : std_logic_vector (width_for_spi_fub - 1 downto 0);
  signal fubB_strb : std_logic;
  signal fubB_busy : std_logic;

  signal fubC_data : std_logic_vector (7 downto 0);
  signal fubC_addr : std_logic_vector (width_for_spi_fub - 1 downto 0);
  signal fubC_strb : std_logic;
  signal fubC_busy : std_logic;

  signal fubD_data : std_logic_vector (7 downto 0);
  signal fubD_addr : std_logic_vector (width_for_spi_fub - 1 downto 0);
  signal fubD_strb : std_logic;
  signal fubD_busy : std_logic;

  signal fubE_data : std_logic_vector (7 downto 0);
  signal fubE_addr : std_logic_vector (width_for_spi_fub - 1 downto 0);
  signal fubE_strb : std_logic;
  signal fubE_busy : std_logic;

  signal vga1_gain : std_logic_vector (3 downto 0);
  signal vga1_strb : std_logic;
  signal vga1_busy : std_logic;


  signal vga2_gain : std_logic_vector (3 downto 0);
  signal vga2_strb : std_logic;
  signal vga2_busy : std_logic;

  signal vga1_counter : integer range 0 to 15;
  signal vga2_counter : integer range 0 to 15;

  signal adc1clk_local : std_logic;
  signal adc2clk_local : std_logic;


  type mls_state_type is (MLS_HIGH, MLS_LOW);
  signal mls_state  : mls_state_type;
  signal mls_data_o : std_logic_vector (7 downto 0);
  signal ftw        : std_logic_vector(13 downto 0);
  signal dds_data   : std_logic_vector (13 downto 0);
  signal dds_phase  : std_logic_vector (13 downto 0);
  signal dac_data   : std_logic_vector (13 downto 0);

  signal io_expander_data : std_logic_vector (15 downto 0);
  signal io_expander_str  : std_logic;
  signal io_expander_busy : std_logic;

  signal adc1sw   : std_logic_vector (3 downto 0);
  signal adc2sw   : std_logic_vector (3 downto 0);
  signal adc1of   : std_logic;
  signal adc2of   : std_logic;
  signal adc1shdn : std_logic;
  signal adc2shdn : std_logic;
  signal dac1slp  : std_logic;
  signal dac2slp  : std_logic;
  signal hdc_io0  : std_logic;
  signal hdc_io1  : std_logic;

  signal seq_reset    : std_logic_vector (2 downto 0);
  signal vga1_rst     : std_logic;
  signal vga2_rst     : std_logic;
  signal expander_rst : std_logic;

  type bbsg_state_type is (WAIT_FOR_TRIGGER, WAIT_SETUP_TIME, SEND_PULSE);
  signal bbsg_state1, bbsg_state2 : bbsg_state_type;

  constant BBSG_VAL_MAX                   : integer := NO_OF_POINTS + 1;
  signal bbsg_val_cnt1, bbsg_val_cnt2     : integer range 0 to BBSG_VAL_MAX;
  signal bbsg_pulse_cnt1, bbsg_pulse_cnt2 : integer range 0 to 3;
  signal bbsg_trigger1, bbsg_trigger2     : std_logic;
  signal auto_trigger1, auto_trigger2     : std_logic;

begin

  -- component instances

  pll0_1 : pll0
    port map (
      inclk0 => xco_clk_i,
      c0     => clk100,
      c1     => clk200,
      c2     => clk500);

  reset_gen_inst : reset_gen
    generic map (
      reset_clks => reset_clks)

    port map (
      clk_i => xco_clk_i,
      rst_o => por_rst);

  adc1_clk_divider_inst : clk_divider
    generic map (
      clk_divider_width => clk_divider_width_toplevel)

    port map (
      clk_div_i => x"0005",
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => adc1clk_local);

  adc2_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width_toplevel)

    port map (
      clk_div_i => x"0005",
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => adc2clk_local);

  vga1_update : clk_divider
    generic map (
      clk_divider_width => 24)
    port map (
      clk_div_i => x"4FFFFF",
--      clk_div_i => x"00000F",
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => str_for_vga1);

  vga2_udpate : clk_divider
    generic map (
      clk_divider_width => 24)
    port map (
      clk_div_i => x"7FFFFF",
--      clk_div_i => x"000009",
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => str_for_vga2);

  fub_multi_spi_master_1 : fub_multi_spi_master
    generic map (
      clk_freq_in_hz        => clk_freq_in_hz,
      spi_clk_perid_in_ns   => spi_clk_perid_in_ns,
      spi_setup_delay_in_ns => spi_setup_delay_in_ns,
      slave0_byte_count     => 1,
      slave1_byte_count     => 3,
      slave2_byte_count     => 1,
      slave3_byte_count     => 0,
      slave4_byte_count     => 0,
      slave5_byte_count     => 0,
      slave6_byte_count     => 0,
      slave7_byte_count     => 0,
      slave8_byte_count     => 0,
      slave9_byte_count     => 0,
      data_width            => 8)
    port map (
      clk_i       => clk,
      rst_i       => global_rst,
      fub_str_i   => fubA_strb,
      fub_busy_o  => fubA_busy,
      fub_data_i  => fubA_data,
      fub_addr_i  => fubA_addr,
      fub_error_o => open,
      fub_str_o   => open,
      fub_busy_i  => '0',
      fub_data_o  => open,
      spi_mosi_o  => mosi,
      spi_miso_i  => miso,
      spi_clk_o   => sclk,
      spi_ss_o    => ss);

  fub_io_expander_inst : fub_io_expander
    generic map (
      default_io_data    => default_io_data,
      default_setup_data => default_setup_data,
      spi_address        => 1,
      fub_addr_width     => width_for_spi_fub,
      fub_data_width     => 8)
    port map (
      clk_i              => clk,
      rst_i              => expander_rst,
      io_expander_data_i => io_expander_data,
      io_expander_str_i  => io_expander_str,
      io_expander_busy_o => io_expander_busy,
      fub_data_o         => fubB_data,
      fub_adr_o          => fubB_addr,
      fub_str_o          => fubB_strb,
      fub_busy_i         => fubB_busy);


  seq_reset_gen_inst : seq_reset_gen
    generic map (
      time_between_resets_in_us => 500.0,
      rst_signal_cnt            => 3,
      clk_freq_in_hz            => clk_freq_in_hz)
    port map (
      rst_i => global_rst,
      clk_i => clk,
      rst_o => seq_reset);

  fub_vga_inst1 : fub_vga
    generic map (
      default_gain   => vga_default_gain,
      spi_address    => 0,
      fub_addr_width => width_for_spi_fub,
      fub_data_width => 8)
    port map (
      clk_i      => clk,
      rst_i      => vga1_rst,
      vga_gain_i => vga1_gain,
      vga_str_i  => vga1_strb,
      vga_busy_o => vga1_busy,
      fub_data_o => fubD_data,
      fub_adr_o  => fubD_addr,
      fub_str_o  => fubD_strb,
      fub_busy_i => fubD_busy);

  fub_vga_inst2 : fub_vga
    generic map (
      default_gain   => vga_default_gain,
      spi_address    => 4,
      fub_addr_width => width_for_spi_fub,
      fub_data_width => 8)
    port map (
      clk_i      => clk,
      rst_i      => vga2_rst,
      vga_gain_i => vga2_gain,
      vga_str_i  => vga2_strb,
      vga_busy_o => vga2_busy,
      fub_data_o => fubE_data,
      fub_adr_o  => fubE_addr,
      fub_str_o  => fubE_strb,
      fub_busy_i => fubE_busy);

  fub_mux_2_to_1_inst1 : fub_mux_2_to_1
    generic map (
      priority        => 0,
      fubA_data_width => 8,
      fubA_adr_width  => width_for_spi_fub,
      fubB_data_width => 8,
      fubB_adr_width  => width_for_spi_fub,
      fub_data_width  => 8,
      fub_adr_width   => width_for_spi_fub)
    port map (
      clk_i       => clk,
      rst_i       => global_rst,
      fubA_data_i => fubB_data,
      fubA_adr_i  => fubB_addr,
      fubA_str_i  => fubB_strb,
      fubA_busy_o => fubB_busy,
      fubB_data_i => fubC_data,
      fubB_adr_i  => fubC_addr,
      fubB_str_i  => fubC_strb,
      fubB_busy_o => fubC_busy,
      fub_data_o  => fubA_data,
      fub_adr_o   => fubA_addr,
      fub_str_o   => fubA_strb,
      fub_busy_i  => fubA_busy);

  fub_mux_2_to_1_inst2 : fub_mux_2_to_1
    generic map (
      priority        => 0,
      fubA_data_width => 8,
      fubA_adr_width  => width_for_spi_fub,
      fubB_data_width => 8,
      fubB_adr_width  => width_for_spi_fub,
      fub_data_width  => 8,
      fub_adr_width   => width_for_spi_fub)
    port map (
      clk_i       => clk,
      rst_i       => global_rst,
      fubA_data_i => fubD_data,
      fubA_adr_i  => fubD_addr,
      fubA_str_i  => fubD_strb,
      fubA_busy_o => fubD_busy,
      fubB_data_i => fubE_data,
      fubB_adr_i  => fubE_addr,
      fubB_str_i  => fubE_strb,
      fubB_busy_o => fubE_busy,
      fub_data_o  => fubC_data,
      fub_adr_o   => fubC_addr,
      fub_str_o   => fubC_strb,
      fub_busy_i  => fubC_busy);

  -- instances
  trigger_maker1_inst : clk_divider
    generic map (
      clk_divider_width => clk_divider_width_toplevel)

    port map (
      clk_div_i => x"01F4",             -- divide by 500
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => auto_trigger1);

  trigger_maker2_inst : clk_divider
    generic map (
      clk_divider_width => clk_divider_width_toplevel)

    port map (
      clk_div_i => x"00FA",             -- divide by 250
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => auto_trigger2);

  -- processes
  p_bbsg_pulser_ch1 : process (clk, global_rst, bbsg_trigger1)
  begin
    if global_rst = '1' then
      dac1d           <= (others => '0');
      bbsg_val_cnt1   <= 0;
      bbsg_pulse_cnt1 <= 1;             -- put 1 for 166MSPS, 0 for 250MSPS
      dac1clk_local   <= '0';
      bbsg_state1     <= WAIT_FOR_TRIGGER;
      
    elsif clk = '1' and clk'event then

      case bbsg_state1 is
        when WAIT_FOR_TRIGGER =>
          if bbsg_trigger1 = '1' then
            bbsg_state1 <= SEND_PULSE;
          end if;
          
        when SEND_PULSE =>
          if bbsg_val_cnt1 = BBSG_VAL_MAX then
            bbsg_val_cnt1 <= 0;
            bbsg_state1   <= WAIT_FOR_TRIGGER;
            dac1clk_local <= '0';
          else
            dac1d         <= sine_lut(bbsg_val_cnt1);
            dac1clk_local <= '1';
            bbsg_val_cnt1 <= bbsg_val_cnt1 + 1;
            bbsg_state1   <= WAIT_SETUP_TIME;  -- comment this line out for 500MSPS
          end if;

        when WAIT_SETUP_TIME =>
          dac1clk_local <= '0';
          if bbsg_pulse_cnt1 = 0 then
            bbsg_state1     <= SEND_PULSE;
            bbsg_pulse_cnt1 <= 1;       -- put 1 for 166MSPS, 0 for 250MSPS
          else
            bbsg_pulse_cnt1 <= bbsg_pulse_cnt1 - 1;
          end if;
        when others => null;
      end case;
    end if;
  end process p_bbsg_pulser_ch1;

--   p_bbsg_pulser_ch2 : process (clk, global_rst, bbsg_trigger2)
--   begin
--     if global_rst = '1' then
--       dac2d           <= (others => '0');
--       bbsg_val_cnt2   <= 0;
--       bbsg_pulse_cnt2 <= 1;             -- put 1 for 166MSPS, 0 for 250MSPS
--       dac2clk_local   <= '0';
--       bbsg_state2     <= WAIT_FOR_TRIGGER;
      
--     elsif clk = '1' and clk'event then

--       case bbsg_state2 is
--         when WAIT_FOR_TRIGGER =>
--           if bbsg_trigger2 = '1' then
--             bbsg_state2 <= SEND_PULSE;
--           end if;
          
--         when SEND_PULSE =>
--           if bbsg_val_cnt2 = BBSG_VAL_MAX then
--             bbsg_val_cnt2 <= 0;
--             bbsg_state2   <= WAIT_FOR_TRIGGER;
--             dac2clk_local <= '0';
--           else
--             dac2d         <= sine_lut(bbsg_val_cnt2);
--             dac2clk_local <= '1';
--             bbsg_val_cnt2 <= bbsg_val_cnt2 + 1;
--             bbsg_state2   <= WAIT_SETUP_TIME;  -- comment this line out for 500MSPS
--           end if;

--         when WAIT_SETUP_TIME =>
--           dac2clk_local <= '0';
--           if bbsg_pulse_cnt2 = 0 then
--             bbsg_state2     <= SEND_PULSE;
--             bbsg_pulse_cnt2 <= 1;       -- put 1 for 166MSPS, 0 for 250MSPS
--           else
--             bbsg_pulse_cnt2 <= bbsg_pulse_cnt2 - 1;
--           end if;
--         when others => null;
--       end case;
--     end if;
--   end process p_bbsg_pulser_ch2;

  bbsg_trigger1 <= auto_trigger1 or auto_trigger2;
  bbsg_trigger2 <= bbsg_trigger1;
  
-- p_trig_detector: process (clk, global_rst)
-- begin  -- process p_trig_detector
--   if global_rst = '1' then              -- asynchronous reset (active high)

--     bbsg_trigger1 <= '0';
--     detector_state <= WAIT_FOR_TRIGGER;

--   elsif clk'event and clk = '1' then    -- rising clock edge

-- case detector_state is
-- when WAIT_FOR_TRIGGER =>

-- when others => null;
-- end case;

--   end if;
-- end process p_trig_detector;

--     end process;

  -- signals interconncections

  -- clk <= xco_clk_i;
  -- clk <= clk100;
  -- clk <= clk200;
  clk <= clk500;

  spi_mosi <= mosi;
  miso     <= spi_miso;
  spi_sclk <= sclk;

  ncs_vga1     <= ss(0);
  ncs_expander <= ss(1);
  ncs_vga2     <= ss(2);

  vga1_rst     <= seq_reset (1);
  expander_rst <= seq_reset (0);
  vga2_rst     <= seq_reset (2);

  global_rst <= por_rst;

  -- clock interconnections

  dac1clk <= dac1clk_local;
  dac2clk <= dac2clk_local;

  adc1clk <= not adc1clk_local;
  adc2clk <= not adc2clk_local;

  io_expander_data <= (
    0  => adc1of,
    1  => adc2of,
    2  => adc1shdn,
    3  => adc1shdn,
    4  => dac1slp,
    5  => dac2slp,
    6  => hdc_io0,
    7  => hdc_io1,
    8  => adc1sw(0),
    9  => adc1sw(1),
    10 => adc1sw(2),
    11 => adc1sw(3),
    12 => adc1sw(0),
    13 => adc1sw(1),
    14 => adc1sw(2),
    15 => adc1sw(3)
    );
  io_expander_str <= '0';

  vga1_strb <= '0';
  vga2_strb <= '0';

end fab_bbsg_top_arch;



-------------------------------------------------------------------------------
-- Recycled Code do not comment out! only for reference purposes!
-----------------------------------------------------------------------------

--         case bbsg_state is
-- when WAIT_FOR_TRIGGER =>
--             if bbsg_trigger1 = '1' then
--               bbsg_state <= SEND_PULSE;
--             end if;
-- when SEND_PULSE =>
--             if bbsg_val_cnt1 = 41 then
--               if bbsg_pulse_cnt1 = 0 then
--                 dac1d           <= sine_lut(bbsg_val_cnt1);
-- --                dac1d<= std_logic_vector(to_signed(1 * to_integer(signed(sine_lut(bbsg_val_cnt1))),14));
-- --                dac1d <= (others => '0');
--                 dac1clk_local   <= '1';
--                 bbsg_pulse_cnt1 <= 2;
--                 bbsg_val_cnt1   <= bbsg_val_cnt1 + 1;
--               else
--                 bbsg_pulse_cnt1 <= bbsg_pulse_cnt1 - 1;
--                 dac1clk_local   <= '0';
--               end if;
--             else
--                 dac1clk_local   <= '0';
--               bbsg_val_cnt1 <= 0;
--               bbsg_state    <= WAIT_FOR_TRIGGER;
--             end if;
--         end case;
