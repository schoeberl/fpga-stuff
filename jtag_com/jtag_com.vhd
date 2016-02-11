--
-- Copyright: 2016, Technical University of Denmark, DTU Compute
-- Author: Martin Schoeberl (martin@jopdesign.com)
-- License: Simplified BSD License
--
-- Use Altera's JTAG communication (former known as JTAG UART)
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity jtag_com is
	port (CLK_24MHZ : in std_logic; LED : out std_logic_vector(7 downto 0));
end entity jtag_com;

architecture rtl of jtag_com is

	component alt_jtag_atlantic is
		generic (
			INSTANCE_ID : integer;
			LOG2_RXFIFO_DEPTH : integer;
			LOG2_TXFIFO_DEPTH : integer;
			SLD_AUTO_INSTANCE_INDEX : string
		);
		port (
			clk : in std_logic;
			rst_n : in std_logic;
			-- the signal names are a little bit strange
			r_dat : in std_logic_vector(7 downto 0); -- data from FPGA
			r_val : in std_logic; -- data valid
			r_ena : out std_logic; -- can write (next) cycle, or FIFO not full?
			t_dat : out std_logic_vector(7 downto 0); -- data to FPGA
			t_dav : in std_logic; -- ready to receive more data
			t_ena : out std_logic; -- tx data valid
			t_pause : out std_logic -- ???
		);
	end component alt_jtag_atlantic;

	signal r_dat : std_logic_vector(7 downto 0);
	signal r_val : std_logic;
	signal r_ena : std_logic;
	signal t_dat : std_logic_vector(7 downto 0);
	signal t_dav : std_logic;
	signal t_ena : std_logic;
	signal t_pause : std_logic;

	signal is_full_reg : std_logic;
	signal data_reg : std_logic_vector(7 downto 0);

	signal clk : std_logic;
	signal cnt : unsigned(24 downto 0);

begin

	clk <= CLK_24MHZ;

	-- r_val <= '1'; -- we should do some hand shaking
	-- t_dav <= '1'; -- should only be set when a new data is there
	-- r_dat <= t_dat; -- should manipulate it (add 1 or make upper case)


	jtag_inst : component alt_jtag_atlantic
		generic map (
			INSTANCE_ID => 0,
			LOG2_RXFIFO_DEPTH => 3,
			LOG2_TXFIFO_DEPTH => 3,
			SLD_AUTO_INSTANCE_INDEX => "YES"
		)
		port map (
			clk => clk,
			rst_n => '1',
			r_dat => r_dat,
			r_val => r_val,
			r_ena => r_ena,
			t_dat => t_dat,
			t_dav => t_dav,
			t_ena => t_ena,
			t_pause => t_pause
		);


	process(clk)
	begin
		if (is_full_reg = '0') then
			if (t_ena = '1') then
				data_reg <= std_logic_vector(unsigned(t_dat) + 1);
				is_full_reg <= '1';
			end if;
		else
			if (r_ena = '1') then
				is_full_reg <= '0';
			end if;
		end if;
	end process;

	t_dav <= not is_full_reg and not t_ena;
	r_val <= is_full_reg;
	r_dat <= data_reg;

	-- keep something blinking to see we are alive
	process(clk)
	begin
		if rising_edge(clk) then
			cnt <= cnt + 1;
		end if;
	end process;
	
	-- LED <= cnt(23 downto 16);
	LED(0) <= cnt(23);

end architecture rtl;
