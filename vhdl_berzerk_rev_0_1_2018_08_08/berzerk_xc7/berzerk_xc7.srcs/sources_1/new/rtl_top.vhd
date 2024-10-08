----------------------------------------------------------------------------------
-- Company: Red~Bote
-- Engineer: Glenn Neidermeier
-- 
-- Create Date: 10/06/2024 07:46:55 AM
-- Design Name: 
-- Module Name: rtl_top - RTL
-- Project Name: berzerk by Dar (darfpga@aol.fr)
-- Target Devices: Artix 7
-- Tool Versions: Vivado v2020.2
-- Description: Top-level for Basys 3 board
--   based on DE10_lite Top level berzerk by Dar
-- Dependencies: vhdl_berzerk_rev_0_1_2018_08_08
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity rtl_top is
    port (
        clk : in std_logic;

        btnC : in std_logic;
        btnU : in std_logic;
        btnL : in std_logic;
        btnR : in std_logic;
        btnD : in std_logic;

        sw : in std_logic_vector (15 downto 0);

        JA : in std_logic_vector(4 downto 0);

        O_PMODAMP2_AIN : out std_logic;
        O_PMODAMP2_GAIN : out std_logic;
        O_PMODAMP2_SHUTD : out std_logic;

        vgaRed : out std_logic_vector (3 downto 0);
        vgaGreen : out std_logic_vector (3 downto 0);
        vgaBlue : out std_logic_vector (3 downto 0);
        vgaHsync : out std_logic;
        vgaVsync : out std_logic;

        led : out std_logic_vector (15 downto 0));
end rtl_top;

architecture RTL of rtl_top is

    signal ledr : std_logic_vector(9 downto 0);

    signal clock_10 : std_logic;
    signal reset : std_logic;
    -- signal clock_6   : std_logic;

    -- signal max3421e_clk : std_logic;

    signal r : std_logic;
    signal g : std_logic;
    signal b : std_logic;
    signal hi : std_logic;
    signal csync : std_logic;
    signal hsync : std_logic;
    signal vsync : std_logic;
    signal blankn : std_logic;
    signal tv15Khz_mode : std_logic;

    signal video_r : std_logic_vector(3 downto 0);
    signal video_g : std_logic_vector(3 downto 0);
    signal video_b : std_logic_vector(3 downto 0);

    signal audio : std_logic_vector(15 downto 0);
    signal pwm_accumulator : std_logic_vector(12 downto 0);

    -- alias reset_n         : std_logic is key(0);
    -- alias ps2_clk         : std_logic is gpio(35); --gpio(0);
    -- alias ps2_dat         : std_logic is gpio(34); --gpio(1);
    -- alias pwm_audio_out_l : std_logic is gpio(1);  --gpio(2);
    -- alias pwm_audio_out_r : std_logic is gpio(3);  --gpio(3);

    signal kbd_intr : std_logic;
    signal kbd_scancode : std_logic_vector(7 downto 0);
    signal joyHBCPPFRLDU : std_logic_vector(9 downto 0);
    -- signal keys_HUA      : std_logic_vector(2 downto 0);

    -- signal start : std_logic := '0';
    -- signal usb_report : usb_report_t;
    -- signal new_usb_report : std_logic := '0';

    signal dbg_cpu_di : std_logic_vector(7 downto 0);
    signal dbg_cpu_addr : std_logic_vector(15 downto 0);
    signal dbg_cpu_addr_latch : std_logic_vector(15 downto 0);
    signal dbg_cpu_addr_s : std_logic_vector(15 downto 0);
    alias vga_r : std_logic_vector is vgaRed;
    alias vga_g : std_logic_vector is vgaGreen;
    alias vga_b : std_logic_vector is vgaBlue;
    alias vga_hs : std_logic is vgaHsync;
    alias vga_vs : std_logic is vgaVsync;

    component clk_wiz_0
        port (-- Clock in ports
            -- Clock out ports
            clk_out1 : out std_logic;
            -- Status and control signals
            locked : out std_logic;
            clk_in1 : in std_logic
        );
    end component;

begin

    led(9 downto 0) <= ledr;

    joyHBCPPFRLDU(7) <= not JA(4) and not JA(3); -- coin1 <= fire+up
    joyHBCPPFRLDU(6) <= '0'; -- start2
    joyHBCPPFRLDU(5) <= not JA(4) and not JA(1); --start1 <= fire+left
    joyHBCPPFRLDU(4) <= not JA(4); -- fire1 
    joyHBCPPFRLDU(3) <= not JA(0); -- right1 
    joyHBCPPFRLDU(2) <= not JA(1); -- left1 
    joyHBCPPFRLDU(1) <= not JA(2); -- down1 
    joyHBCPPFRLDU(0) <= not JA(3); -- up1 

    reset <= '0'; -- not reset_n;
    tv15Khz_mode <= '0'; --sw(0);

    -- Clock 10MHz for Berzerk core
    clocks : clk_wiz_0
    port map(
        -- Clock out ports  
        clk_out1 => clock_10,
        -- Status and control signals
        locked => open,
        -- Clock in ports
        clk_in1 => clk
    );

    -- berzerk
    berzerk : entity work.berzerk
        port map(
            clock_10 => clock_10,
            reset => reset,

            tv15Khz_mode => tv15Khz_mode,
            video_r => r,
            video_g => g,
            video_b => b,
            video_hi => hi,
            video_csync => csync,
            video_hs => hsync,
            video_vs => vsync,
            audio_out => audio,

            start2 => joyHBCPPFRLDU(6),
            start1 => joyHBCPPFRLDU(5),
            coin1 => joyHBCPPFRLDU(7),
            cocktail => '1',

            right1 => joyHBCPPFRLDU(3),
            left1 => joyHBCPPFRLDU(2),
            down1 => joyHBCPPFRLDU(1),
            up1 => joyHBCPPFRLDU(0),
            fire1 => joyHBCPPFRLDU(4),

            right2 => joyHBCPPFRLDU(3),
            left2 => joyHBCPPFRLDU(2),
            down2 => joyHBCPPFRLDU(1),
            up2 => joyHBCPPFRLDU(0),
            fire2 => joyHBCPPFRLDU(4),

            sw => (others => '0'), --sw,
            ledr => ledr,
            dbg_cpu_di => dbg_cpu_di,
            dbg_cpu_addr => dbg_cpu_addr,
            dbg_cpu_addr_latch => dbg_cpu_addr_latch
        );

    blankn <= '1'; -- TBA

    -- adapt video to 4bits/color only
    video_r <= "1100" when r = '1' and hi = '1' else
               "0100" when r = '1' and hi = '0' else
               "0000";

    video_g <= "1100" when g = '1' and hi = '1' else
               "0100" when g = '1' and hi = '0' else
               "0000";

    video_b <= "1100" when b = '1' and hi = '1' else
               "0100" when b = '1' and hi = '0' else
               "0000";

    vga_r <= video_r when blankn = '1' else "0000";
    vga_g <= video_g when blankn = '1' else "0000";
    vga_b <= video_b when blankn = '1' else "0000";

    -- synchro composite/ synchro horizontale
    --vga_hs <= csync;
    vga_hs <= csync when tv15Khz_mode = '1' else hsync;
    -- commutation rapide / synchro verticale
    --vga_vs <= '1';
    vga_vs <= '1' when tv15Khz_mode = '1' else vsync;

    -- pwm sound output

    process (clock_10) -- use same clock as sound_board
    begin
        if rising_edge(clock_10) then
            pwm_accumulator <= std_logic_vector(unsigned('0' & pwm_accumulator(11 downto 0)) + unsigned('0' & audio(15 downto 4)));
        end if;
    end process;

    --pwm_audio_out_l <= pwm_accumulator(12);
    --pwm_audio_out_r <= pwm_accumulator(12); 

    -- active-low shutdown pin
    O_PMODAMP2_SHUTD <= sw(14);
    -- gain pin is driven high there is a 6 dB gain, low is a 12 dB gain 
    O_PMODAMP2_GAIN <= sw(15);

    O_PMODAMP2_AIN <= pwm_accumulator(12);

end RTL;
