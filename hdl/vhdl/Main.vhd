--
--
-- FPGA Display Handler IP Core By Mehran Ahadi (http://mehran.ahadi.me)
-- This IP allows you to draw shapes and print texts on VGA screen.
-- Copyright (C) 2015-2016  Mehran Ahadi
-- This work is released under MIT License.
--
-- Display Component Main Fille
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MainComponent is
	Generic (
		w_pixels:		integer;
		w_fp:			integer;
		w_synch:		integer;
		w_bp:			integer;
		w_syncval:		std_logic;
		
		h_pixels:		integer;
		h_fp:			integer;
		h_synch:		integer;
		h_bp:			integer;
		h_syncval:		std_logic;
		
		display_clk_m:	integer;
		display_clk_d:	integer
	);
	 

	Port (
		CLK: in STD_LOGIC;
		R : out STD_LOGIC_VECTOR(7 downto 0);
		G : out STD_LOGIC_VECTOR(7 downto 0);
		B : out STD_LOGIC_VECTOR(7 downto 0);
		PIXEL_CLK : out  STD_LOGIC;
		COMP_SYNCH : out  STD_LOGIC;
		OUT_BLANK_Z : out  STD_LOGIC;
		HSYNC : out  STD_LOGIC;
		VSYNC : out  STD_LOGIC;
		
		MEMCLK: in std_logic;
		MEMDIN: in std_logic_vector (0 to 0);
		MEMDOUT: out std_logic_vector (0 to 0);
		MEMADDR: in std_logic_vector(19 downto 0);
		MEMWE: in std_logic
	);
	
end MainComponent;

architecture Behavioral of MainComponent is
	-- ## Define Components
	-- DisplayOut
	component DisplayOut
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
	end component;
	
	-- ClockMaker
	component ClockMaker is
		generic (
			multiplier	: integer;
			divider		: integer
		);
		
		port ( CLKIN_IN    : in    std_logic; 
			RST_IN          : in    std_logic; 
			CLKFX_OUT       : out   std_logic; 
			CLKIN_IBUFG_OUT : out   std_logic; 
			LOCKED_OUT      : out   std_logic
		);
	end component;
	
	-- Dual Port Memory
	component DisplayMemoryDual
		port (
		addra: IN std_logic_VECTOR(19 downto 0);
		addrb: IN std_logic_VECTOR(19 downto 0);
		clka: IN std_logic;
		clkb: IN std_logic;
		dina: IN std_logic_VECTOR(0 downto 0);
		dinb: IN std_logic_VECTOR(0 downto 0);
		douta: OUT std_logic_VECTOR(0 downto 0);
		doutb: OUT std_logic_VECTOR(0 downto 0);
		wea: IN std_logic;
		web: IN std_logic
		);
	end component;
	
	-- ## Define Signals
	signal displayClockSignal : std_logic;
	signal displayClockReset : std_logic;
	signal displayClockBuffer : std_logic;
	signal displayClockLocked : std_logic;
	
	signal memoryReadAddress: std_logic_VECTOR(19 downto 0);
	signal memoryOut: std_logic_VECTOR(0 downto 0);
	
	-- ## Define Constants
	-- 640x480@60hz
--	constant displayClockDivider:		integer 		:= 8;
--	constant displayClockMultiplier: 	integer 		:= 2;
--	
--	constant displayWidthPixels:		integer 		:= 640;
--	constant displayWidthFP:			integer 		:= 16;
--	constant displayWidthSynch:			integer 		:= 96;
--	constant displayWidthBP:			integer			:= 48;
--	constant displayWidthSyncVal:		std_logic		:= '0';
--	
--	constant displayHeightPixels:		integer 		:= 480;
----	constant displayHeightFP:			integer 		:= 10;
----	constant displayHeightSynch:		integer 		:= 2;
----	constant displayHeightBP:			integer			:= 33;
--	constant displayHeightFP:			integer 		:= 9;
--	constant displayHeightSynch:		integer 		:= 2;
--	constant displayHeightBP:			integer			:= 29;
--	constant displayHeightSyncVal:		std_logic		:= '0';

	-- 800x600@60hz
--	constant displayClockDivider:		integer 		:= 10;
--	constant displayClockMultiplier: 	integer 		:= 4;
--	
--	constant displayWidthPixels:		integer 		:= 800;
--	constant displayWidthFP:			integer 		:= 40;
--	constant displayWidthSynch:			integer 		:= 128;
--	constant displayWidthBP:			integer			:= 88;
--	constant displayWidthSyncVal:		std_logic		:= '1';
--	
--	constant displayHeightPixels:		integer 		:= 600;
--	constant displayHeightFP:			integer 		:= 1;
--	constant displayHeightSynch:		integer 		:= 4;
--	constant displayHeightBP:			integer			:= 23;
--	constant displayHeightSyncVal:		std_logic		:= '1';

	-- 1024*768@60hz
--	constant displayClockDivider:		integer 		:= 20;
--	constant displayClockMultiplier: 	integer 		:= 13;
--	
--	constant displayWidthPixels:		integer 		:= 1024;
--	constant displayWidthFP:			integer 		:= 24;
--	constant displayWidthSynch:			integer 		:= 136;
--	constant displayWidthBP:			integer			:= 160;
--	constant displayWidthSyncVal:		std_logic		:= '0';
--	
--	constant displayHeightPixels:		integer 		:= 768;
--	constant displayHeightFP:			integer 		:= 3;
--	constant displayHeightSynch:		integer 		:= 6;
--	constant displayHeightBP:			integer			:= 29;
--	constant displayHeightSyncVal:		std_logic		:= '0';

	constant displayClockDivider:		integer 		:= display_clk_d;
	constant displayClockMultiplier: 	integer 		:= display_clk_m;
	
	constant displayWidthPixels:		integer 		:= w_pixels;
	constant displayWidthFP:			integer 		:= w_fp;
	constant displayWidthSynch:			integer 		:= w_synch;
	constant displayWidthBP:			integer			:= w_bp;
	constant displayWidthSyncVal:		std_logic		:= w_syncval;
	
	constant displayHeightPixels:		integer 		:= h_pixels;
	constant displayHeightFP:			integer 		:= h_fp;
	constant displayHeightSynch:		integer 		:= h_synch;
	constant displayHeightBP:			integer			:= h_bp;
	constant displayHeightSyncVal:		std_logic		:= h_syncval;
	
begin
	
	-- ## Connecting Components together
	
	PIXEL_CLK <= displayClockSignal;
	
	-- ClockMaker
	displayClock: ClockMaker
	generic map (
		DIVIDER		=> displayClockDivider,
		MULTIPLIER	=> displayClockMultiplier
	)
	port map (
		CLKIN_IN			=>	CLK,
		RST_IN				=>	displayClockReset,
		CLKFX_OUT			=>	displayClockSignal,
		CLKIN_IBUFG_OUT		=>	displayClockBuffer,
		LOCKED_OUT			=>	displayClockLocked
	);
	
	-- DisplayOut
	display: DisplayOut
	generic map (
		w_pixels		=> displayWidthPixels,
		w_fp			=> displayWidthFP,
		w_synch			=> displayWidthSynch,
		w_bp			=> displayWidthBP,
		w_syncval		=> displayWidthSyncVal,
		
		h_pixels		=> displayHeightPixels,
		h_fp			=> displayHeightFP,
		h_synch			=> displayHeightSynch,
		h_bp			=> displayHeightBP,
		h_syncval		=> displayHeightSyncVal
	)
	port map (
		PIXEL_CLK			=>	displayClockSignal,
		COMP_SYNCH			=>	COMP_SYNCH,
		OUT_BLANK_Z			=>	OUT_BLANK_Z,
		HSYNC				=>	HSYNC,
		VSYNC				=>	VSYNC,
		R					=>	R,
		G					=>	G,
		B					=>	B,
		MEMORY_ADDRESS		=>	memoryReadAddress,
		MEMORY_OUT			=>	memoryOut
	);
	
	-- Display Memory
	memory: DisplayMemoryDual 
	port map (
		clka		=>	MEMCLK,
		dina		=>	MEMDIN,
		douta		=>	MEMDOUT,
		addra		=>	MEMADDR,
		wea			=>  MEMWE,
		
		clkb		=>	displayClockSignal,
		addrb		=>	memoryReadAddress,
		doutb		=>	memoryOut,
		dinb		=> "0",
		web			=> '0'
	);

end Behavioral;

