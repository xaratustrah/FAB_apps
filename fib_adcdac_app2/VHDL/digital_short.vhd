library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sawtooth_pkg.all;
use work.clk_divider_pkg.all;

entity digital_short is
  generic (
    clk_freq_in_hz : real    := 200000000.0;  --system clock frequency
    counter_width  : integer := 7;
    delay_in_ns    : real    := 25.0);        -- 25.0

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

  component sawtooth
    generic (
      counter_width : integer);
    port (
      dat_o : out std_logic_vector (counter_width - 1 downto 0);
      rst_i : in  std_logic;
      clk_i : in  std_logic);
  end component;

  component lut
    generic (
      length : integer);
    port (
      dat_o : out std_logic_vector (counter_width - 1 downto 0);
      adr_i : in  std_logic_vector (counter_width - 1 downto 0));
  end component;

  constant FAB_DAC_ADR : std_logic_vector (5 downto 0) := "000100";  -- Address of the DAC1 channel

  signal local_data    : std_logic_vector (15 downto 0);  -- data read from or written to fab
  signal local_counter : std_logic_vector (counter_width - 1 downto 0);

  signal clk_from_divider : std_logic;  -- clock from divider
  
begin  -- digital_short_arch

  --  local_data (7 downto 0)  <= local_counter;

  local_data (15 downto counter_width) <= (others => '0');

  -- component instances

  sawtooth_1 : sawtooth
    generic map (
      counter_width => counter_width)
    port map (
      dat_o => local_counter,
      rst_i => rst_i,
      clk_i => clk_i);

  lut_1 : lut
    generic map (
      length => counter_width)
    port map (
      dat_o => local_data (counter_width -1 downto 0),
      adr_i => local_counter (counter_width -1 downto 0));

  clk_divider_1 : clk_divider
    generic map (
      clk_divider_width => 16)
    port map (
      clk_div_i => x"0004",
      rst_i   => rst_i,
      clk_i   => clk_i,
      clk_o   => clk_from_divider);

  -- data flow only in a single direction

  strobe_o        <= '1';
  rnw_o           <= '0';
  en_write_to_bus <= '1';
  ext_driver_dir  <= '1';
  adr_o           <= FAB_DAC_ADR;


  -- purpose: Read from ADC on FAB and write it back in FAB's DAC

  process (clk_from_divider, rst_i)

  begin  -- process p_shorting

    if rst_i = '1' then                 -- asynchronous reset (active high)

      data_to_bus <= (others => '0');

    elsif clk_from_divider'event and clk_from_divider = '1' then  -- rising clock edge

      data_to_bus <= local_data;
      
    end if;
  end process;

end digital_short_arch;
