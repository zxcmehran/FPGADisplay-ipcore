--
--
-- FPGA Display Handler IP Core By Mehran Ahadi (http://mehran.ahadi.me)
-- This IP allows you to draw shapes and print texts on VGA screen.
-- Copyright (C) 2015-2016  Mehran Ahadi
-- This work is released under MIT License.
--
-- VGA Signal Generator File
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DisplayOut is
	 
	Generic (
		w_pixels:	integer;
		w_fp:			integer;
		w_synch:		integer;
		w_bp:			integer;
		w_syncval:	std_logic;
		
		h_pixels:	integer;
		h_fp:			integer;
		h_synch:		integer;
		h_bp:			integer;
		h_syncval:	std_logic
	);
	 
	Port (
		PIXEL_CLK :in  STD_LOGIC;
		COMP_SYNCH : out  STD_LOGIC;
		OUT_BLANK_Z : out  STD_LOGIC;
		HSYNC : out  STD_LOGIC;
		VSYNC : out  STD_LOGIC;
		R : out STD_LOGIC_VECTOR(7 downto 0);
		G : out STD_LOGIC_VECTOR(7 downto 0);
		B : out STD_LOGIC_VECTOR(7 downto 0);
		MEMORY_ADDRESS: OUT std_logic_VECTOR(19 downto 0);
		MEMORY_OUT: IN std_logic_VECTOR(0 downto 0)
	);
end DisplayOut;

architecture Behavioral of DisplayOut is

	constant w_total : integer := w_pixels + w_fp + w_synch + w_bp;
	constant h_total : integer := h_pixels + h_fp + h_synch + h_bp;
	
begin

	COMP_SYNCH <= '0'; -- Disable "sync on green"
	
	R <= (others => MEMORY_OUT(0));
	G <= (others => MEMORY_OUT(0));
	B <= (others => MEMORY_OUT(0));
	
	process(PIXEL_CLK)
		variable clk_x: integer range 0 to w_total - 1 := 0;
		variable clk_y: integer range 0 to h_total - 1 := 0;
		variable clk_xy: STD_LOGIC_VECTOR (19 downto 0) := "00000000000000000000"; -- 1048576 = 2 ^ 20 as we have 20 bits.
	begin
		if PIXEL_CLK'event and PIXEL_CLK='1' then
		
			-- VGA Signals
			if clk_x < w_pixels + w_fp or clk_x >= w_pixels + w_fp + w_synch then
				HSYNC <= not w_syncval; -- not on synch location
			else
				HSYNC <= w_syncval; -- on synch location
			end if;
			
			if clk_y < h_pixels + h_fp or clk_y >= h_pixels + h_fp + h_synch then
				VSYNC <= not h_syncval; -- not on synch location
			else
				VSYNC <= h_syncval; -- on synch location
			end if;
			
			if clk_x >= w_pixels or clk_y >= h_pixels then 
				OUT_BLANK_Z <= '0';
			else
				OUT_BLANK_Z <= '1';
			end if;
			
			-- Increment coordinate counters
			if clk_x < w_total - 1 then
				clk_x := clk_x + 1;
			else
				clk_x := 0;
				if clk_y < h_total - 1 then
					clk_y := clk_y + 1;
				else
					clk_y := 0;
				end if;
			end if;
			
			
			-- Let it be one clock ahead
			if clk_x = w_pixels - 1 then 
				if clk_y < h_pixels - 1 then
					clk_xy (19 downto 10) := clk_xy (19 downto 10) + 1;
					clk_xy (9 downto 0) := "0000000000";
				elsif clk_y = h_total - 1 then
					clk_xy := "00000000000000000000";
				end if;
				
			elsif clk_x < w_pixels - 1 then
				-- add up
				clk_xy := clk_xy + '1';
			end if;

			MEMORY_ADDRESS <= clk_xy;
			
		end if;
	end process;
	
end Behavioral;

