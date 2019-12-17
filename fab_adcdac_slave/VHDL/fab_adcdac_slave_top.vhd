-------------------------------------------------------------------------------
--
-- Slave Program for FAB ADC DAC Rev.C and following revisions
-- S. Sanjari
-- 
-------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.clk_divider_pkg.all;
use work.fub_multi_spi_master_pkg.all;
use work.fub_vga_pkg.all;
use work.fub_mux_2_to_1_pkg.all;
use work.fub_io_expander_pkg.all;
use work.seq_reset_gen_pkg.all;
use work.inout_driver02_pkg.all;

entity fab_adcdac_slave_top is

  generic(
    vga_default_gain      : std_logic_vector (3 downto 0)    := "0001";
    spi_clk_perid_in_ns   : real                             := 1000.0;
    spi_setup_delay_in_ns : real                             := 1000.0;
    -- default value is x"1100", 11 for setting the switches and 00 for
    -- switching all converters on
    default_io_data       : std_logic_vector(15 downto 0)    := x"1100"; 
    default_setup_data    : std_logic_vector (64-1 downto 0) := x"0A200B20000001C3";
    reset_clks            : integer                          := 20;
    clk_freq_in_hz        : real                             := 100.0E6;
	 clk_divider_width : integer := 8);    -- width of the dividers in bits

  port (

--clk's

    -- hf_clk_i    : in  std_logic;
    -- hdc_clk_i   : in  std_logic;
    -- xco_clk_i   : in  std_logic;
    -- piggy_clk_o : out std_logic;
    piggy_clk_i : in  std_logic;

-- ram signals

    -- ramd : in std_logic_vector (15 downto 0);
    -- rama : out   std_ulogic_vector (18 downto 0);

    -- ram_nwe  : out std_logic;
    -- ram_nlub : out std_logic;

-- SPI signals

    spi_sclk : out std_logic;
    spi_mosi : out std_logic;
    spi_miso : in  std_logic;

    ncs_expander : out std_logic;
    --ncs_eeprom   : out std_logic;
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

    -- hdc_diff1n_io : out std_logic;
    -- hdc_diff1p_io : out std_logic;
    -- hdc_diff2n_io : out std_logic;
    -- hdc_diff2p_io : out std_logic;
    -- hdc_diff3n_io : out std_logic;
    -- hdc_diff3p_io : out std_logic;
    -- hdc_diff4n_io : out std_logic;
    -- hdc_diff4p_io : out std_logic;
    -- hdc_diff5n_io : out std_logic;
    -- hdc_diff5p_io : out std_logic;

-- Piggy Connector 
       
    dat_alpha_i : inout std_logic_vector (7 downto 0);  -- fib data bus LOW Byte connected to uC_LINK_D[7..0] (BUS_ALPHA_IO in Revision B)
    adr_alpha_i  : in    std_logic_vector (4 downto 0);  -- fib address bus
    busy_alpha_o  : in    std_logic;     -- read-not-write signal from fib: 1 = read from FAB , 0 = write to FAB (rnw_alpha_i in Revision B)
    str_alpha_i  : in    std_logic;     -- strobe signal from fib
    dat_beta_o : inout std_logic_vector (7 downto 0);  -- fib data bus HI Byte connected to uC_LINK_A[7..0] (BUS_BETA_IO in Revision B)
    adr_beta_o  : in    std_logic_vector (4 downto 0);  -- fib address bus (adr_beta_i in Revision B), adr_beta_o[4]= Global reset signal (nrst_i in Revision B)
	busy_beta_i  : in    std_logic;      -- read-not-write signal from fib: 1 = read from FAB , 0 = write to FAB (rnw_beta_i in revision B)
	str_beta_o  : in    std_logic      -- strobe signal from fib (str_beta_i in revision B)
    );

end fab_adcdac_slave_top;

architecture fab_adcdac_slave_top_arch of fab_adcdac_slave_top is

  --internal variables

  signal global_rst : std_logic;        -- internal global reset signal

  signal clk    : std_logic;

  signal mosi : std_logic;
  signal miso : std_logic;
  signal sclk : std_logic;
  signal ss   : std_logic_vector (9 downto 0);

  signal str_for_vga1 : std_logic;
  signal str_for_vga2 : std_logic;

  -- internal FUB connections

  constant width_for_spi_fub : integer := 3;  -- berechnet sich aus der

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

  -- Signals for the main part
  
    type register_file_type is array (0 to 15) of std_logic_vector (7 downto 0);
  signal read_register_file  : register_file_type;
  signal write_register_file : register_file_type;

    signal bus_alpha_to   : std_logic_vector (7 downto 0);
  signal bus_alpha_from : std_logic_vector (7 downto 0);

  signal bus_beta_to   : std_logic_vector (7 downto 0);
  signal bus_beta_from : std_logic_vector (7 downto 0);

  signal internal_busy_alpha_o : std_logic;
  signal internal_busy_beta_i  : std_logic;
  
begin  -- FAB_ADC_DAC_top_level_arch

  -- component instances

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
  
-- signals interconncections for the main part

clk <= piggy_clk_i;

  spi_mosi <= mosi;
  miso     <= spi_miso;
  spi_sclk <= sclk;

  ncs_vga1     <= ss(0);
  ncs_expander <= ss(1);
  ncs_vga2     <= ss(2);

vga1_rst  <= seq_reset (1);
expander_rst  <= seq_reset (0);
vga2_rst  <= seq_reset (2);

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

	vga1_strb   <= '0';
	vga2_strb   <= '0';
	
-- component instantiations of the main process

  adc1_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (6),
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => adc1clk);

  adc2_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (7),
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => adc2clk);

  dac1_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (8),
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => dac1clk);

  dac2_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (9),
      rst_i     => global_rst,
      clk_i     => clk,
      clk_o     => dac2clk);

	  -- Alpha Bus

	  inout_driver02_1 : inout_driver02
    generic map (
      io_bus_width => 8)
    port map (
      read_not_write_to_bus_i => internal_busy_alpha_o,
      data_bus_io             => dat_alpha_i,
      data_to_bus_i           => bus_alpha_to,
      data_from_bus_o         => bus_alpha_from);

  -- Beta Bus
  inout_driver02_2 : inout_driver02
    generic map (
      io_bus_width => 8)
    port map (
      read_not_write_to_bus_i => internal_busy_beta_i,
      data_bus_io             => dat_beta_o,
      data_to_bus_i           => bus_beta_to,
      data_from_bus_o         => bus_beta_from);

  -- globat reset signal
   global_rst <= write_register_file(4) (3) or not adr_beta_o(4);  -- either of the reset sources

  -- static signals connected to registers
  adc2shdn <= write_register_file(4) (7);
  adc1shdn <= write_register_file(4) (6);
  dac2slp  <= write_register_file(4) (5);
  dac1slp  <= write_register_file(4) (4);

  adc2sw <= write_register_file(5)(7 downto 4);
  adc1sw <= write_register_file(5)(3 downto 0);

  read_register_file(4) (1 downto 0) <= (others => '0');
  read_register_file(4) (2)          <= adc1of;
  read_register_file(4) (3)          <= adc2of;
  read_register_file(4) (7 downto 4) <= (others => '0');

  -- direction of the rnw signal for the inout drivers
  internal_busy_beta_i  <= not busy_beta_i;
  internal_busy_alpha_o <= not busy_alpha_o;

  -- register interconnections
  read_register_file (6)  <= write_register_file (6);
  read_register_file (7)  <= write_register_file (7);
  read_register_file (8)  <= write_register_file (8);
  read_register_file (9)  <= write_register_file (9);
  read_register_file (10) <= write_register_file (10);

  -- main process

  p_main : process (clk, global_rst)

    variable adc_update : boolean;
    variable dac_update : boolean;

  begin  -- process p_main

    if global_rst = '1' then            -- asynchronous reset (active high)

      write_register_file(0)  <= x"00";
      write_register_file(1)  <= x"00";
      write_register_file(2)  <= x"00";
      write_register_file(3)  <= x"00";
      write_register_file(4)  <= x"00";
      write_register_file(5)  <= "01000100";  -- x"44"
      write_register_file(6)  <= x"04";
      write_register_file(7)  <= x"04";
      write_register_file(8)  <= x"04";
      write_register_file(9)  <= x"04";
 --     write_register_file(10) <= "10101010";  -- x"AA", update on all channels,
                                              -- on low byte 
      write_register_file(10) <= "10101111";  -- x"AA", update on all channels,
                                              -- on low byte 
      adc_update                  := false;
      dac_update                  := false;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      adc_update := false;
      dac_update := false;

      if str_beta_o = '1' then
        if busy_beta_i = '0' then
          write_register_file (conv_integer (adr_beta_o(3 downto 0))) <= bus_beta_from;
        elsif busy_beta_i = '1' then
          bus_beta_to <= read_register_file (conv_integer (adr_beta_o(3 downto 0)));
        end if;
        if (adr_beta_o(3 downto 2) = conv_std_logic_vector (0, 2)) then
          if busy_beta_i = '1' then
            if write_register_file(10)(1) = '1' and adr_beta_o (1) = '0' then
              --ADC1 is update source and ADC1 is selected
              if write_register_file (10) (0) = adr_beta_o(0) then
                -- Update source byte is identical to select byte
                adc_update := true;
              end if;
              
            elsif write_register_file(10)(3) = '1' and adr_beta_o (1) = '1' then
              --ADC2 is update source and ADC2 is selected
              if write_register_file (10) (2) = adr_beta_o(0) then
                -- Update source byte is identical to select byte
                adc_update := true;
              end if;
            end if;
          else
            if write_register_file(10)(5) = '1' and adr_beta_o (1) = '0' then
              --DAC1 is update source and DAC1 is selected
              if write_register_file (10) (4) = adr_beta_o(0) then
                -- Update source byte is identical to select byte
                dac_update := true;
              end if;
              
            elsif write_register_file(10)(7) = '1' and adr_beta_o (1) = '1' then
              --DAC2 is update source and DAC2 is selected
              if write_register_file (10) (6) = adr_beta_o(0) then
                -- Update source byte is identical to select byte
                dac_update := true;
              end if;
            end if;
          end if;
        end if;
      end if;


      if str_alpha_i = '1' then
        if busy_alpha_o = '0' then
          write_register_file (conv_integer (adr_alpha_i(3 downto 0))) <= bus_alpha_from;
--          if adr_alpha_i(3 downto 1)="000" then
--            if adr_alpha_i(0)='0' then
--              write_register_file (0) <= bus_alpha_from;
--            else
--              write_register_file (1) <= bus_alpha_from;
--            end if;
--          end if;
        elsif busy_alpha_o = '1' then
          bus_alpha_to <= read_register_file (conv_integer (adr_alpha_i(3 downto 0)));
        end if;

        if (adr_alpha_i(3 downto 2) <=  conv_std_logic_vector (0, 2)) then
          if busy_alpha_o = '1' then
            if write_register_file(10)(1) = '1' and adr_alpha_i (1) = '0' then
              --ADC1 is update source and ADC1 is selected
              if write_register_file (10) (0) = adr_alpha_i(0) then
                -- Update source byte is identical to select byte
                adc_update := true;
              end if;
              
            elsif write_register_file(10)(3) = '1' and adr_alpha_i (1) = '1' then
              --ADC2 is update source and ADC2 is selected
              if write_register_file (10) (2) = adr_alpha_i(0) then
                -- Update source byte is identical to select byte
                adc_update := true;
              end if;
            end if;
          else
            if write_register_file(10)(5) = '1' and adr_alpha_i (1) = '0' then
              --DAC1 is update source and DAC1 is selected
              if write_register_file (10) (4) = adr_alpha_i(0) then
                -- Update source byte is identical to select byte
                dac_update := true;
              end if;
              
            elsif write_register_file(10)(7) = '1' and adr_alpha_i (1) = '1' then
              --DAC2 is update source and DAC2 is selected
              if write_register_file (10) (6) = adr_alpha_i(0) then
                -- Update source byte is identical to select byte
                dac_update := true;
              end if;
            end if;
          end if;
        end if;
      end if;

      if dac_update = true then

        dac1d (7 downto 0)  <= write_register_file(0);
        dac1d (13 downto 8) <= write_register_file(1) (5 downto 0);
        --  write_register_file (1) (7 downto 6) <= (others => '0');

        dac2d (7 downto 0)  <= write_register_file (2);
        dac2d (13 downto 8) <= write_register_file (3) (5 downto 0);
        --  write_register_file (3) (7 downto 0) <= (others => '0');
      end if;

      if adc_update = true then
        read_register_file(0) (7 downto 0) <= adc1d (7 downto 0);
        read_register_file(1) (5 downto 0) <= adc1d (13 downto 8);
        read_register_file(1) (7 downto 6) <= (others => '0');
        read_register_file(2) (7 downto 0) <= adc2d (7 downto 0);
        read_register_file(3) (5 downto 0) <= adc2d (13 downto 8);
        read_register_file(3) (7 downto 6) <= (others => '0');

      end if;
      
    end if;
  end process p_main;

end fab_adcdac_slave_top_arch;
