-------------------------------------------------------------------------------
-- Title      : Testbench for design "fab_bbsg_top"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fab_bbsg_top_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2008-11-04
-- Last update: 2008-11-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-11-04  1.0      ssanjari	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity fab_bbsg_top_tb is

end fab_bbsg_top_tb;

-------------------------------------------------------------------------------

architecture fab_bbsg_top_tb_arch of fab_bbsg_top_tb is

  component fab_bbsg_top
    generic (
      vga_default_gain      : std_logic_vector (3 downto 0);
      spi_clk_perid_in_ns   : real;
      spi_setup_delay_in_ns : real;
      reset_clks            : integer;
      clk_freq_in_hz        : real);
    port (
      hf_clk_i               : in    std_logic;
      hdc_clk_i              : in    std_logic;
      xco_clk_i              : in    std_logic;
      piggy_clk_o            : out   std_logic;
      piggy_clk_i            : in    std_logic;
      ramd                   : inout std_logic_vector (15 downto 0);
      rama                   : out   std_ulogic_vector (18 downto 0);
      ram_nwe                : out   std_logic;
      ram_nlub               : out   std_logic;
      spi_sclk               : out   std_logic;
      spi_mosi               : out   std_logic;
      spi_miso               : in    std_logic;
      ncs_expander           : out   std_logic;
      ncs_eeprom             : out   std_logic;
      ncs_vga1               : out   std_logic;
      ncs_vga2               : out   std_logic;
      adc1d                  : in    std_logic_vector (13 downto 0);
      adc2d                  : in    std_logic_vector (13 downto 0);
      dac1d                  : out   std_logic_vector (13 downto 0);
      dac2d                  : out   std_logic_vector (13 downto 0);
      adc1clk                : out   std_logic;
      adc2clk                : out   std_logic;
      dac1clk                : out   std_logic;
      dac2clk                : out   std_logic;
      hdc_diff1n_io          : out   std_logic;
      hdc_diff1p_io          : out   std_logic;
      hdc_diff2n_io          : out   std_logic;
      hdc_diff2p_io          : out   std_logic;
      hdc_diff3n_io          : out   std_logic;
      hdc_diff3p_io          : out   std_logic;
      hdc_diff4n_io          : out   std_logic;
      hdc_diff4p_io          : out   std_logic;
      hdc_diff5n_io          : out   std_logic;
      hdc_diff5p_io          : out   std_logic;
      dat_alpha_i            : in    std_logic_vector (7 downto 0);
      adr_alpha_i            : in    std_logic_vector (4 downto 0);
      str_alpha_i            : in    std_logic;
      busy_alpha_o           : out   std_logic;
      dat_beta_o             : inout std_logic_vector (7 downto 0);
      adr_beta_o             : in    std_logic_vector (4 downto 0);
      str_beta_o             : in    std_logic;
      busy_beta_i            : in    std_logic;
      ucl_rnw                : in    std_logic;
      ucl_str                : in    std_logic;
      piggy_rst_o            : out   std_logic;
      ucl_ack_fpga_init_conf : out   std_logic);
  end component;

  -- component generics
  constant vga_default_gain      : std_logic_vector (3 downto 0) := "0010";
  constant spi_clk_perid_in_ns   : real                          := 1000.0;
  constant spi_setup_delay_in_ns : real                          := 1000.0;
  constant reset_clks            : integer                       := 20;
  constant clk_freq_in_hz        : real                          := 50.0E6;

  -- component ports
  signal hf_clk_i               : std_logic;
  signal hdc_clk_i              : std_logic;
  signal xco_clk_i              : std_logic;
  signal piggy_clk_o            : std_logic;
  signal piggy_clk_i            : std_logic;
  signal ramd                   : std_logic_vector (15 downto 0);
  signal rama                   : std_ulogic_vector (18 downto 0);
  signal ram_nwe                : std_logic;
  signal ram_nlub               : std_logic;
  signal spi_sclk               : std_logic;
  signal spi_mosi               : std_logic;
  signal spi_miso               : std_logic;
  signal ncs_expander           : std_logic;
  signal ncs_eeprom             : std_logic;
  signal ncs_vga1               : std_logic;
  signal ncs_vga2               : std_logic;
  signal adc1d                  : std_logic_vector (13 downto 0);
  signal adc2d                  : std_logic_vector (13 downto 0);
  signal dac1d                  : std_logic_vector (13 downto 0);
  signal dac2d                  : std_logic_vector (13 downto 0);
  signal adc1clk                : std_logic;
  signal adc2clk                : std_logic;
  signal dac1clk                : std_logic;
  signal dac2clk                : std_logic;
  signal hdc_diff1n_io          : std_logic;
  signal hdc_diff1p_io          : std_logic;
  signal hdc_diff2n_io          : std_logic;
  signal hdc_diff2p_io          : std_logic;
  signal hdc_diff3n_io          : std_logic;
  signal hdc_diff3p_io          : std_logic;
  signal hdc_diff4n_io          : std_logic;
  signal hdc_diff4p_io          : std_logic;
  signal hdc_diff5n_io          : std_logic;
  signal hdc_diff5p_io          : std_logic;
  signal dat_alpha_i            : std_logic_vector (7 downto 0);
  signal adr_alpha_i            : std_logic_vector (4 downto 0);
  signal str_alpha_i            : std_logic;
  signal busy_alpha_o           : std_logic;
  signal dat_beta_o             : std_logic_vector (7 downto 0);
  signal adr_beta_o             : std_logic_vector (4 downto 0);
  signal str_beta_o             : std_logic;
  signal busy_beta_i            : std_logic;
  signal ucl_rnw                : std_logic;
  signal ucl_str                : std_logic;
  signal piggy_rst_o            : std_logic;
  signal ucl_ack_fpga_init_conf : std_logic;

  -- clock
  signal simclk : std_logic := '1';

begin  -- fab_bbsg_top_tb_arch

  -- component instantiation
  fab_bbsg_top_inst: fab_bbsg_top
    generic map (
      vga_default_gain      => vga_default_gain,
      spi_clk_perid_in_ns   => spi_clk_perid_in_ns,
      spi_setup_delay_in_ns => spi_setup_delay_in_ns,
      reset_clks            => reset_clks,
      clk_freq_in_hz        => clk_freq_in_hz)
    port map (
      hf_clk_i               => hf_clk_i,
      hdc_clk_i              => hdc_clk_i,
      xco_clk_i              => xco_clk_i,
      piggy_clk_o            => piggy_clk_o,
      piggy_clk_i            => piggy_clk_i,
      ramd                   => ramd,
      rama                   => rama,
      ram_nwe                => ram_nwe,
      ram_nlub               => ram_nlub,
      spi_sclk               => spi_sclk,
      spi_mosi               => spi_mosi,
      spi_miso               => spi_miso,
      ncs_expander           => ncs_expander,
      ncs_eeprom             => ncs_eeprom,
      ncs_vga1               => ncs_vga1,
      ncs_vga2               => ncs_vga2,
      adc1d                  => adc1d,
      adc2d                  => adc2d,
      dac1d                  => dac1d,
      dac2d                  => dac2d,
      adc1clk                => adc1clk,
      adc2clk                => adc2clk,
      dac1clk                => dac1clk,
      dac2clk                => dac2clk,
      hdc_diff1n_io          => hdc_diff1n_io,
      hdc_diff1p_io          => hdc_diff1p_io,
      hdc_diff2n_io          => hdc_diff2n_io,
      hdc_diff2p_io          => hdc_diff2p_io,
      hdc_diff3n_io          => hdc_diff3n_io,
      hdc_diff3p_io          => hdc_diff3p_io,
      hdc_diff4n_io          => hdc_diff4n_io,
      hdc_diff4p_io          => hdc_diff4p_io,
      hdc_diff5n_io          => hdc_diff5n_io,
      hdc_diff5p_io          => hdc_diff5p_io,
      dat_alpha_i            => dat_alpha_i,
      adr_alpha_i            => adr_alpha_i,
      str_alpha_i            => str_alpha_i,
      busy_alpha_o           => busy_alpha_o,
      dat_beta_o             => dat_beta_o,
      adr_beta_o             => adr_beta_o,
      str_beta_o             => str_beta_o,
      busy_beta_i            => busy_beta_i,
      ucl_rnw                => ucl_rnw,
      ucl_str                => ucl_str,
      piggy_rst_o            => piggy_rst_o,
      ucl_ack_fpga_init_conf => ucl_ack_fpga_init_conf);

  -- clock generation
  simclk <= not simclk after 1 ns;


  xco_clk_i <= simclk;
  
end fab_bbsg_top_tb_arch;

