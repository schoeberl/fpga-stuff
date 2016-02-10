
    --
    --  hello_world.vhd
    --
    --  The 'Hello World' example for FPGA programming.
    --
    --  Author: Martin Schoeberl (martin@jopdesign.com)
    --
    --  2006-08-04  created
    --

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity hello_world is

    port (
        CLK_24MHZ     : in std_logic;
        LED     : out std_logic_vector(7 downto 0)
    );
    end hello_world;

    architecture rtl of hello_world is

        constant CLK_FREQ : integer := 24000000;
        constant BLINK_FREQ : integer := 1;
        constant CNT_MAX : integer := CLK_FREQ/BLINK_FREQ/2-1;

        signal clk      : std_logic;
        signal cnt      : unsigned(24 downto 0);
        signal blink    : std_logic;

    begin

        clk <= CLK_24MHZ;

        process(clk)
        begin

            if rising_edge(clk) then
                if cnt=CNT_MAX then
                    cnt <= (others => '0');
                    blink <= not blink;
                else
                    cnt <= cnt + 1;
                end if;
            end if;

        end process;

        LED(7 downto 1) <= "1111111";
        LED(0) <= blink;

    end rtl;
