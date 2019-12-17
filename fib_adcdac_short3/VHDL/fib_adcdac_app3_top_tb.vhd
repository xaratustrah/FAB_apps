
-------------------------------------------------------------------------------
-- Title      : Testbench for design "fib_adcdac_app3_top"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fib_adcdac_app3_top_tb.vhd
-- Author     :   <ssanjari@BTPC088>
-- Company    : 
-- Created    : 2007-05-16
-- Last update: 2007-06-29
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-05-16  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.dds_synthesizer_pkg.all;
use work.clk_divider_pkg.all;

-------------------------------------------------------------------------------

entity fib_adcdac_app3_top_tb is

end fib_adcdac_app3_top_tb;

-------------------------------------------------------------------------------

architecture fib_adcdac_app3_top_tb_arch of fib_adcdac_app3_top_tb is

  component fib_adcdac_app3_top
    generic (
      clk_freq_in_hz   : real;
      reset_clocks     : integer;
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
      uC_Link_A                    : out   std_logic_vector(7 downto 0);
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
      nSPI_EN                      : out   std_logic;
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

  -- component generics
  constant clk_freq_in_hz   : real    := 50.0E6;
  constant reset_clocks     : integer := 20;
  constant firmware_id      : integer := 10;
  constant firmware_version : integer := 5;

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
  signal nSPI_EN                      : std_logic;
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
      oe_i         : out   std_logic;
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


  signal dds1_data : std_logic_vector (13 downto 0);
  signal dds2_data : std_logic_vector (13 downto 0);

  signal dds_phase : std_logic_vector (13 downto 0);
  signal ftw       : std_logic_vector (13 downto 0);
  signal dds_rst   : std_logic;
  signal sim_rst   : std_logic;
  signal dds_clk   : std_logic;

  -- clock
  signal Clk : std_logic := '1';

--  signal test : std_logic;

begin  -- fib_adcdac_app3_top_tb_arch

  -- component instantiation
  DUT : fib_adcdac_app3_top
    generic map (
      clk_freq_in_hz   => clk_freq_in_hz,
      reset_clocks     => reset_clocks,
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
      rs232_rx_i         => rs232_rx_i,
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
      nSPI_EN            => nSPI_EN,
      nSPI_MISO          => nSPI_MISO,
      nSPI_MOSI          => nSPI_MOSI,
      nSPI_SCK           => nSPI_SCK,
      opt1_los           => opt1_los,
      opt1_rx            => opt1_rx,
      opt1_tx            => opt1_tx,
      opt2_los           => opt2_los,
      opt2_rx            => opt2_rx,
      opt2_tx            => opt2_tx);

  fab_adc_dac_firmware02_top_1 : fab_adc_dac_firmware02_top
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

  dds_synthesizer_1 : dds_synthesizer
    generic map (
      ftw_width => 14)
    port map (
      clk_i   => dds_clk,
      rst_i   => dds_rst,
      ftw_i   => ftw,
      phase_i => (others => '0'),
      phase_o => dds_phase,
      ampl_o  => dds1_data);

  dds_synthesizer_2 : dds_synthesizer
    generic map (
      ftw_width => 14)
    port map (
      clk_i   => dds_clk,
      rst_i   => dds_rst,
      ftw_i   => ftw,
      phase_i => "01000000000000",
      phase_o => open,
      ampl_o  => dds2_data);

  divider1 : clk_divider
    generic map (
      clk_divider_width => 2)
    port map (
      clk_div_i => "11",
      rst_i     => sim_rst,
      clk_i     => Piggy_Clk1,
      clk_o     => dds_clk);

--  ftw <= conv_std_logic_vector (1600, 14);
  ftw <= std_logic_vector (to_signed(200, 14));
--  ftw <= std_logic_vector (to_signed(25, 14));

  -- clock generation

  Clk     <= not Clk after 10 ns;
  sim_rst <= '1', '0' after 100 ns;
  hf1_in  <= Clk;
  --clk0    <= Clk;
  clk_i   <= Piggy_Clk1;
  nrst_i  <= Piggy_Ack2;
  oe_i    <= Piggy_Ack1;
  dds_rst <= not Piggy_Ack2;

--  adc1d <= "01001000110100", "00011111111000" after 800 ns, "11111111111111" after 803200 ps,
--           "01110010110000" after 806400 ps, "11010001100001" after 808000 ps,
--           "00011010111000" after 809600 ps;  -- "11001101100101" after 811200 ps;

--  adc2d <= "01001001110100", "00011101111000" after 800 ns, "11111111011111" after 803200 ps,
--           "01110010110010" after 806400 ps, "11010001100101" after 808000 ps,
--           "00011010111010" after 809600 ps;  -- "11001111100101" after 811200 ps;

  adc1d <= std_logic_vector(shift_right(signed(dds1_data),1));
  adc2d <= std_logic_vector(shift_right(signed(dds2_data),1));

--  adc1d <= conv_std_logic_vector(1000, 14);
--  adc2d <= conv_std_logic_vector(2000, 14);

--  adc1d <= dds_phase;
--  adc1d <= (others => '1');

--  bus_alpha_io <= uC_Link_A when Piggy_RnW1 = '0' else (others => 'Z');
  bus_alpha_io <= uC_Link_A;
  adr_alpha_i  <= piggy_io (7 downto 4);
  rnw_alpha_i  <= Piggy_RnW1;
  str_alpha_i  <= Piggy_Strb1;

--  bus_beta_io <= uC_Link_D when Piggy_RnW2 = '0' else (others => 'Z');
  uC_Link_D  <= bus_beta_io;
  adr_beta_i <= piggy_io (3 downto 0);
  rnw_beta_i <= Piggy_RnW2;
  str_beta_i <= Piggy_Strb2;

--  process(clk_i)
--  begin
--    if clk_i'event and clk_i = '1' then  -- rising clock edge
--      test <= piggy_io(4);
--    end if;
--  end process;

--  process(clk_i)
--  begin
--    if clk_i'event and clk_i = '1' then  -- rising clock edge
--        if adr_alpha_i = "0000" then
--          adr_alpha_i(3 downto 0) <= "0001";
--        else
--          adr_alpha_i(3 downto 0) <= "0000";
--        end if;
--    end if;
--  end process;
  

end fib_adcdac_app3_top_tb_arch;
