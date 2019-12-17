-------------------------------------------------------------------------------
-- Title      : Testbench for design "fib_agc_top"
-- Project    : fib_AGC
-------------------------------------------------------------------------------
-- File       : fib_agc_top_tb.vhd
-- Author     :   <ssanjari@BTPC088>
-- Company    : GSI Darmstadt
-- Created    : 2007-08-24
-- Last update: 2007-12-21
-- Platform   : CYCLONE I, ALTERA
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-08-24  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fub_rs232_tx_pkg.all;

-------------------------------------------------------------------------------

entity fib_agc_top_tb is
  generic (
    clk_freq_in_hz        : real    := 50.0E6;  --50 MHz system clock frequency
    slow_clk_period_in_ms : real    := 0.2E-3;  -- 200ns
    baud_rate             : real    := 10.0E6;
    wait_clks             : integer := 20;
    clk_period            : time    := 20 ns;
    reset_clocks          : integer := 20;
    firmware_id           : integer := 2;  --ID of the firmware (is displayed first)
    firmware_version      : integer := 6  --Version of the firmware (is displayed after)
    );
end fib_agc_top_tb;

-------------------------------------------------------------------------------

architecture fib_agc_top_tb_arch of fib_agc_top_tb is

  component fib_agc_top
    generic (
      clk_freq_in_hz   : real;
      baud_rate        : real;
      firmware_id      : integer;
      firmware_version : integer);
    port (
      trig1_in                     : in    std_logic;
      trig2_out                    : out   std_logic;
      trig1_out                    : out   std_logic;
      trig2_in                     : in    std_logic;
      clk0                         : in    std_logic;
      clk1                         : in    std_logic;
      hf1_in                       : in    std_logic;
      hf2_in                       : in    std_logic;
      uC_Link_D                    : in    std_logic_vector(7 downto 0);
      uC_Link_A                    : in    std_logic_vector(7 downto 0);
      nuC_Link_ACK_R               : in    std_logic;
      nuC_Link_ACK_W               : out   std_logic;
      nuC_Link_MRQ_R               : in    std_logic;
      nuC_Link_MRQ_W               : out   std_logic;
      nuC_Link_RnW_R               : in    std_logic;
      nuC_Link_RnW_W               : out   std_logic;
      nuC_Link_STROBE_R            : in    std_logic;
      nuC_Link_STROBE_W            : out   std_logic;
      uC_Link_DIR_D, uC_Link_DIR_A : out   std_logic;
      nuC_Link_EN_CTRL_A           : out   std_logic;
      uC_Link_EN_DA                : out   std_logic;
      Piggy_Clk1                   : out   std_logic;
      Piggy_RnW1                   : out   std_logic;
      Piggy_RnW2                   : out   std_logic;
      Piggy_Strb2                  : out   std_logic;
      Piggy_Strb1                  : out   std_logic;
      Piggy_Ack1                   : out   std_logic;
      Piggy_Ack2                   : out   std_logic;
      A2nSW8                       : in    std_logic;
      A3nSW9                       : in    std_logic;
      A0nSW10                      : in    std_logic;
      A1nSW11                      : in    std_logic;
      Sub_A0nIW6                   : in    std_logic;
      Sub_A1nIW7                   : in    std_logic;
      Sub_A2nIW4                   : in    std_logic;
      Sub_A3nIW5                   : in    std_logic;
      Sub_A4nSW14                  : in    std_logic;
      Sub_A5nSW15                  : in    std_logic;
      Sub_A6nSW12                  : in    std_logic;
      Sub_A7nSW13                  : in    std_logic;
      nResetnSW0                   : in    std_logic;
      SW1                          : in    std_logic;
      nDSnSW2                      : in    std_logic;
      BClocknSW3                   : in    std_logic;
      RnWnSW4                      : in    std_logic;
      SW5                          : in    std_logic;
      A4nSW6                       : in    std_logic;
      SW7                          : in    std_logic;
      NEWDATA                      : in    std_logic;
      FC_Str                       : in    std_logic;
      FC0                          : in    std_logic;
      FC1                          : in    std_logic;
      FC2                          : in    std_logic;
      FC3                          : in    std_logic;
      FC4                          : in    std_logic;
      FC5                          : in    std_logic;
      VG_A3nFC6                    : in    std_logic;
      FC7                          : in    std_logic;
      SD                           : in    std_logic;
      nDRQ2                        : out   std_logic;
      VG_SK0nSWF6                  : in    std_logic;
      VG_SK1nSWF5                  : in    std_logic;
      VG_SK2nSWF4                  : in    std_logic;
      VG_SK3nSWF3                  : in    std_logic;
      VG_SK4nSWF2                  : in    std_logic;
      VG_SK5nSWF1                  : in    std_logic;
      VG_SK6nSWF0                  : in    std_logic;
      VG_SK7                       : in    std_logic;
      VG_ID0nRes                   : in    std_logic;
      VG_ID1nIW3                   : in    std_logic;
      VG_ID2nIW2                   : in    std_logic;
      VG_ID3nIW1                   : in    std_logic;
      VG_ID4nIW0                   : in    std_logic;
      VG_ID5                       : in    std_logic;
      VG_ID6                       : in    std_logic;
      VG_ID7nSWF7                  : in    std_logic;
      D0nIW14                      : inout std_logic;
      D1nIW15                      : inout std_logic;
      D2nIW12                      : inout std_logic;
      D3nIW13                      : inout std_logic;
      D4nIW10                      : inout std_logic;
      D5nIW11                      : inout std_logic;
      D6nIW8                       : inout std_logic;
      D7nIW9                       : inout std_logic;
      BBA_DIR                      : out   std_logic;
      BBB_DIR                      : out   std_logic;
      BBC_DIR                      : out   std_logic;
      BBD_DIR                      : out   std_logic;
      BBE_DIR                      : out   std_logic;
      BBG_DIR                      : out   std_logic;
      BBH_DIR                      : out   std_logic;
      nBB_EN                       : out   std_logic;
      DRDY                         : out   std_logic;
      SRQ3                         : out   std_logic;
      DRQ                          : out   std_logic;
      INTERL                       : out   std_logic;
      DTACK                        : out   std_logic;
      nDRDY2                       : out   std_logic;
      SEND_EN                      : out   std_logic;
      SEND_STR                     : out   std_logic;
      DSP_CRDY_W                   : out   std_logic;
      DSP_CREQ_W                   : out   std_logic;
      DSP_CACK_R                   : in    std_logic;
      DSP_CSTR_R                   : in    std_logic;
      DSP_D_R0                     : in    std_logic;
      DSP_D_R1                     : in    std_logic;
      DSP_D_R2                     : in    std_logic;
      DSP_D_R3                     : in    std_logic;
      DSP_D_R4                     : in    std_logic;
      DSP_D_R5                     : in    std_logic;
      DSP_D_R6                     : in    std_logic;
      DSP_D_R7                     : in    std_logic;
      DSP_CRDY_R                   : in    std_logic;
      DSP_CREQ_R                   : in    std_logic;
      DSP_CACK_W                   : out   std_logic;
      DSP_CSTR_W                   : out   std_logic;
      DSP_D_W0                     : out   std_logic;
      DSP_D_W1                     : out   std_logic;
      DSP_D_W2                     : out   std_logic;
      DSP_D_W3                     : out   std_logic;
      DSP_D_W4                     : out   std_logic;
      DSP_D_W5                     : out   std_logic;
      DSP_D_W6                     : out   std_logic;
      DSP_D_W7                     : out   std_logic;
      DSP_DIR_D                    : out   std_logic;
      DSP_DIR_STRACK               : out   std_logic;
      DSP_DIR_REQRDY               : out   std_logic;
      led1                         : out   std_logic;
      led2                         : out   std_logic;
      led3                         : out   std_logic;
      led4                         : out   std_logic;
      piggy_io                     : out   std_logic_vector(7 downto 0);
      VG_A4                        : in    std_logic;
      VG_A1                        : in    std_logic;
      VG_A2                        : in    std_logic;
      VG_A0                        : in    std_logic;
      rs232_rx_i                   : in    std_logic;
      rs232_tx_o                   : out   std_logic;
      eeprom_data                  : in    std_logic;
      eeprom_dclk                  : out   std_logic;
      eeprom_ncs                   : out   std_logic;
      eeprom_asdi                  : out   std_logic;
      Testpin_J60                  : out   std_logic;
      TCXO1_CNTRL                  : out   std_logic;
      TCXO2_CNTRL                  : out   std_logic;
      nGPIO1_R                     : in    std_logic;
      nGPIO1_W                     : out   std_logic;
      nGPIO2_R                     : in    std_logic;
      nGPIO2_W                     : out   std_logic;
      nI2C_SCL                     : out   std_logic;
      nI2C_SDA                     : out   std_logic;
      nSPI_SS                      : out   std_logic;
      nSPI_MISO                    : in    std_logic;
      nSPI_MOSI                    : out   std_logic;
      nSPI_SCK                     : out   std_logic;
      opt1_los                     : in    std_logic;
      opt1_rx                      : in    std_logic;
      opt1_tx                      : out   std_logic;
      opt2_los                     : in    std_logic;
      opt2_rx                      : in    std_logic;
      opt2_tx                      : out   std_logic);
  end component;

  -- component ports
  signal trig1_in                     : std_logic;
  signal trig2_out                    : std_logic;
  signal trig1_out                    : std_logic;
  signal trig2_in                     : std_logic;
  signal clk0                         : std_logic;
  signal clk1                         : std_logic;
  signal hf1_in                       : std_logic;
  signal hf2_in                       : std_logic;
  signal uC_Link_D                    : std_logic_vector(7 downto 0);
  signal uC_Link_A                    : std_logic_vector(7 downto 0);
  signal nuC_Link_ACK_R               : std_logic;
  signal nuC_Link_ACK_W               : std_logic;
  signal nuC_Link_MRQ_R               : std_logic;
  signal nuC_Link_MRQ_W               : std_logic;
  signal nuC_Link_RnW_R               : std_logic;
  signal nuC_Link_RnW_W               : std_logic;
  signal nuC_Link_STROBE_R            : std_logic;
  signal nuC_Link_STROBE_W            : std_logic;
  signal uC_Link_DIR_D, uC_Link_DIR_A : std_logic;
  signal nuC_Link_EN_CTRL_A           : std_logic;
  signal uC_Link_EN_DA                : std_logic;
  signal Piggy_Clk1                   : std_logic;
  signal Piggy_RnW1                   : std_logic;
  signal Piggy_RnW2                   : std_logic;
  signal Piggy_Strb2                  : std_logic;
  signal Piggy_Strb1                  : std_logic;
  signal Piggy_Ack1                   : std_logic;
  signal Piggy_Ack2                   : std_logic;
  signal A2nSW8                       : std_logic;
  signal A3nSW9                       : std_logic;
  signal A0nSW10                      : std_logic;
  signal A1nSW11                      : std_logic;
  signal Sub_A0nIW6                   : std_logic;
  signal Sub_A1nIW7                   : std_logic;
  signal Sub_A2nIW4                   : std_logic;
  signal Sub_A3nIW5                   : std_logic;
  signal Sub_A4nSW14                  : std_logic;
  signal Sub_A5nSW15                  : std_logic;
  signal Sub_A6nSW12                  : std_logic;
  signal Sub_A7nSW13                  : std_logic;
  signal nResetnSW0                   : std_logic;
  signal SW1                          : std_logic;
  signal nDSnSW2                      : std_logic;
  signal BClocknSW3                   : std_logic;
  signal RnWnSW4                      : std_logic;
  signal SW5                          : std_logic;
  signal A4nSW6                       : std_logic;
  signal SW7                          : std_logic;
  signal NEWDATA                      : std_logic;
  signal FC_Str                       : std_logic;
  signal FC0                          : std_logic;
  signal FC1                          : std_logic;
  signal FC2                          : std_logic;
  signal FC3                          : std_logic;
  signal FC4                          : std_logic;
  signal FC5                          : std_logic;
  signal VG_A3nFC6                    : std_logic;
  signal FC7                          : std_logic;
  signal SD                           : std_logic;
  signal nDRQ2                        : std_logic;
  signal VG_SK0nSWF6                  : std_logic;
  signal VG_SK1nSWF5                  : std_logic;
  signal VG_SK2nSWF4                  : std_logic;
  signal VG_SK3nSWF3                  : std_logic;
  signal VG_SK4nSWF2                  : std_logic;
  signal VG_SK5nSWF1                  : std_logic;
  signal VG_SK6nSWF0                  : std_logic;
  signal VG_SK7                       : std_logic;
  signal VG_ID0nRes                   : std_logic;
  signal VG_ID1nIW3                   : std_logic;
  signal VG_ID2nIW2                   : std_logic;
  signal VG_ID3nIW1                   : std_logic;
  signal VG_ID4nIW0                   : std_logic;
  signal VG_ID5                       : std_logic;
  signal VG_ID6                       : std_logic;
  signal VG_ID7nSWF7                  : std_logic;
  signal D0nIW14                      : std_logic;
  signal D1nIW15                      : std_logic;
  signal D2nIW12                      : std_logic;
  signal D3nIW13                      : std_logic;
  signal D4nIW10                      : std_logic;
  signal D5nIW11                      : std_logic;
  signal D6nIW8                       : std_logic;
  signal D7nIW9                       : std_logic;
  signal BBA_DIR                      : std_logic;
  signal BBB_DIR                      : std_logic;
  signal BBC_DIR                      : std_logic;
  signal BBD_DIR                      : std_logic;
  signal BBE_DIR                      : std_logic;
  signal BBG_DIR                      : std_logic;
  signal BBH_DIR                      : std_logic;
  signal nBB_EN                       : std_logic;
  signal DRDY                         : std_logic;
  signal SRQ3                         : std_logic;
  signal DRQ                          : std_logic;
  signal INTERL                       : std_logic;
  signal DTACK                        : std_logic;
  signal nDRDY2                       : std_logic;
  signal SEND_EN                      : std_logic;
  signal SEND_STR                     : std_logic;
  signal DSP_CRDY_W                   : std_logic;
  signal DSP_CREQ_W                   : std_logic;
  signal DSP_CACK_R                   : std_logic;
  signal DSP_CSTR_R                   : std_logic;
  signal DSP_D_R0                     : std_logic;
  signal DSP_D_R1                     : std_logic;
  signal DSP_D_R2                     : std_logic;
  signal DSP_D_R3                     : std_logic;
  signal DSP_D_R4                     : std_logic;
  signal DSP_D_R5                     : std_logic;
  signal DSP_D_R6                     : std_logic;
  signal DSP_D_R7                     : std_logic;
  signal DSP_CRDY_R                   : std_logic;
  signal DSP_CREQ_R                   : std_logic;
  signal DSP_CACK_W                   : std_logic;
  signal DSP_CSTR_W                   : std_logic;
  signal DSP_D_W0                     : std_logic;
  signal DSP_D_W1                     : std_logic;
  signal DSP_D_W2                     : std_logic;
  signal DSP_D_W3                     : std_logic;
  signal DSP_D_W4                     : std_logic;
  signal DSP_D_W5                     : std_logic;
  signal DSP_D_W6                     : std_logic;
  signal DSP_D_W7                     : std_logic;
  signal DSP_DIR_D                    : std_logic;
  signal DSP_DIR_STRACK               : std_logic;
  signal DSP_DIR_REQRDY               : std_logic;
  signal led1                         : std_logic;
  signal led2                         : std_logic;
  signal led3                         : std_logic;
  signal led4                         : std_logic;
  signal piggy_io                     : std_logic_vector(7 downto 0);
  signal VG_A4                        : std_logic;
  signal VG_A1                        : std_logic;
  signal VG_A2                        : std_logic;
  signal VG_A0                        : std_logic;
  signal rs232_rx_i                   : std_logic;
  signal rs232_tx_o                   : std_logic;
  signal eeprom_data                  : std_logic;
  signal eeprom_dclk                  : std_logic;
  signal eeprom_ncs                   : std_logic;
  signal eeprom_asdi                  : std_logic;
  signal Testpin_J60                  : std_logic;
  signal TCXO1_CNTRL                  : std_logic;
  signal TCXO2_CNTRL                  : std_logic;
  signal nGPIO1_R                     : std_logic;
  signal nGPIO1_W                     : std_logic;
  signal nGPIO2_R                     : std_logic;
  signal nGPIO2_W                     : std_logic;
  signal nI2C_SCL                     : std_logic;
  signal nI2C_SDA                     : std_logic;
  signal nSPI_SS                      : std_logic;
  signal nSPI_MISO                    : std_logic;
  signal nSPI_MOSI                    : std_logic;
  signal nSPI_SCK                     : std_logic;
  signal opt1_los                     : std_logic;
  signal opt1_rx                      : std_logic;
  signal opt1_tx                      : std_logic;
  signal opt2_los                     : std_logic;
  signal opt2_rx                      : std_logic;
  signal opt2_tx                      : std_logic;

  -- FAB Component
  component fab_adc_dac_firmware02_top
    generic (
      clk_divider_width : integer);
    port (
      clk_i        : in    std_logic;
      nrst_i       : in    std_logic;
      oe_i         : in    std_logic;
      bus_alpha_io : inout std_logic_vector (7 downto 0);
      adr_alpha_i  : in    std_logic_vector (3 downto 0);
      rnw_alpha_i  : in    std_logic;
      str_alpha_i  : in    std_logic;
      bus_beta_io  : inout std_logic_vector (7 downto 0);
      adr_beta_i   : in    std_logic_vector (3 downto 0);
      rnw_beta_i   : in    std_logic;
      str_beta_i   : in    std_logic;
      adc1d        : in    std_logic_vector (13 downto 0);
      dac1d        : out   std_logic_vector (13 downto 0);
      adc2d        : in    std_logic_vector (13 downto 0);
      dac2d        : out   std_logic_vector (13 downto 0);
      adc1sw       : out   std_logic_vector (3 downto 0);
      adc2sw       : out   std_logic_vector (3 downto 0);
      adc1clk      : out   std_logic;
      adc2clk      : out   std_logic;
      dac1clk      : out   std_logic;
      dac2clk      : out   std_logic;
      adc1of       : in    std_logic;
      adc2of       : in    std_logic;
      adc1shdn     : out   std_logic;
      adc2shdn     : out   std_logic;
      dac1slp      : out   std_logic;
      dac2slp      : out   std_logic;
      tp1          : out   std_logic;
      tp2          : out   std_logic;
      tp3          : in    std_logic;
      tp4          : in    std_logic;
      tp5          : in    std_logic;
      tp6          : in    std_logic;
      tp7          : in    std_logic;
      ucl_rnw      : in    std_logic;
      ucl_str      : in    std_logic;
      ucl_ack      : out   std_logic;
      ucl_mrq      : in    std_logic);
  end component;

  -- FAB Signals
  constant clk_divider_width : integer := 8;

  signal clk_i        : std_logic;
  signal nrst_i       : std_logic;
  signal oe_i         : std_logic;
  signal bus_alpha_io : std_logic_vector (7 downto 0);
  signal adr_alpha_i  : std_logic_vector (3 downto 0);
  signal rnw_alpha_i  : std_logic;
  signal str_alpha_i  : std_logic;
  signal bus_beta_io  : std_logic_vector (7 downto 0);
  signal adr_beta_i   : std_logic_vector (3 downto 0);
  signal rnw_beta_i   : std_logic;
  signal str_beta_i   : std_logic;
  signal adc1d        : std_logic_vector (13 downto 0);
  signal dac1d        : std_logic_vector (13 downto 0);
  signal adc2d        : std_logic_vector (13 downto 0);
  signal dac2d        : std_logic_vector (13 downto 0);
  signal adc1sw       : std_logic_vector (3 downto 0);
  signal adc2sw       : std_logic_vector (3 downto 0);
  signal adc1clk      : std_logic;
  signal adc2clk      : std_logic;
  signal dac1clk      : std_logic;
  signal dac2clk      : std_logic;
  signal adc1of       : std_logic;
  signal adc2of       : std_logic;
  signal adc1shdn     : std_logic;
  signal adc2shdn     : std_logic;
  signal dac1slp      : std_logic;
  signal dac2slp      : std_logic;
  signal tp1          : std_logic;
  signal tp2          : std_logic;
  signal tp3          : std_logic;
  signal tp4          : std_logic;
  signal tp5          : std_logic;
  signal tp6          : std_logic;
  signal tp7          : std_logic;
  signal ucl_rnw      : std_logic;
  signal ucl_str      : std_logic;
  signal ucl_ack      : std_logic;
  signal ucl_mrq      : std_logic;

  -- clock
  signal sim_clk : std_logic := '1';
  signal sim_rst : std_logic := '1';

  signal sim_rs232_tx_o    : std_logic;
  signal sim_rs232_tx_str  : std_logic;
  signal nsim_rs232_tx_o   : std_logic;
  signal sim_rs232_tx_data : std_logic_vector (7 downto 0);

  procedure command_cycle (
    addr              : in  std_logic_vector (15 downto 0);
    data              : in  std_logic_vector (7 downto 0);
    signal rs232_data : out std_logic_vector (7 downto 0);
    signal rs232_strb : out std_logic
    )is

  begin

    wait for 500 ns;
    rs232_data <= addr (15 downto 8);
    rs232_strb <= '1';
    wait for 500 ns;
    rs232_strb <= '0';

    wait for 500 ns;
    rs232_data <= addr (7 downto 0);
    rs232_strb <= '1';
    wait for 500 ns;
    rs232_strb <= '0';

    wait for 500 ns;
    rs232_data <= data;
    rs232_strb <= '1';
    wait for 500 ns;
    rs232_strb <= '0';

    wait for 500 ns;
    rs232_data <= data xor addr (7 downto 0) xor addr (15 downto 8);
    rs232_strb <= '1';
    wait for 500 ns;
    rs232_strb <= '0';

  end command_cycle;
  
begin  -- fib_agc_top_tb_arch

  -- component instantiation
  fib_agc_top_inst : fib_agc_top
    generic map (
      clk_freq_in_hz   => clk_freq_in_hz,
      baud_rate        => baud_rate,
      firmware_id      => firmware_id,
      firmware_version => firmware_version)
    port map (
      trig1_in           => trig1_in,
      trig2_out          => trig2_out,
      trig1_out          => trig1_out,
      trig2_in           => trig2_in,
      clk0               => clk0,
      clk1               => clk1,
      hf1_in             => hf1_in,
      hf2_in             => hf2_in,
      uC_Link_D          => uC_Link_D,
      uC_Link_A          => uC_Link_A,
      nuC_Link_ACK_R     => nuC_Link_ACK_R,
      nuC_Link_ACK_W     => nuC_Link_ACK_W,
      nuC_Link_MRQ_R     => nuC_Link_MRQ_R,
      nuC_Link_MRQ_W     => nuC_Link_MRQ_W,
      nuC_Link_RnW_R     => nuC_Link_RnW_R,
      nuC_Link_RnW_W     => nuC_Link_RnW_W,
      nuC_Link_STROBE_R  => nuC_Link_STROBE_R,
      nuC_Link_STROBE_W  => nuC_Link_STROBE_W,
      uC_Link_DIR_D      => uC_Link_DIR_D,
      uC_Link_DIR_A      => uC_Link_DIR_A,
      nuC_Link_EN_CTRL_A => nuC_Link_EN_CTRL_A,
      uC_Link_EN_DA      => uC_Link_EN_DA,
      Piggy_Clk1         => Piggy_Clk1,
      Piggy_RnW1         => Piggy_RnW1,
      Piggy_RnW2         => Piggy_RnW2,
      Piggy_Strb2        => Piggy_Strb2,
      Piggy_Strb1        => Piggy_Strb1,
      Piggy_Ack1         => Piggy_Ack1,
      Piggy_Ack2         => Piggy_Ack2,
      A2nSW8             => A2nSW8,
      A3nSW9             => A3nSW9,
      A0nSW10            => A0nSW10,
      A1nSW11            => A1nSW11,
      Sub_A0nIW6         => Sub_A0nIW6,
      Sub_A1nIW7         => Sub_A1nIW7,
      Sub_A2nIW4         => Sub_A2nIW4,
      Sub_A3nIW5         => Sub_A3nIW5,
      Sub_A4nSW14        => Sub_A4nSW14,
      Sub_A5nSW15        => Sub_A5nSW15,
      Sub_A6nSW12        => Sub_A6nSW12,
      Sub_A7nSW13        => Sub_A7nSW13,
      nResetnSW0         => nResetnSW0,
      SW1                => SW1,
      nDSnSW2            => nDSnSW2,
      BClocknSW3         => BClocknSW3,
      RnWnSW4            => RnWnSW4,
      SW5                => SW5,
      A4nSW6             => A4nSW6,
      SW7                => SW7,
      NEWDATA            => NEWDATA,
      FC_Str             => FC_Str,
      FC0                => FC0,
      FC1                => FC1,
      FC2                => FC2,
      FC3                => FC3,
      FC4                => FC4,
      FC5                => FC5,
      VG_A3nFC6          => VG_A3nFC6,
      FC7                => FC7,
      SD                 => SD,
      nDRQ2              => nDRQ2,
      VG_SK0nSWF6        => VG_SK0nSWF6,
      VG_SK1nSWF5        => VG_SK1nSWF5,
      VG_SK2nSWF4        => VG_SK2nSWF4,
      VG_SK3nSWF3        => VG_SK3nSWF3,
      VG_SK4nSWF2        => VG_SK4nSWF2,
      VG_SK5nSWF1        => VG_SK5nSWF1,
      VG_SK6nSWF0        => VG_SK6nSWF0,
      VG_SK7             => VG_SK7,
      VG_ID0nRes         => VG_ID0nRes,
      VG_ID1nIW3         => VG_ID1nIW3,
      VG_ID2nIW2         => VG_ID2nIW2,
      VG_ID3nIW1         => VG_ID3nIW1,
      VG_ID4nIW0         => VG_ID4nIW0,
      VG_ID5             => VG_ID5,
      VG_ID6             => VG_ID6,
      VG_ID7nSWF7        => VG_ID7nSWF7,
      D0nIW14            => D0nIW14,
      D1nIW15            => D1nIW15,
      D2nIW12            => D2nIW12,
      D3nIW13            => D3nIW13,
      D4nIW10            => D4nIW10,
      D5nIW11            => D5nIW11,
      D6nIW8             => D6nIW8,
      D7nIW9             => D7nIW9,
      BBA_DIR            => BBA_DIR,
      BBB_DIR            => BBB_DIR,
      BBC_DIR            => BBC_DIR,
      BBD_DIR            => BBD_DIR,
      BBE_DIR            => BBE_DIR,
      BBG_DIR            => BBG_DIR,
      BBH_DIR            => BBH_DIR,
      nBB_EN             => nBB_EN,
      DRDY               => DRDY,
      SRQ3               => SRQ3,
      DRQ                => DRQ,
      INTERL             => INTERL,
      DTACK              => DTACK,
      nDRDY2             => nDRDY2,
      SEND_EN            => SEND_EN,
      SEND_STR           => SEND_STR,
      DSP_CRDY_W         => DSP_CRDY_W,
      DSP_CREQ_W         => DSP_CREQ_W,
      DSP_CACK_R         => DSP_CACK_R,
      DSP_CSTR_R         => DSP_CSTR_R,
      DSP_D_R0           => DSP_D_R0,
      DSP_D_R1           => DSP_D_R1,
      DSP_D_R2           => DSP_D_R2,
      DSP_D_R3           => DSP_D_R3,
      DSP_D_R4           => DSP_D_R4,
      DSP_D_R5           => DSP_D_R5,
      DSP_D_R6           => DSP_D_R6,
      DSP_D_R7           => DSP_D_R7,
      DSP_CRDY_R         => DSP_CRDY_R,
      DSP_CREQ_R         => DSP_CREQ_R,
      DSP_CACK_W         => DSP_CACK_W,
      DSP_CSTR_W         => DSP_CSTR_W,
      DSP_D_W0           => DSP_D_W0,
      DSP_D_W1           => DSP_D_W1,
      DSP_D_W2           => DSP_D_W2,
      DSP_D_W3           => DSP_D_W3,
      DSP_D_W4           => DSP_D_W4,
      DSP_D_W5           => DSP_D_W5,
      DSP_D_W6           => DSP_D_W6,
      DSP_D_W7           => DSP_D_W7,
      DSP_DIR_D          => DSP_DIR_D,
      DSP_DIR_STRACK     => DSP_DIR_STRACK,
      DSP_DIR_REQRDY     => DSP_DIR_REQRDY,
      led1               => led1,
      led2               => led2,
      led3               => led3,
      led4               => led4,
      piggy_io           => piggy_io,
      VG_A4              => VG_A4,
      VG_A1              => VG_A1,
      VG_A2              => VG_A2,
      VG_A0              => VG_A0,
      rs232_rx_i         => nsim_rs232_tx_o,
      rs232_tx_o         => rs232_tx_o,
      eeprom_data        => eeprom_data,
      eeprom_dclk        => eeprom_dclk,
      eeprom_ncs         => eeprom_ncs,
      eeprom_asdi        => eeprom_asdi,
      Testpin_J60        => Testpin_J60,
      TCXO1_CNTRL        => TCXO1_CNTRL,
      TCXO2_CNTRL        => TCXO2_CNTRL,
      nGPIO1_R           => nGPIO1_R,
      nGPIO1_W           => nGPIO1_W,
      nGPIO2_R           => nGPIO2_R,
      nGPIO2_W           => nGPIO2_W,
      nI2C_SCL           => nI2C_SCL,
      nI2C_SDA           => nI2C_SDA,
      nSPI_SS            => nSPI_SS,
      nSPI_MISO          => nSPI_MISO,
      nSPI_MOSI          => nSPI_MOSI,
      nSPI_SCK           => nSPI_SCK,
      opt1_los           => opt1_los,
      opt1_rx            => opt1_rx,
      opt1_tx            => opt1_tx,
      opt2_los           => opt2_los,
      opt2_rx            => opt2_rx,
      opt2_tx            => opt2_tx);

  fab_adc_dac_firmware02_top_inst : fab_adc_dac_firmware02_top
    generic map (
      clk_divider_width => clk_divider_width)
    port map (
      clk_i        => clk_i,
      nrst_i       => nrst_i,
      oe_i         => oe_i,
      bus_alpha_io => bus_alpha_io,
      adr_alpha_i  => adr_alpha_i,
      rnw_alpha_i  => rnw_alpha_i,
      str_alpha_i  => str_alpha_i,
      bus_beta_io  => bus_beta_io,
      adr_beta_i   => adr_beta_i,
      rnw_beta_i   => rnw_beta_i,
      str_beta_i   => str_beta_i,
      adc1d        => adc1d,
      dac1d        => dac1d,
      adc2d        => adc2d,
      dac2d        => dac2d,
      adc1sw       => adc1sw,
      adc2sw       => adc2sw,
      adc1clk      => adc1clk,
      adc2clk      => adc2clk,
      dac1clk      => dac1clk,
      dac2clk      => dac2clk,
      adc1of       => adc1of,
      adc2of       => adc2of,
      adc1shdn     => adc1shdn,
      adc2shdn     => adc2shdn,
      dac1slp      => dac1slp,
      dac2slp      => dac2slp,
      tp1          => tp1,
      tp2          => tp2,
      tp3          => tp3,
      tp4          => tp4,
      tp5          => tp5,
      tp6          => tp6,
      tp7          => tp7,
      ucl_rnw      => ucl_rnw,
      ucl_str      => ucl_str,
      ucl_ack      => ucl_ack,
      ucl_mrq      => ucl_mrq);

  simulation_fub_rs232_tx_inst : fub_rs232_tx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => baud_rate
      )
    port map (
      clk_i      => sim_clk,
      rst_i      => sim_rst,
      rs232_tx_o => sim_rs232_tx_o,
      fub_str_i  => sim_rs232_tx_str,
      fub_busy_o => open,
      fub_data_i => sim_rs232_tx_data
      );

  -- clock generation
  sim_clk <= not sim_clk after clk_period / 2;
  sim_rst <= '1', '0' after 200 ns;
  hf1_in  <= sim_clk;
  clk0    <= sim_clk;
  clk_i   <= Piggy_Clk1;
  nrst_i  <= Piggy_Ack2;
  oe_i    <= Piggy_Ack1;

  uC_Link_A   <= bus_alpha_io;
  adr_alpha_i <= piggy_io (7 downto 4);
  rnw_alpha_i <= Piggy_RnW1;
  str_alpha_i <= Piggy_Strb1;

  uC_Link_D  <= bus_beta_io;
  adr_beta_i <= piggy_io (3 downto 0);
  rnw_beta_i <= Piggy_RnW2;
  str_beta_i <= Piggy_Strb2;

--  adc2d <= "01001001110100", "00011101111000" after 800 ns, "11111111011111" after 803200 ps, "01110010110010" after 806400 ps, "11010001100101" after 808000 ps, "00011010111010" after 809600 ps;  -- "11001111100101" after 811200 ps;

  adc1d <= "01111101011111", "00000111010111" after 1 us;  -- first 0dBm,
                                                           -- then -30dBm
  adc2d <= "00000111111111", "01111111111111" after 1 us;  -- first -30dBm,
                                                           -- then 0dBm

--  adc2d <= std_logic_vector(to_signed(1000, 14)),
--           std_logic_vector(to_signed(7000, 14))   after 5000 ns;

  nsim_rs232_tx_o <= not sim_rs232_tx_o;

  p_command_cycle : process
  begin  -- process p_command_cycle

    command_cycle (x"0012", x"01", sim_rs232_tx_data, sim_rs232_tx_str);
    wait for 10 us;

    -- set desired amplitude value to 4000 decimal
--    command_cycle (x"0005", x"0F", sim_rs232_tx_data, sim_rs232_tx_str);
--    wait for 10 us;

--    command_cycle (x"0004", x"A0", sim_rs232_tx_data, sim_rs232_tx_str);
--    wait for 10 us;

--    command_cycle (x"000D", x"01", sim_rs232_tx_data, sim_rs232_tx_str);
--    wait for 10 us;

--    command_cycle (x"000C", x"F4", sim_rs232_tx_data, sim_rs232_tx_str);
--    wait for 10 us;

--    command_cycle (x"000F", x"32", sim_rs232_tx_data, sim_rs232_tx_str);
--    wait for 10 us;

    command_cycle (x"000B", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
    wait for 10 us;
    command_cycle (x"000A", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
    wait for 10 us;

    command_cycle (x"0009", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
    wait for 10 us;
    command_cycle (x"0008", x"04", sim_rs232_tx_data, sim_rs232_tx_str);
    wait for 10 us;

    command_cycle (x"0012", x"00", sim_rs232_tx_data, sim_rs232_tx_str);

--    -- set update rate to 300 us
--    command_cycle (x"0011", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"0010", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"0009", x"3A", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"0008", x"98", sim_rs232_tx_data, sim_rs232_tx_str);

--    wait for 30 us;

    -- set update rate to 5 ms
--    command_cycle (x"0011", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"0010", x"03", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"0009", x"D0", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"0008", x"90", sim_rs232_tx_data, sim_rs232_tx_str);

--    -- read cycle
--    command_cycle (x"FFF1", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"FFF2", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"FFF3", x"00", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"FFF4", x"13", sim_rs232_tx_data, sim_rs232_tx_str);
--    command_cycle (x"FFF0", x"02", sim_rs232_tx_data, sim_rs232_tx_str);

    wait;
    
  end process p_command_cycle;
  
end fib_agc_top_tb_arch;
