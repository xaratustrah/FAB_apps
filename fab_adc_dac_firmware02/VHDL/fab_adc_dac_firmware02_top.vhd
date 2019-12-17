

-------------------------------------------------------------------------------
--
-- Firmware02 for the CPLD on the FAB_ADC/DAC
-- 27.04.2007/sh
--
-------------------------------------------------------------------------------

-- Package definition

-- Entity definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.STD_LOGIC_arith.all;
use ieee.STD_LOGIC_unsigned.all;

use work.inout_driver02_pkg.all;
use work.clk_divider_pkg.all;

entity fab_adc_dac_firmware02_top is

  generic (
    clk_divider_width : integer := 8    -- width of the divider in bits
    );
  port (

    -- common signals

    clk_i  : in std_logic;              -- main clock in
    nrst_i : in std_logic;              -- CPLD Global reset signal

    oe_i : in std_logic;               -- CPLD Global operation enable signal
    -- (not used)
    -- fib signals

    bus_alpha_io : inout std_logic_vector (7 downto 0);  -- fib data bus LOW Byte
                                        -- connected to uC_LINK_D[7..0]
    adr_alpha_i  : in    std_logic_vector (3 downto 0);  -- fib address bus
    rnw_alpha_i  : in    std_logic;     -- read-not-write signal from fib:
                                        -- 1 = read from FAB , 0 = write to FAB
    str_alpha_i  : in    std_logic;     -- strobe signal from fib

    bus_beta_io : inout std_logic_vector (7 downto 0);  -- fib data bus HI Byte
                                        -- connected to uC_LINK_A[7..0]
    adr_beta_i  : in    std_logic_vector (3 downto 0);  -- fib address bus
    rnw_beta_i  : in    std_logic;      -- read-not-write signal from fib:
                                        -- 1 = read from FAB , 0 = write to FAB
    str_beta_i  : in    std_logic;      -- strobe signal from fib

    -- board signals

    adc1d : in  std_logic_vector (13 downto 0);  -- ADC1 data input
    dac1d : out std_logic_vector (13 downto 0);  -- DAC1 data output
    adc2d : in  std_logic_vector (13 downto 0);  -- ADC2 data input
    dac2d : out std_logic_vector (13 downto 0);  -- DAC2 data output

    adc1sw : out std_logic_vector (3 downto 0);  -- calibration switch for ADC1
    adc2sw : out std_logic_vector (3 downto 0);  -- calibration switch for ADC2

    adc1clk : out std_logic;            -- clock for ADC1
    adc2clk : out std_logic;            -- clock for ADC2
    dac1clk : out std_logic;            -- clock for DAC1
    dac2clk : out std_logic;            -- clock for DAC2

    adc1of   : in  std_logic;           -- overflow from ADC1
    adc2of   : in  std_logic;           -- overflow from ADC2
    adc1shdn : out std_logic;           -- shut down ADC1
    adc2shdn : out std_logic;           -- shut down ADC2
    dac1slp  : out std_logic;           -- shut down DAC1
    dac2slp  : out std_logic;           -- shut down DAC2

    tp1 : out std_logic;                -- test pin 1  
    tp2 : out std_logic;                -- test pin 2
    tp3 : in  std_logic;                -- test pin 3  
    tp4 : in  std_logic;                -- test pin 4  
    tp5 : in  std_logic;                -- test pin 5
    tp6 : in  std_logic;                -- test pin 6
    tp7 : in  std_logic;                -- test pin 7

    -- Micro Controller link signals (not used) 

    ucl_rnw : in  std_logic;
    ucl_str : in  std_logic;
    ucl_ack : out std_logic;
    ucl_mrq : in  std_logic

    );

end fab_adc_dac_firmware02_top;

architecture fab_adc_dac_firmware02_top_arch of fab_adc_dac_firmware02_top is

  -- internal registers

  type register_file_type is array (0 to 15) of std_logic_vector (7 downto 0);
  signal read_register_file  : register_file_type;
  signal write_register_file : register_file_type;

  -- test pins

  signal testpins_vector_o : std_logic_vector (1 downto 0);  -- Vector for the test pins
  signal testpins_vector_i : std_logic_vector (4 downto 0);  -- Vector for the test pins

  -- internal signals

  signal global_rst : std_logic;        -- internal global reset signal

  signal bus_alpha_to   : std_logic_vector (7 downto 0);
  signal bus_alpha_from : std_logic_vector (7 downto 0);

  signal bus_beta_to   : std_logic_vector (7 downto 0);
  signal bus_beta_from : std_logic_vector (7 downto 0);

  signal internal_rnw_alpha_i : std_logic;
  signal internal_rnw_beta_i  : std_logic;

--  signal test : std_logic;
--  signal adr_alpha_i  : std_logic_vector (3 downto 0);
begin  -- fab_adc_dac_firmware02_top_arch

  -- component instances

  adc1_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (6),
      rst_i     => global_rst,
      clk_i     => clk_i,
      clk_o     => adc1clk);

  adc2_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (7),
      rst_i     => global_rst,
      clk_i     => clk_i,
      clk_o     => adc2clk);

  dac1_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (8),
      rst_i     => global_rst,
      clk_i     => clk_i,
      clk_o     => dac1clk);

  dac2_clk_divider_inst : clk_divider

    generic map (
      clk_divider_width => clk_divider_width)

    port map (
      clk_div_i => write_register_file (9),
      rst_i     => global_rst,
      clk_i     => clk_i,
      clk_o     => dac2clk);

  -- Alpha Bus
  inout_driver02_1 : inout_driver02
    generic map (
      io_bus_width => 8)
    port map (
      read_not_write_to_bus_i => internal_rnw_alpha_i,
      data_bus_io             => bus_alpha_io,
      data_to_bus_i           => bus_alpha_to,
      data_from_bus_o         => bus_alpha_from);

  -- Beta Bus
  inout_driver02_2 : inout_driver02
    generic map (
      io_bus_width => 8)
    port map (
      read_not_write_to_bus_i => internal_rnw_beta_i,
      data_bus_io             => bus_beta_io,
      data_to_bus_i           => bus_beta_to,
      data_from_bus_o         => bus_beta_from);

  -- unused signals set to ground

  ucl_ack <= '0';

  -- globat reset signal
  global_rst <= write_register_file(4) (3) or not nrst_i;  -- either of the reset sources

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
  internal_rnw_beta_i  <= not rnw_beta_i;
  internal_rnw_alpha_i <= not rnw_alpha_i;

  -- testpins_vectors
  tp1 <= testpins_vector_o(0);
  tp2 <= testpins_vector_o(1);

  testpins_vector_i <= (
    0 => tp3,
    1 => tp4,
    2 => tp5,
    3 => tp6,
    4 => tp7
    );

  -- set a test signal for the oscilloscope
  testpins_vector_o <= (others => '1');

  -- register interconnections
  read_register_file (6)  <= write_register_file (6);
  read_register_file (7)  <= write_register_file (7);
  read_register_file (8)  <= write_register_file (8);
  read_register_file (9)  <= write_register_file (9);
  read_register_file (10) <= write_register_file (10);


--  process(clk_i)
--  begin
--    if clk_i'event and clk_i = '1' then  -- rising clock edge
----      test <= adr_alpha_i(0);
--        if adr_alpha_i = "0000" then
--          adr_alpha_i(3 downto 0) <= "0001";
--        else
--          adr_alpha_i(3 downto 0) <= "0000";
--        end if;
--    end if;
--  end process;
--  
  -- main process
  p_main : process (clk_i, global_rst)

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
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
 --         test <= adr_alpha_i(0);

--      dac1d(7 downto 0)  <= "01010101";
--      dac1d(13 downto 8) <= "101010";

      adc_update := false;
      dac_update := false;

      if str_beta_i = '1' then
        if rnw_beta_i = '0' then
          write_register_file (conv_integer (adr_beta_i)) <= bus_beta_from;
        elsif rnw_beta_i = '1' then
          bus_beta_to <= read_register_file (conv_integer (adr_beta_i));
        end if;
        if (adr_beta_i(3 downto 2) = conv_std_logic_vector (0, 2)) then
          if rnw_beta_i = '1' then
            if write_register_file(10)(1) = '1' and adr_beta_i (1) = '0' then
              --ADC1 is update source and ADC1 is selected
              if write_register_file (10) (0) = adr_beta_i(0) then
                -- Update source byte is identical to select byte
                adc_update := true;
              end if;
              
            elsif write_register_file(10)(3) = '1' and adr_beta_i (1) = '1' then
              --ADC2 is update source and ADC2 is selected
              if write_register_file (10) (2) = adr_beta_i(0) then
                -- Update source byte is identical to select byte
                adc_update := true;
              end if;
            end if;
          else
            if write_register_file(10)(5) = '1' and adr_beta_i (1) = '0' then
              --DAC1 is update source and DAC1 is selected
              if write_register_file (10) (4) = adr_beta_i(0) then
                -- Update source byte is identical to select byte
                dac_update := true;
              end if;
              
            elsif write_register_file(10)(7) = '1' and adr_beta_i (1) = '1' then
              --DAC2 is update source and DAC2 is selected
              if write_register_file (10) (6) = adr_beta_i(0) then
                -- Update source byte is identical to select byte
                dac_update := true;
              end if;
            end if;
          end if;
        end if;
      end if;


      if str_alpha_i = '1' then
        if rnw_alpha_i = '0' then
          write_register_file (conv_integer (adr_alpha_i)) <= bus_alpha_from;
--          if adr_alpha_i(3 downto 1)="000" then
--            if adr_alpha_i(0)='0' then
--              write_register_file (0) <= bus_alpha_from;
--            else
--              write_register_file (1) <= bus_alpha_from;
--            end if;
--          end if;
        elsif rnw_alpha_i = '1' then
          bus_alpha_to <= read_register_file (conv_integer (adr_alpha_i));
        end if;

        if (adr_alpha_i(3 downto 2) <=  conv_std_logic_vector (0, 2)) then
          if rnw_alpha_i = '1' then
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

  -- test betrieb
--  read_register_file(0) (7 downto 0) <= "01010101";
--  read_register_file(1) (5 downto 0) <= "101010";

end fab_adc_dac_firmware02_top_arch;

