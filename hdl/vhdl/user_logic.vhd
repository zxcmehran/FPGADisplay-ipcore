--
--
-- FPGA Display Handler IP Core By Mehran Ahadi (http://mehran.ahadi.me)
-- This IP allows you to draw shapes and print texts on VGA screen.
-- Copyright (C) 2015-2016  Mehran Ahadi
-- This work is released under MIT License.
--
-- IP Logic File
--
------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Mon Aug 08 23:53:04 2016 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v2_00_a;
use proc_common_v2_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_AWIDTH                 -- Slave interface address bus width
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--   C_NUM_MEM                    -- Number of memory spaces
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Addr                  -- Bus to IP address bus
--   Bus2IP_CS                    -- Bus to IP chip select for user logic memory selection
--   Bus2IP_RNW                   -- Bus to IP read/not write
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
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
	display_clk_d:	integer;
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_AWIDTH                   : integer              := 32;
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 2;
    C_NUM_MEM                      : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
	CLK: in STD_LOGIC;
	R : out STD_LOGIC_VECTOR(7 downto 0);
	G : out STD_LOGIC_VECTOR(7 downto 0);
	B : out STD_LOGIC_VECTOR(7 downto 0);
	PIXEL_CLK : out  STD_LOGIC;
	COMP_SYNCH : out  STD_LOGIC;
	OUT_BLANK_Z : out  STD_LOGIC;
	HSYNC : out  STD_LOGIC;
	VSYNC : out  STD_LOGIC;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Addr                    : in  std_logic_vector(0 to C_SLV_AWIDTH-1);
    Bus2IP_CS                      : in  std_logic_vector(0 to C_NUM_MEM-1);
    Bus2IP_RNW                     : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic

	component MainComponent
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
		
	end component;

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 1);
  signal slv_reg_read_sel               : std_logic_vector(0 to 1);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

  ------------------------------------------
  -- Signals for user logic memory space example
  ------------------------------------------
  type BYTE_RAM_TYPE is array (0 to 255) of std_logic_vector(0 to 7);
  type DO_TYPE is array (0 to C_NUM_MEM-1) of std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal mem_data_out                   : DO_TYPE;
  signal mem_address                    : std_logic_vector(0 to 7);
  signal mem_select                     : std_logic_vector(0 to 0);
  signal mem_read_enable                : std_logic;
  signal mem_read_enable_dly1           : std_logic;
  signal mem_read_req                   : std_logic;
  signal mem_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal mem_read_ack_dly1              : std_logic;
  signal mem_read_ack                   : std_logic;
  signal mem_write_ack                  : std_logic;

	signal MEMCLK: std_logic;
	signal MEMDIN: std_logic_vector(0 to 0);
	signal MEMDOUT: std_logic_vector(0 to 0);
	signal MEMADDR: std_logic_vector(19 downto 0);
	signal MEMWE: std_logic;

begin

  --USER logic implementation added here


	-- Initialize display main component
	mainHandle: MainComponent
	Generic map (
		w_pixels 		=>w_pixels,
		w_fp 			=>w_fp,
		w_synch 		=>w_synch,
		w_bp 			=>w_bp,
		w_syncval 		=>w_syncval,
		
		h_pixels 		=>h_pixels,
		h_fp	 		=>h_fp,
		h_synch 		=>h_synch,
		h_bp	 		=>h_bp,
		h_syncval 		=>h_syncval,
		
		display_clk_m 	=>display_clk_m,
		display_clk_d 	=>display_clk_d
	)
	Port map (
		CLK => CLK,
		R => R,
		G => G,
		B => B,
		PIXEL_CLK => PIXEL_CLK,
		COMP_SYNCH => COMP_SYNCH,
		OUT_BLANK_Z => OUT_BLANK_Z,
		HSYNC => HSYNC,
		VSYNC => VSYNC,

		MEMCLK => MEMCLK,
		MEMDIN => MEMDIN,
		MEMDOUT => MEMDOUT,
		MEMADDR => MEMADDR,
		MEMWE => MEMWE
	);


  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 1);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 1);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "10" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "01" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1 ) is
  begin

    case slv_reg_read_sel is
      when "10" => slv_ip2bus_data <= slv_reg0;
      when "01" => slv_ip2bus_data <= slv_reg1;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to access user logic memory region
  -- 
  -- Note:
  -- The example code presented here is to show you one way of using
  -- the user logic memory space features. The Bus2IP_Addr, Bus2IP_CS,
  -- and Bus2IP_RNW IPIC signals are dedicated to these user logic
  -- memory spaces. Each user logic memory space has its own address
  -- range and is allocated one bit on the Bus2IP_CS signal to indicated
  -- selection of that memory space. Typically these user logic memory
  -- spaces are used to implement memory controller type cores, but it
  -- can also be used in cores that need to access additional address space
  -- (non C_BASEADDR based), s.t. bridges. This code snippet infers
  -- 1 256x32-bit (byte accessible) single-port Block RAM by XST.
  ------------------------------------------
--  mem_select      <= Bus2IP_CS;
--  mem_read_enable <= ( Bus2IP_CS(0) ) and Bus2IP_RNW;
--  mem_read_ack    <= mem_read_ack_dly1;
--  mem_write_ack   <= ( Bus2IP_CS(0) ) and not(Bus2IP_RNW);
--  mem_address     <= Bus2IP_Addr(C_SLV_AWIDTH-10 to C_SLV_AWIDTH-3);
--
--  -- implement single clock wide read request
--  mem_read_req    <= mem_read_enable and not(mem_read_enable_dly1);
--  BRAM_RD_REQ_PROC : process( Bus2IP_Clk ) is
--  begin
--
--    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
--      if ( Bus2IP_Reset = '1' ) then
--        mem_read_enable_dly1 <= '0';
--      else
--        mem_read_enable_dly1 <= mem_read_enable;
--      end if;
--    end if;
--
--  end process BRAM_RD_REQ_PROC;
--
--  -- this process generates the read acknowledge 1 clock after read enable
--  -- is presented to the BRAM block. The BRAM block has a 1 clock delay
--  -- from read enable to data out.
--  BRAM_RD_ACK_PROC : process( Bus2IP_Clk ) is
--  begin
--
--    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
--      if ( Bus2IP_Reset = '1' ) then
--        mem_read_ack_dly1 <= '0';
--      else
--        mem_read_ack_dly1 <= mem_read_req;
--      end if;
--    end if;
--
--  end process BRAM_RD_ACK_PROC;

  -- implement Block RAM(s)
--  BRAM_GEN : for i in 0 to C_NUM_MEM-1 generate
--    constant NUM_BYTE_LANES : integer := (C_SLV_DWIDTH+7)/8;
--  begin

--    BYTE_BRAM_GEN : for byte_index in 0 to ((C_SLV_DWIDTH+7)/8)-1 generate
--      signal ram           : BYTE_RAM_TYPE;
--      signal write_enable  : std_logic;
--      signal data_in       : std_logic_vector(0 to 7);
--      signal data_out      : std_logic_vector(0 to 7);
--      signal read_address  : std_logic_vector(0 to 7);
--    begin
--
--      write_enable <= not(Bus2IP_RNW) and
--                      Bus2IP_CS(0) and
--                      Bus2IP_BE(byte_index);
--
--      data_in <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--      mem_data_out(0)(byte_index*8 to byte_index*8+7) <= data_out;
--
--      BYTE_RAM_PROC : process( Bus2IP_Clk ) is
--      begin
--
--        if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
--          if ( write_enable = '1' ) then
--            ram(CONV_INTEGER(mem_address)) <= data_in;
--          end if;
--          read_address <= mem_address;
--        end if;
--
--      end process BYTE_RAM_PROC;
--
--      data_out <= ram(CONV_INTEGER(read_address));
--
--    end generate BYTE_BRAM_GEN;
--
----  end generate BRAM_GEN;
--
--  -- implement Block RAM read mux
--  MEM_IP2BUS_DATA_PROC : process( mem_data_out, mem_select ) is
--  begin
--
--    case mem_select is
--      when "1" => mem_ip2bus_data <= mem_data_out(0);
--      when others => mem_ip2bus_data <= (others => '0');
--    end case;
--
--  end process MEM_IP2BUS_DATA_PROC;


-- Commented BRAM block generated by XPS custom peripheral wizard
-- Connecting second port of Display Memory to PLB Bus.


	-- Translate address bits order
	ADDR_TRANSLATE: for i in 0 to 19 generate
		MEMADDR(i) <= Bus2IP_Addr (31-i);  
		-- Connect 31 to 0, ..., 12 to 19
	end generate;
	
	MEMCLK <= Bus2IP_Clk;

	mem_read_enable <= Bus2IP_RNW and
				  Bus2IP_CS(0) and
				  (Bus2IP_BE(0) 
				  or Bus2IP_BE(1) 
				  or Bus2IP_BE(2) 
				  or Bus2IP_BE(3)
				  );
	-- Used to delay read acknowledgement signal for 1 clock, to let memory loading the data.
	process (Bus2IP_Clk) is
	begin
		if ( Bus2IP_Clk'event and Bus2IP_Clk = '1') then
		
		  mem_read_ack <= '0';
		  
		  if mem_read_enable = '1' then 
			  if (mem_read_ack_dly1 = '0') then
				mem_read_ack_dly1 <= '1';
			  else
				mem_read_ack <= '1';
				mem_read_ack_dly1 <= '0';
			  end if;
		  end if;
		end if;
	end process;
		  
	mem_write_ack <= not(Bus2IP_RNW) and
				  Bus2IP_CS(0) and
				  (Bus2IP_BE(0) 
				  or Bus2IP_BE(1) 
				  or Bus2IP_BE(2) 
				  or Bus2IP_BE(3)
				  );
				  
	MEMWE <= mem_write_ack;
		 
	MEMDIN(0) <= Bus2IP_Data(31);
	
	-- PLB Bus is 32 bits wide. We're going to use 8 bit selections.
	-- Thus, we assign every 8 bit to our disired value to get rid of Bus2IP_BE signal.
	mem_ip2bus_data(7) <= MEMDOUT(0);
	mem_ip2bus_data(15) <= MEMDOUT(0);
	mem_ip2bus_data(23) <= MEMDOUT(0);
	mem_ip2bus_data(31) <= MEMDOUT(0);
	

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  mem_ip2bus_data when mem_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack or mem_write_ack;
  IP2Bus_RdAck <= slv_read_ack or mem_read_ack;
  IP2Bus_Error <= '0';

end IMP;
