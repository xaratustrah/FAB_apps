-------------------------------------------------------------------------------
-- Title      : Testbench for design "digital_short_rev2_top"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : digital_short_rev2_top_tb.vhd
-- Author     :   <ssanjari@BTPC088>
-- Company    : 
-- Created    : 2007-01-12
-- Last update: 2007-03-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-01-12  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-------------------------------------------------------------------------------

entity digital_short_rev2_top_tb is

end digital_short_rev2_top_tb;

-------------------------------------------------------------------------------

architecture digital_short_rev2_top_tb of digital_short_rev2_top_tb is

  component digital_short_rev2_top
    generic (
      system_clk_freq_in_hz      : real;
      firmware_id                : integer;
      firmware_version           : integer;
      clk_divider_width_toplevel : integer;
      reset_clks_toplevel        : integer);
    port (
      trig1_in                     : in    std_logic;
      trig2_out                    : out   std_logic;
      clk0                         : in    std_logic;
      hf_in                        : in    std_logic;
      uC_Link_D                    : inout std_logic_vector(7 downto 0);
      uC_Link_A                    : inout std_logic_vector(7 downto 0);
      Piggy_Clk1                   : out   std_logic;
      Piggy_RnW1                   : out   std_logic;
      Piggy_Strb1                  : out   std_logic;
      Piggy_Ack1                   : out   std_logic;
      Piggy_Ack2                   : out   std_logic;
      uC_Link_DIR_D, uC_Link_DIR_A : out   std_logic;
      nuC_Link_EN_CTRL_A           : out   std_logic;
      uC_Link_EN_DA                : out   std_logic;
      A2nSW8                       : in    std_logic;
      A3nSW9                       : in    std_logic;
      A0nSW10                      : in    std_logic;
      A1nSW11                      : in    std_logic;
      Sub_A6nSW12                  : in    std_logic;
      Sub_A7nSW13                  : in    std_logic;
      Sub_A4nSW14                  : in    std_logic;
      Sub_A5nSW15                  : in    std_logic;
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
      led1                         : out   std_logic;
      led2                         : out   std_logic;
      led3                         : out   std_logic;
      led4                         : out   std_logic;
      piggy_io                     : out   std_logic_vector(7 downto 0);
      VG_A4                        : in    std_logic;
      VG_A1                        : in    std_logic;
      DSP_DIR_D                    : out   std_logic;
      DSP_DIR_STRACK               : out   std_logic;
      DSP_DIR_REQRDY               : out   std_logic);
  end component;

  -- component generics
  constant system_clk_freq_in_hz      : real    := 70.0E+6;
  constant firmware_id                : integer := 1;
  constant firmware_version           : integer := 3;
  constant clk_divider_width_toplevel : integer := 16;
  constant reset_clks_toplevel        : integer := 2;

  -- component ports
  signal trig1_in                     : std_logic;
  signal trig2_out                    : std_logic;
  signal clk0                         : std_logic;
  signal hf_in                        : std_logic;
  signal uC_Link_D                    : std_logic_vector(7 downto 0);
  signal uC_Link_A                    : std_logic_vector(7 downto 0);
  signal Piggy_Clk1                   : std_logic;
  signal Piggy_RnW1                   : std_logic;
  signal Piggy_Strb1                  : std_logic;
  signal Piggy_Ack1                   : std_logic;
  signal Piggy_Ack2                   : std_logic;
  signal uC_Link_DIR_D, uC_Link_DIR_A : std_logic;
  signal nuC_Link_EN_CTRL_A           : std_logic;
  signal uC_Link_EN_DA                : std_logic;
  signal A2nSW8                       : std_logic;
  signal A3nSW9                       : std_logic;
  signal A0nSW10                      : std_logic;
  signal A1nSW11                      : std_logic;
  signal Sub_A6nSW12                  : std_logic;
  signal Sub_A7nSW13                  : std_logic;
  signal Sub_A4nSW14                  : std_logic;
  signal Sub_A5nSW15                  : std_logic;
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
  signal led1                         : std_logic;
  signal led2                         : std_logic;
  signal led3                         : std_logic;
  signal led4                         : std_logic;
  signal piggy_io                     : std_logic_vector(7 downto 0);
  signal VG_A4                        : std_logic;
  signal VG_A1                        : std_logic;
  signal DSP_DIR_D                    : std_logic;
  signal DSP_DIR_STRACK               : std_logic;
  signal DSP_DIR_REQRDY               : std_logic;

  component fab_adc_dac_firmware01_top
    generic (
      clk_divider_width   : integer;
      reset_clks_toplevel : integer);
    port (
      clk_i     : in    std_logic;
      bus8lo_io : inout std_logic_vector (7 downto 0);
      bus8hi_io : inout std_logic_vector (15 downto 8);
      adr_i     : in    std_logic_vector (5 downto 0);
      rnw_i     : in    std_logic;
      str_i     : in    std_logic;
      b8nb16_i  : in    std_logic;
      adc1d     : in    std_logic_vector (13 downto 0);
      dac1d     : out   std_logic_vector (13 downto 0);
      adc2d     : in    std_logic_vector (13 downto 0);
      dac2d     : out   std_logic_vector (13 downto 0);
      adc1sw    : out   std_logic_vector (3 downto 0);
      adc2sw    : out   std_logic_vector (3 downto 0);
      adc1clk   : out   std_logic;
      adc2clk   : out   std_logic;
      dac1clk   : out   std_logic;
      dac2clk   : out   std_logic;
      adc1of    : in    std_logic;
      adc2of    : in    std_logic;
      adc1shdn  : out   std_logic;
      adc2shdn  : out   std_logic;
      dac1slp   : out   std_logic;
      dac2slp   : out   std_logic;
      tp1_tio1  : out   std_logic;
      tp2_tio2  : out   std_logic;
      tp3       : in    std_logic;
      tp4_gclk0 : in    std_logic;
      tp5_gclk1 : in    std_logic;
      tp6       : in    std_logic;
      tp7_gclk3 : in    std_logic;
      cpld_clrn : in    std_logic;
      cpld_oe   : in    std_logic);
  end component;

  constant clk_divider_width : integer := 16;

  signal clk_i     : std_logic;
  signal bus8lo_io : std_logic_vector (7 downto 0);
  signal bus8hi_io : std_logic_vector (15 downto 8);
  signal adr_i     : std_logic_vector (5 downto 0);
  signal rnw_i     : std_logic;
  signal str_i     : std_logic;
  signal b8nb16_i  : std_logic;
  signal adc1d     : std_logic_vector (13 downto 0);
  signal dac1d     : std_logic_vector (13 downto 0);
  signal adc2d     : std_logic_vector (13 downto 0);
  signal dac2d     : std_logic_vector (13 downto 0);
  signal adc1sw    : std_logic_vector (3 downto 0);
  signal adc2sw    : std_logic_vector (3 downto 0);
  signal adc1clk   : std_logic;
  signal adc2clk   : std_logic;
  signal dac1clk   : std_logic;
  signal dac2clk   : std_logic;
  signal adc1of    : std_logic;
  signal adc2of    : std_logic;
  signal adc1shdn  : std_logic;
  signal adc2shdn  : std_logic;
  signal dac1slp   : std_logic;
  signal dac2slp   : std_logic;
  signal tp1_tio1  : std_logic;
  signal tp2_tio2  : std_logic;
  signal tp3       : std_logic;
  signal tp4_gclk0 : std_logic;
  signal tp5_gclk1 : std_logic;
  signal tp6       : std_logic;
  signal tp7_gclk3 : std_logic;
  signal cpld_clrn : std_logic;
  signal cpld_oe : std_logic;

  -- sim-clock
  signal simclk : std_logic := '1';

begin  -- digital_short_rev2_top_tb

  -- component instantiation
  digital_short_rev2_top_inst : digital_short_rev2_top
    generic map (
      system_clk_freq_in_hz      => system_clk_freq_in_hz,
      firmware_id                => firmware_id,
      firmware_version           => firmware_version,
      clk_divider_width_toplevel => clk_divider_width_toplevel,
      reset_clks_toplevel        => reset_clks_toplevel)
    port map (
      trig1_in           => trig1_in,
      trig2_out          => trig2_out,
      clk0               => clk0,
      hf_in              => hf_in,
      uC_Link_D          => uC_Link_D,
      uC_Link_A          => uC_Link_A,
      Piggy_Clk1         => Piggy_Clk1,
      Piggy_RnW1         => Piggy_RnW1,
      Piggy_Strb1        => Piggy_Strb1,
      Piggy_Ack1         => Piggy_Ack1,
      Piggy_Ack2         => Piggy_Ack2,
      uC_Link_DIR_D      => uC_Link_DIR_D,
      uC_Link_DIR_A      => uC_Link_DIR_A,
      nuC_Link_EN_CTRL_A => nuC_Link_EN_CTRL_A,
      uC_Link_EN_DA      => uC_Link_EN_DA,
      A2nSW8             => A2nSW8,
      A3nSW9             => A3nSW9,
      A0nSW10            => A0nSW10,
      A1nSW11            => A1nSW11,
      Sub_A6nSW12        => Sub_A6nSW12,
      Sub_A7nSW13        => Sub_A7nSW13,
      Sub_A4nSW14        => Sub_A4nSW14,
      Sub_A5nSW15        => Sub_A5nSW15,
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
      led1               => led1,
      led2               => led2,
      led3               => led3,
      led4               => led4,
      piggy_io           => piggy_io,
      VG_A4              => VG_A4,
      VG_A1              => VG_A1,
      DSP_DIR_D          => DSP_DIR_D,
      DSP_DIR_STRACK     => DSP_DIR_STRACK,
      DSP_DIR_REQRDY     => DSP_DIR_REQRDY);

  fab_adc_dac_firmware01_top_1 : fab_adc_dac_firmware01_top
    generic map (
      clk_divider_width   => clk_divider_width,
      reset_clks_toplevel => reset_clks_toplevel)
    port map (
      clk_i     => clk_i,
      bus8lo_io => bus8lo_io,
      bus8hi_io => bus8hi_io,
      adr_i     => adr_i,
      rnw_i     => rnw_i,
      str_i     => str_i,
      b8nb16_i  => b8nb16_i,
      adc1d     => adc1d,
      dac1d     => dac1d,
      adc2d     => adc2d,
      dac2d     => dac2d,
      adc1sw    => adc1sw,
      adc2sw    => adc2sw,
      adc1clk   => adc1clk,
      adc2clk   => adc2clk,
      dac1clk   => dac1clk,
      dac2clk   => dac2clk,
      adc1of    => adc1of,
      adc2of    => adc2of,
      adc1shdn  => adc1shdn,
      adc2shdn  => adc2shdn,
      dac1slp   => dac1slp,
      dac2slp   => dac2slp,
      tp1_tio1  => tp1_tio1,
      tp2_tio2  => tp2_tio2,
      tp3       => tp3,
      tp4_gclk0 => tp4_gclk0,
      tp5_gclk1 => tp5_gclk1,
      tp6       => tp6,
      tp7_gclk3 => tp7_gclk3,
      cpld_clrn => cpld_clrn,
      cpld_oe => cpld_oe);

  -- clock generation
  simclk <= not simclk after 10 ns;     -- 50 MHz Clock
  clk0   <= simclk;
  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    
    wait until simclk = '1';
  end process WaveGen_Proc;

  --  component interconnections

  clk_i <= Piggy_Clk1;

  b8nb16_i <= Piggy_Ack1;
  str_i    <= Piggy_Strb1;
  rnw_i    <= Piggy_RnW1;

  adr_i     <= piggy_io (5 downto 0);
  cpld_clrn <= piggy_io (7);

--  adc2d <= "10101010101010", "00011111111000" after 635 ns, "11111111111111" after 860 ns, conv_std_logic_vector (123,14) after 930 ns;
adc2d <= conv_std_logic_vector (100, 14), conv_std_logic_vector (200, 14) after 200 ns, conv_std_logic_vector (300, 14) after 300 ns, conv_std_logic_vector (400, 14) after 400 ns, conv_std_logic_vector (500, 14) after 500 ns, conv_std_logic_vector (600, 14) after 600 ns, conv_std_logic_vector (700, 14) after 700 ns;
  uC_Link_D <= bus8lo_io when Piggy_RnW1 = '1' else (others => 'Z');
  uC_Link_A <= bus8hi_io when Piggy_RnW1 = '1' else (others => 'Z');

  bus8lo_io <= uC_Link_D when Piggy_RnW1 = '0' else (others => 'Z');
  bus8hi_io <= uC_Link_A when Piggy_RnW1 = '0' else (others => 'Z');

end digital_short_rev2_top_tb;
