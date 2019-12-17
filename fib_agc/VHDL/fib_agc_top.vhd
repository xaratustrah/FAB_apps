-------------------------------------------------------------------------------
--
-- Automatic Gain Control Firmware for FIB
-- For use with PDMIXER FG352.102
-- Uses "adc_dac_firmware_02" for the FAB-ADC-DAC Board
--
-- S. Sanjari
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.reset_gen_pkg.all;
use work.id_info_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.fub_rs232_rx_pkg.all;
use work.real_time_blinker_pkg.all;
use work.fub_seq_demux_pkg.all;
use work.fub_seq_mux_pkg.all;
use work.clk_detector_pkg.all;
use work.fub_spi_master_pkg.all;
use work.real_time_calculator_pkg.all;
use work.fub_registerfile_cntrl_pkg.all;
use work.registerfile_ram_interface_pkg.all;
use work.fub_ftdi_usb_pkg.all;
use work.fub_flash_pkg.all;
use work.sigmon_ctrl_pkg.all;

-- desired_amplitude: default 4000
-- desired_amplitude_window: default 500
-- gain_update_period_in_us: default 300.0;

entity fib_agc_top is
  generic(
    clk_freq_in_hz                 : real    := 50.0E6;
    baud_rate                      : real    := 115200.0;
    rs232_seq_timeout_in_us        : real    := 10.0E3;
    no_of_registers                : integer := 20;
    firmware_id                    : integer := 5;  --ID of the firmware (is displayed first)
    firmware_version               : integer := 1;  --Version of the firmware (is displayed after)   
    firmware_config                : integer := 1;  --Configuration of the firmware (is displayed last)   
    firmware_id_display_time_in_ms : real    := 1000.0;
    enable_sigmon_output           : boolean := true;  -- turn off/on the SIGMON
    sigmon_channel                 : integer := 2
    );
  port (
    --trigger signals
    trig1_in  : in  std_logic;          --rst
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
    uC_Link_A         : in  std_logic_vector(7 downto 0);  --dds_addr
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
    nSPI_SS   : out std_logic;
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
end entity fib_agc_top;

architecture fib_agc_top_arch of fib_agc_top is

  -- common signals
  signal clk      : std_logic;
  signal rst      : std_logic;
  signal soft_rst : std_logic;

  -- LED signals
  signal led_id_inf_i : std_logic_vector(3 downto 0);
  signal led_id_inf_o : std_logic_vector(3 downto 0);

  -- RS232 Signals

--  signal fub_strobe   : std_logic;
  signal rs232_busy   : std_logic;
  signal fub_data_ch1 : std_logic_vector (7 downto 0);
  signal fub_data_ch2 : std_logic_vector (7 downto 0);

  -- AGC Signals
  constant MAX_GAIN : integer := 71;
  constant MIN_GAIN : integer := 0;
  signal gain_ch1   : integer range 0 to 71;
  signal gain_ch2   : integer range 0 to 71;

  signal detected_amplitude_ch1 : std_logic_vector (13 downto 0);
  signal detected_amplitude_ch2 : std_logic_vector (13 downto 0);

  type read_state_type is (READ_FROM_CH1, READ_FROM_CH2);
  signal read_state : read_state_type;

  -- LED Signals
  signal led_leise_ch1 : std_logic;
  signal led_leise_ch2 : std_logic;
  signal led_laut_ch1  : std_logic;
  signal led_laut_ch2  : std_logic;

  -- SPI Channel 1 Signals
  signal spi_ch1_mosi   : std_logic;
  signal spi_ch1_miso   : std_logic;
  signal spi_ch1_sck    : std_logic;
  signal spi_ch1_ss     : std_logic;
  signal spi_ch1_busy   : std_logic;
  signal spi_ch1_strobe : std_logic;

  -- SPI Channel 2 Signals
  signal spi_ch2_mosi   : std_logic;
  signal spi_ch2_miso   : std_logic;
  signal spi_ch2_sck    : std_logic;
  signal spi_ch2_ss     : std_logic;
  signal spi_ch2_busy   : std_logic;
  signal spi_ch2_strobe : std_logic;

  -- Signale fuer Config und RS232
  signal nrs232_rx_i : std_logic;

  signal fub_rs232_rx_data : std_logic_vector(7 downto 0);
  signal fub_rs232_rx_str  : std_logic;
  signal fub_rs232_rx_busy : std_logic;

  signal fub_rs232_rx_conf_data : std_logic_vector(7 downto 0);
  signal fub_rs232_rx_conf_adr  : std_logic_vector(15 downto 0);
  signal fub_rs232_rx_conf_str  : std_logic;
  signal fub_rs232_rx_conf_busy : std_logic;

  signal fub_rs232_tx_data : std_logic_vector(7 downto 0);
  signal fub_rs232_tx_str  : std_logic;
  signal fub_rs232_tx_busy : std_logic;

  signal fub_rs232_tx_conf_data : std_logic_vector(7 downto 0);
  signal fub_rs232_tx_conf_adr  : std_logic_vector(15 downto 0);
  signal fub_rs232_tx_conf_str  : std_logic;
  signal fub_rs232_tx_conf_busy : std_logic;

  signal registerfile_wren_a : std_logic;
  signal registerfile_adr_a  : std_logic_vector (15 downto 0);
  signal registerfile_dat_a  : std_logic_vector (7 downto 0);
  signal registerfile_q_a    : std_logic_vector (7 downto 0);

  signal registerfile_to_agc   : std_logic_vector (no_of_registers * 8 - 1 downto 0);
  signal registerfile_from_agc : std_logic_vector (no_of_registers * 8 - 1 downto 0);

  type registerfile_array_type is array(0 to no_of_registers-1) of std_logic_vector(7 downto 0);
  signal registerfile_to_agc_array   : registerfile_array_type;
  signal registerfile_from_agc_array : registerfile_array_type;

  -- Flash/EEPROM Signals
  signal fub_flash_fub_read_busy_o            : std_logic;
  signal fub_flash_fub_read_data_o            : std_logic_vector(7 downto 0);
  signal fub_registerfile_cntrl_fub_fr_str_o  : std_logic;
  signal fub_registerfile_cntrl_fub_fr_adr_o  : std_logic_vector(15 downto 0);
  signal fub_registerfile_cntrl_fub_fw_str_o  : std_logic;
  signal fub_flash_fub_write_busy_o           : std_logic;
  signal fub_registerfile_cntrl_fub_fw_data_o : std_logic_vector(7 downto 0);
  signal fub_registerfile_cntrl_fub_fw_adr_o  : std_logic_vector(15 downto 0);

  signal fub_registerfile_cntrl_fub_fr_adr_o_extended : std_logic_vector(23 downto 0);
  signal fub_registerfile_cntrl_fub_fw_adr_o_extended : std_logic_vector(23 downto 0);

  signal eeprom_ncs_intern  : std_logic;
  signal eeprom_asdi_intern : std_logic;
  signal eeprom_dclk_intern : std_logic;
  signal eeprom_data_sync   : std_logic;

  -- Signals mapped to Registers

  signal desired_value_adc1         : std_logic_vector (15 downto 0);
  signal desired_value_adc1_decimal : integer range 0 to 2**14 - 1;
  signal actual_value_adc1          : std_logic_vector (15 downto 0);

  signal desired_value_adc2         : std_logic_vector (15 downto 0);
  signal desired_value_adc2_decimal : integer range 0 to 2**14 - 1;
  signal actual_value_adc2          : std_logic_vector (15 downto 0);

  signal desired_amplitude_window            : std_logic_vector (15 downto 0);
  signal desired_amplitude_window_in_decimal : integer range 0 to 2**16 - 1;

  signal manual_gain_ch1 : std_logic_vector (7 downto 0);
  signal manual_gain_ch2 : std_logic_vector (7 downto 0);

  signal actual_gain_ch1 : std_logic_vector (7 downto 0);
  signal actual_gain_ch2 : std_logic_vector (7 downto 0);

  signal control_register : std_logic_vector (7 downto 0);
  signal status_register  : std_logic_vector (7 downto 0);

  signal update_rate         : std_logic_vector (31 downto 0);  -- for both channels
  signal update_rate_counter : std_logic_vector (32 downto 0);

  ------------------------

begin
  
  reset_gen_inst : reset_gen
    generic map(
      reset_clks => 2
      )
    port map (
      clk_i => clk0,
      rst_o => rst
      );

  id_info_inst : id_info
    generic map (
      clk_freq_in_hz     => clk_freq_in_hz,
      display_time_in_ms => firmware_id_display_time_in_ms,
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

  inst_fub_spi_master1 : fub_spi_master
    generic map (
      setup_clks => 10,
      spi_clks   => 20)

    port map (
      clk_i      => clk,
      rst_i      => rst,
      fub_str_i  => spi_ch1_strobe,
      fub_busy_o => spi_ch1_busy,
      fub_data_i => fub_data_ch1,
      fub_str_o  => open,
      fub_busy_i => '0',
      fub_data_o => open,
      fub_error  => open,
      spi_mosi_o => spi_ch1_mosi,
      spi_miso_i => spi_ch1_miso,
      spi_clk_o  => spi_ch1_sck,
      spi_ss_o   => spi_ch1_ss
      );

  inst_fub_spi_master2 : fub_spi_master
    generic map (
      setup_clks => 10,
      spi_clks   => 20)

    port map (
      clk_i      => clk,
      rst_i      => rst,
      fub_str_i  => spi_ch2_strobe,
      fub_busy_o => spi_ch2_busy,
      fub_data_i => fub_data_ch2,
      fub_str_o  => open,
      fub_busy_i => '0',
      fub_data_o => open,
      fub_error  => open,
      spi_mosi_o => spi_ch2_mosi,
      spi_miso_i => spi_ch2_miso,
      spi_clk_o  => spi_ch2_sck,
      spi_ss_o   => spi_ch2_ss
      );

  -----------------------------------------------------------------------------
  -- FIB Signals

  clk <= clk0;

  --led signal mapping
  led4 <= led_id_inf_o(3);
  led3 <= led_id_inf_o(2);
  led2 <= led_id_inf_o(1);
  led1 <= led_id_inf_o(0);

  -- LED Connection according to the front side marking on the housing
  led_id_inf_i(3) <= led_laut_ch1;
  led_id_inf_i(2) <= led_leise_ch1;
  led_id_inf_i(1) <= led_laut_ch2;
  led_id_inf_i(0) <= led_leise_ch2;

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
  uC_Link_DIR_A      <= '0';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  nuC_Link_EN_CTRL_A <= '1';            --EN: '1'=disabled, '0'=enabled
  uC_Link_EN_DA      <= '0';            --EN: '1'=disabled, '0'=enabled !!

  -------------------------------------------------------------------------------
  -- FAB Signals

  Piggy_Ack1  <= '1';                   -- OE Signal von FAB
  Piggy_Clk1  <= clk;
  Piggy_Strb1 <= '1';
  Piggy_Strb2 <= '1';
  Piggy_RnW1  <= '1';                   -- alpha rnw
  Piggy_RnW2  <= '1';                   -- beta rnw
  Piggy_Ack2  <= not rst;               -- nRST signal von FAB
--  piggy_io (7 downto 4) <= "0011";      -- alpha Address of the ADC2-HB
--  piggy_io (3 downto 0) <= "0010";      -- beta Address of the ADC2-LB

  -----------------------------------------------------------------------------
  -- Config Interface + RS232

  rs232_rx_inst : fub_rs232_rx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => baud_rate
      )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      rs232_rx_i => nrs232_rx_i,
      fub_str_o  => fub_rs232_rx_str,
      fub_busy_i => fub_rs232_rx_busy,
      fub_data_o => fub_rs232_rx_data
      );

  fub_seq_demux_inst : fub_seq_demux
    generic map (
      fub_address_width => 16,
      fub_data_width    => 8,
      clk_freq_in_hz    => clk_freq_in_hz,
      timeout_in_us     => rs232_seq_timeout_in_us
      )
    port map (
      clk_i          => clk,
      rst_i          => rst,
      fub_strb_o     => fub_rs232_rx_conf_str,
      fub_data_o     => fub_rs232_rx_conf_data,
      fub_addr_o     => fub_rs232_rx_conf_adr,
      fub_busy_i     => fub_rs232_rx_conf_busy,
      seq_busy_o     => fub_rs232_rx_busy,
      seq_data_i     => fub_rs232_rx_data,
      seq_strb_i     => fub_rs232_rx_str,
      crc_mismatch_o => open
      );

  fub_registerfile_cntrl_inst : fub_registerfile_cntrl
    generic map(
      adr_width                => 16,
      data_width               => 8,
      default_start_adr        => 16#0000#,
      default_end_adr          => 16#0013#,
      reg_adr_cmd              => 16#fff0#,
      reg_adr_start_adr_high   => 16#fff1#,
      reg_adr_start_adr_low    => 16#fff2#,
      reg_adr_end_adr_high     => 16#fff3#,
      reg_adr_end_adr_low      => 16#fff4#,
      reg_adr_firmware_id      => 16#fff5#,
      reg_adr_firmware_version => 16#fff6#,
      reg_adr_firmware_config  => 16#fff7#,
      firmware_id              => firmware_id,
      firmware_version         => firmware_version,
      firmware_config          => firmware_config,
      boot_from_flash          => true
      )
    port map (
      rst_i                  => rst,
      clk_i                  => clk,
      fub_cfg_reg_in_dat_i   => fub_rs232_rx_conf_data,
      fub_cfg_reg_in_adr_i   => fub_rs232_rx_conf_adr,
      fub_cfg_reg_in_str_i   => fub_rs232_rx_conf_str,
      fub_cfg_reg_in_busy_o  => fub_rs232_rx_conf_busy,
      fub_cfg_reg_out_str_o  => fub_rs232_tx_conf_str,
      fub_cfg_reg_out_dat_o  => fub_rs232_tx_conf_data,
      fub_cfg_reg_out_adr_o  => fub_rs232_tx_conf_adr,
      fub_cfg_reg_out_busy_i => fub_rs232_tx_conf_busy,
      fub_fr_busy_i          => fub_flash_fub_read_busy_o,
      fub_fr_dat_i           => fub_flash_fub_read_data_o,
      fub_fr_str_o           => fub_registerfile_cntrl_fub_fr_str_o,
      fub_fr_adr_o           => fub_registerfile_cntrl_fub_fr_adr_o,
      fub_fw_str_o           => fub_registerfile_cntrl_fub_fw_str_o,
      fub_fw_busy_i          => fub_flash_fub_write_busy_o,
      fub_fw_dat_o           => fub_registerfile_cntrl_fub_fw_data_o,
      fub_fw_adr_o           => fub_registerfile_cntrl_fub_fw_adr_o,
      fub_out_data_o         => open,
      fub_out_adr_o          => open,
      fub_out_str_o          => open,
      fub_out_busy_i         => '0',
      ram_wren_o             => registerfile_wren_a,
      ram_adr_o              => registerfile_adr_a,
      ram_dat_o              => registerfile_dat_a,
      ram_q_i                => registerfile_q_a
      );

  fub_registerfile_cntrl_fub_fr_adr_o_extended <= ("00000000" & fub_registerfile_cntrl_fub_fr_adr_o);
  fub_registerfile_cntrl_fub_fw_adr_o_extended <= ("00000000" & fub_registerfile_cntrl_fub_fw_adr_o);

  fub_flash_inst : fub_flash
    generic map(
      main_clk                   => clk_freq_in_hz,
      priority_on_reading        => '1',
      my_delay_in_ns_for_reading => 25.0,  -- equal to 40 MHz // 25ns high 25ns low => 50ns equal to 20MHz CLK Signal
      my_delay_in_ns_for_writing => 20.0,  -- equal to 50 MHz // 20ns high 20ns low => 40ns equal to 25MHz CLK Signal
      erase_in_front_of_write    => '1'
      )                                                                 
    port map(
      clk_i            => clk,
      rst_i            => rst,
      fub_write_busy_o => fub_flash_fub_write_busy_o,
      fub_write_data_i => fub_registerfile_cntrl_fub_fw_data_o,
      fub_write_adr_i  => fub_registerfile_cntrl_fub_fw_adr_o_extended,
      fub_write_str_i  => fub_registerfile_cntrl_fub_fw_str_o,
      fub_read_busy_o  => fub_flash_fub_read_busy_o,
      fub_read_data_o  => fub_flash_fub_read_data_o,
      fub_read_adr_i   => fub_registerfile_cntrl_fub_fr_adr_o_extended,
      fub_read_str_i   => fub_registerfile_cntrl_fub_fr_str_o,
      erase_str_i      => '0',
      erase_adr_i      => (others => '0'),
      nCS_o            => eeprom_ncs_intern,
      asdi_o           => eeprom_asdi_intern,
      dclk_o           => eeprom_dclk_intern,
      data_i           => eeprom_data_sync
      );

  registerfile_ram_interface_inst : registerfile_ram_interface
    generic map (
      adr_width       => 16,
      data_width      => 8,
      no_of_registers => no_of_registers
      )
    port map(
      rst_i      => rst,
      clk_i      => clk,
      wren_a     => registerfile_wren_a,
      adr_a      => registerfile_adr_a,
      dat_a      => registerfile_dat_a,
      q_a        => registerfile_q_a,
      register_o => registerfile_to_agc,
      register_i => registerfile_from_agc
      );

  registerfile_array_to_parallel_gen1 : for i in 0 to no_of_registers-1 generate
    registerfile_to_agc_array(i) <= registerfile_to_agc((i+1)*8-1 downto i*8);
  end generate;

  registerfile_array_to_parallel_gen2 : for i in 0 to no_of_registers-1 generate
    registerfile_from_agc((i+1)*8-1 downto i*8) <= registerfile_from_agc_array(i);
  end generate;

  -- Registers from System to AGC
  desired_value_adc1 (7 downto 0)  <= registerfile_to_agc_array (00);
  desired_value_adc1 (15 downto 8) <= registerfile_to_agc_array (01);

  desired_value_adc2(7 downto 0)  <= registerfile_to_agc_array (04);
  desired_value_adc2(15 downto 8) <= registerfile_to_agc_array (05);

  update_rate (7 downto 0)   <= registerfile_to_agc_array (08);
  update_rate (15 downto 8)  <= registerfile_to_agc_array (09);
  update_rate (23 downto 16) <= registerfile_to_agc_array (10);
  update_rate (31 downto 24) <= registerfile_to_agc_array (11);

  desired_amplitude_window (7 downto 0)  <= registerfile_to_agc_array (12);
  desired_amplitude_window (15 downto 8) <= registerfile_to_agc_array (13);

  manual_gain_ch1 <= registerfile_to_agc_array (14);
  manual_gain_ch2 <= registerfile_to_agc_array (15);

  control_register <= registerfile_to_agc_array (18);

  -- Registers from AGC to System
  registerfile_from_agc_array (00) <= registerfile_to_agc_array (00);
  registerfile_from_agc_array (01) <= registerfile_to_agc_array (01);

  registerfile_from_agc_array (02) <= actual_value_adc1 (7 downto 0);
  registerfile_from_agc_array (03) <= actual_value_adc1 (15 downto 8);

  registerfile_from_agc_array (04) <= registerfile_to_agc_array (04);
  registerfile_from_agc_array (05) <= registerfile_to_agc_array (05);

  registerfile_from_agc_array (06) <= actual_value_adc2 (7 downto 0);
  registerfile_from_agc_array (07) <= actual_value_adc2 (15 downto 8);

  registerfile_from_agc_array (08) <= registerfile_to_agc_array (08);
  registerfile_from_agc_array (09) <= registerfile_to_agc_array (09);
  registerfile_from_agc_array (10) <= registerfile_to_agc_array (10);
  registerfile_from_agc_array (11) <= registerfile_to_agc_array (11);
  registerfile_from_agc_array (12) <= registerfile_to_agc_array (12);
  registerfile_from_agc_array (13) <= registerfile_to_agc_array (13);
  registerfile_from_agc_array (14) <= registerfile_to_agc_array (14);
  registerfile_from_agc_array (15) <= registerfile_to_agc_array (15);

  registerfile_from_agc_array (16) <= actual_gain_ch1;
  registerfile_from_agc_array (17) <= actual_gain_ch2;

  registerfile_from_agc_array (18) <= registerfile_to_agc_array (18);

  registerfile_from_agc_array (19) <= status_register;


  fub_seq_mux_inst : fub_seq_mux
    generic map (
      fub_address_width => 16,
      fub_data_width    => 8,
      clk_freq_in_hz    => clk_freq_in_hz,
      timeout_in_us     => rs232_seq_timeout_in_us
      )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      fub_strb_i => fub_rs232_tx_conf_str,
      fub_data_i => fub_rs232_tx_conf_data,
      fub_addr_i => fub_rs232_tx_conf_adr,
      fub_busy_o => fub_rs232_tx_conf_busy,
      seq_busy_i => fub_rs232_tx_busy,
      seq_data_o => fub_rs232_tx_data,
      seq_strb_o => fub_rs232_tx_str
      );

  fub_rs232_tx_inst : fub_rs232_tx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => baud_rate
      )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      rs232_tx_o => rs232_tx_o,
      fub_str_i  => fub_rs232_tx_str,
      fub_busy_o => fub_rs232_tx_busy,
      fub_data_i => fub_rs232_tx_data
      );

  -- Register connections to real signals
  
  desired_value_adc1_decimal <= to_integer(unsigned(desired_value_adc1));
  desired_value_adc2_decimal <= to_integer(unsigned(desired_value_adc2));

  desired_amplitude_window_in_decimal <= to_integer(unsigned(desired_amplitude_window));

  soft_rst <= rst or control_register (0);

  -----------------------------------------------------------------------------
  -- Processes
  p_register : process (clk)
  begin  -- process p_register
    if clk'event and clk = '1' then

      actual_value_adc1 (7 downto 0)   <= detected_amplitude_ch1 (7 downto 0);
      actual_value_adc1 (13 downto 8)  <= detected_amplitude_ch1 (13 downto 8);
      actual_value_adc1 (15 downto 14) <= (others => '0');

      actual_value_adc2 (7 downto 0)   <= detected_amplitude_ch2 (7 downto 0);
      actual_value_adc2 (13 downto 8)  <= detected_amplitude_ch2 (13 downto 8);
      actual_value_adc2 (15 downto 14) <= (others => '0');

      status_register (0) <= control_register (0);
      status_register (1) <= control_register (1);
      status_register (2) <= control_register (2);
      status_register (3) <= led_leise_ch1;
      status_register (4) <= led_laut_ch1;
      status_register (5) <= led_leise_ch2;
      status_register (6) <= led_laut_ch2;
      status_register (7) <= control_register (7);

      trig2_out <= control_register (7);
    end if;
  end process p_register;

  p_agc : process (clk, soft_rst)
  begin  -- process p_agc
    if soft_rst = '1' then              -- asynchronous reset (active high)

      update_rate_counter <= (others => '0');

      fub_data_ch1 <= std_logic_vector(to_unsigned(MAX_GAIN, 8));
      fub_data_ch2 <= std_logic_vector(to_unsigned(MAX_GAIN, 8));
      gain_ch1     <= MIN_GAIN;
      gain_ch2     <= MIN_GAIN;

      spi_ch1_strobe <= '0';
      spi_ch2_strobe <= '0';

      detected_amplitude_ch1 <= (others => '0');
      detected_amplitude_ch2 <= (others => '0');

      piggy_io (7 downto 4) <= "0001";  -- alpha Address of the ADC1-HB
      piggy_io (3 downto 0) <= "0000";  -- beta Address of the ADC1-LB

      led_leise_ch1 <= '0';
      led_laut_ch1  <= '0';
      led_leise_ch2 <= '0';
      led_laut_ch2  <= '0';

      read_state <= READ_FROM_CH1;

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Channel 1 Signal update
      nSPI_MOSI    <= not spi_ch1_mosi;
      spi_ch1_miso <= not nSPI_MISO;
      nSPI_SS      <= not spi_ch1_ss;
      nSPI_SCK     <= not spi_ch1_sck;

      -- Channel 2 Signal update
      nI2C_SDA     <= not spi_ch2_mosi;
      spi_ch2_miso <= not nGPIO2_R;
      nGPIO1_W     <= not spi_ch2_ss;
      nI2C_SCL     <= not spi_ch2_sck;

      -- Read ADC Signals
      case read_state is
        when READ_FROM_CH1 =>
          piggy_io (7 downto 4)                <= "0001";  -- alpha Address of the ADC1-HB
          piggy_io (3 downto 0)                <= "0000";  -- beta Address of the ADC1-LB
          detected_amplitude_ch1 (7 downto 0)  <= uC_Link_D;
          detected_amplitude_ch1 (13 downto 8) <= uC_Link_A (5 downto 0);
          read_state                           <= READ_FROM_CH2;

        when READ_FROM_CH2 =>
          piggy_io (7 downto 4)                <= "0011";  -- alpha Address of the ADC2-HB
          piggy_io (3 downto 0)                <= "0010";  -- beta Address of the ADC2-LB
          detected_amplitude_ch2 (7 downto 0)  <= uC_Link_D;
          detected_amplitude_ch2 (13 downto 8) <= uC_Link_A (5 downto 0);
          read_state                           <= READ_FROM_CH1;
        when others => null;
      end case;

      --

      if update_rate_counter (32) = '1' then

        -- Channel one AGC
        -- Leise!
        if to_integer(signed(detected_amplitude_ch1)) < desired_value_adc1_decimal - desired_amplitude_window_in_decimal and gain_ch1 < MAX_GAIN then
          gain_ch1 <= gain_ch1 + 1;
        end if;

        -- Laut!
        if to_integer(signed(detected_amplitude_ch1)) > desired_value_adc1_decimal + desired_amplitude_window_in_decimal and gain_ch1 > MIN_GAIN then
          gain_ch1 <= gain_ch1 - 1;
        end if;

        -- LED Signals Control
        if to_integer(signed(detected_amplitude_ch1)) < desired_value_adc1_decimal - desired_amplitude_window_in_decimal then
          -- leise 
          led_leise_ch1 <= '1';
          led_laut_ch1  <= '0';
        elsif to_integer(signed(detected_amplitude_ch1)) > desired_value_adc1_decimal + desired_amplitude_window_in_decimal then
          -- laut
          led_leise_ch1 <= '0';
          led_laut_ch1  <= '1';
        else
          led_leise_ch1 <= '1';
          led_laut_ch1  <= '1';
        end if;

        -- Channel Two AGC
        -- Leise!
        if to_integer(signed(detected_amplitude_ch2)) < desired_value_adc2_decimal - desired_amplitude_window_in_decimal and gain_ch2 < MAX_GAIN then
          gain_ch2 <= gain_ch2 + 1;
        end if;

        -- Laut!
        if to_integer(signed(detected_amplitude_ch2)) > desired_value_adc2_decimal + desired_amplitude_window_in_decimal and gain_ch2 > MIN_GAIN then
          gain_ch2 <= gain_ch2 - 1;
        end if;

        -- LED Signals Control
        if to_integer(signed(detected_amplitude_ch2)) < desired_value_adc2_decimal - desired_amplitude_window_in_decimal then
          -- leise 
          led_leise_ch2 <= '1';
          led_laut_ch2  <= '0';
        elsif to_integer(signed(detected_amplitude_ch2)) > desired_value_adc2_decimal + desired_amplitude_window_in_decimal then
          -- laut
          led_leise_ch2 <= '0';
          led_laut_ch2  <= '1';
        else
          led_leise_ch2 <= '1';
          led_laut_ch2  <= '1';
        end if;

        -- SPI Channel 1 Data update
        if spi_ch1_busy = '0' then
          if control_register (1) = '0' then
            fub_data_ch1    <= std_logic_vector(to_signed(gain_ch1, 8));
            actual_gain_ch1 <= std_logic_vector(to_signed(gain_ch1, 8));
          else
            fub_data_ch1    <= manual_gain_ch1;
            actual_gain_ch1 <= manual_gain_ch1;
          end if;
          spi_ch1_strobe <= '1';
        end if;

        -- SPI Channel 2 Data update
        if spi_ch2_busy = '0' then
          if control_register (2) = '0' then
            fub_data_ch2    <= std_logic_vector(to_signed(gain_ch2, 8));
            actual_gain_ch2 <= std_logic_vector(to_signed(gain_ch2, 8));
          else
            fub_data_ch2    <= manual_gain_ch2;
            actual_gain_ch2 <= manual_gain_ch2;
          end if;
          spi_ch2_strobe <= '1';
        end if;

        update_rate_counter (31 downto 0) <= update_rate;
        update_rate_counter (32)          <= '0';

      else
        update_rate_counter <= update_rate_counter - x"0001";
        spi_ch1_strobe      <= '0';
        spi_ch2_strobe      <= '0';
      end if;
    end if;
  end process p_agc;

  p_rs232_rx : process(clk, rst)
  begin
    if clk = '1' and clk'event then
      nrs232_rx_i <= not rs232_rx_i;
    end if;
  end process p_rs232_rx;

  eeprom_ncs  <= eeprom_ncs_intern;
  eeprom_asdi <= eeprom_asdi_intern;
  eeprom_dclk <= eeprom_dclk_intern;

  p_eeprom : process(clk, rst)
  begin
    if clk = '1' and clk'event then
      eeprom_data_sync <= eeprom_data;
    end if;
  end process p_eeprom;

-------------------------------------------------------------------------------
-- SIGMON USB Generate MODULE
-- BEGIN
-------------------------------------------------------------------------------  

  sigmon_gen : if (enable_sigmon_output = true) generate
    
    component fifo_16bit is
      port
        (
          clock : in  std_logic;
          data  : in  std_logic_vector (15 downto 0);
          rdreq : in  std_logic;
          sclr  : in  std_logic;
          wrreq : in  std_logic;
          empty : out std_logic;
          full  : out std_logic;
          q     : out std_logic_vector (15 downto 0)
          );
    end component;

    -- FIFO Signals
    
    signal fifo_data_in  : std_logic_vector(15 downto 0);
    signal fifo_data_out : std_logic_vector(15 downto 0);
    signal fifo_rdreq    : std_logic;
    signal fifo_wrreq    : std_logic;
    signal fifo_empty    : std_logic;
    signal fifo_full     : std_logic;

    signal fub_tx_str  : std_logic;
    signal fub_tx_busy : std_logic;
    signal fub_tx_data : std_logic_vector(7 downto 0);

    signal fub_rx_str  : std_logic;
    signal fub_rx_busy : std_logic;
    signal fub_rx_data : std_logic_vector(7 downto 0);


    -- FTDI Signals
    signal fub_usb_data : std_logic_vector (7 downto 0);
    signal fub_usb_str  : std_logic;
    signal fub_usb_busy : std_logic;

    signal ftdi_d    : std_logic_vector (7 downto 0);
    signal ftdi_nrd  : std_logic;
    signal ftdi_wr   : std_logic;
    signal ftdi_nrxf : std_logic;
    signal ftdi_ntxe : std_logic;

    signal ftdi_nrxf_synced : std_logic;
    signal ftdi_ntxe_synced : std_logic;

    signal signal_probe : std_logic_vector(15 downto 0);


  begin
    --- SIGMON
    
    fifo_inst : fifo_16bit
      port map (
        clock => clk,
        data  => fifo_data_in,
        rdreq => fifo_rdreq,
        sclr  => rst,
        wrreq => fifo_wrreq,
        empty => fifo_empty,
        full  => fifo_full,
        q     => fifo_data_out
        );

    fub_ftdi_usb_inst : fub_ftdi_usb
      generic map (
        clk_freq_in_hz => clk_freq_in_hz
        )
      port map (
        clk_i          => clk,
        rst_i          => rst,
        fub_in_str_i   => fub_tx_str,
        fub_in_busy_o  => fub_tx_busy,
        fub_in_data_i  => fub_tx_data,
        fub_out_str_o  => fub_rx_str,
        fub_out_busy_i => fub_rx_busy,
        fub_out_data_o => fub_rx_data,
        ftdi_d_io      => ftdi_d,
        ftdi_nrd_o     => ftdi_nrd,
        ftdi_wr_o      => ftdi_wr,
        ftdi_nrxf_i    => ftdi_nrxf_synced,
        ftdi_ntxe_i    => ftdi_ntxe_synced
        );

    sigmon_ctrl_inst : sigmon_ctrl
      generic map(
        data_width          => 16,
        fifo_size           => 4096,
        external_trigger_en => false,
        magic_number        => 1442775210  -- (=55ff00aa) magic number as header indentifier 
        )         
      port map(
        clk_i          => clk,
        rst_i          => rst,
        --data interface
        data_i         => signal_probe,
        data_trigger_i => '0',
        --fifo interface
        fifo_d_o       => fifo_data_in,
        fifo_rdreq_o   => fifo_rdreq,
        fifo_wrreq_o   => fifo_wrreq,
        fifo_empty_i   => fifo_empty,
        fifo_full_i    => fifo_full,
        fifo_d_i       => fifo_data_out,
        --fub out
        fub_tx_str_o   => fub_tx_str,
        fub_tx_busy_i  => fub_tx_busy,
        fub_tx_data_o  => fub_tx_data,
        --fub in
        fub_rx_str_i   => fub_rx_str,
        fub_rx_busy_o  => fub_rx_busy,
        fub_rx_data_i  => fub_rx_data,
        test_o         => open
        );

    -- UDL Platine
    --DSP-Link Direction:
    DSP_DIR_D      <= not ftdi_nrd;     --DIR: '1'=to FPGA, '0'=from FPGA
    DSP_DIR_STRACK <= '0';              --DIR: '1'=to FPGA, '0'=from FPGA
    DSP_DIR_REQRDY <= '1';              --DIR: '1'=to FPGA, '0'=from FPGA

    --FTDI signal mapping
    ftdi_d(0)  <= not DSP_D_R0 when ftdi_nrd = '0' else 'Z';
    ftdi_d(1)  <= not DSP_D_R1 when ftdi_nrd = '0' else 'Z';
    ftdi_d(2)  <= not DSP_D_R2 when ftdi_nrd = '0' else 'Z';
    ftdi_d(3)  <= not DSP_D_R3 when ftdi_nrd = '0' else 'Z';
    ftdi_d(4)  <= not DSP_D_R4 when ftdi_nrd = '0' else 'Z';
    ftdi_d(5)  <= not DSP_D_R5 when ftdi_nrd = '0' else 'Z';
    ftdi_d(6)  <= not DSP_D_R6 when ftdi_nrd = '0' else 'Z';
    ftdi_d(7)  <= not DSP_D_R7 when ftdi_nrd = '0' else 'Z';
    DSP_D_W0   <= not ftdi_d(0);
    DSP_D_W1   <= not ftdi_d(1);
    DSP_D_W2   <= not ftdi_d(2);
    DSP_D_W3   <= not ftdi_d(3);
    DSP_D_W4   <= not ftdi_d(4);
    DSP_D_W5   <= not ftdi_d(5);
    DSP_D_W6   <= not ftdi_d(6);
    DSP_D_W7   <= not ftdi_d(7);
    DSP_CSTR_W <= not ftdi_wr;
    DSP_CACK_W <= not ftdi_nrd;
    ftdi_nrxf  <= not DSP_CRDY_R;
    ftdi_ntxe  <= not DSP_CREQ_R;

    -----------------------------------------------------------------------------

    --- Sigmon processes

    p_synch_udl : process(clk)
    begin
      if clk = '1' and clk'event then
        ftdi_nrxf_synced <= ftdi_nrxf;
        ftdi_ntxe_synced <= ftdi_ntxe;
      end if;
    end process p_synch_udl;

    signal_probe (13 downto 0)  <= detected_amplitude_ch1 when sigmon_channel = 1 else detected_amplitude_ch2;
    signal_probe (15 downto 14) <= (others => '0');

  end generate sigmon_gen;

-------------------------------------------------------------------------------
-- END
-- SIGMON USB Generate MODULE
-------------------------------------------------------------------------------  

end fib_agc_top_arch;
