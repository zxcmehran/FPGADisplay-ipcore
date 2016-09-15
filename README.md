# FPGA Display (IP Core)

FPGA Display Handler IP Core lets you drive VGA Displays using a VGA DAC connected to a FPGA. It's mainly designed to run along a PowerPC embedded processor. It should be possible to run along MicroBlaze Cores but it's not tested yet. 

You can also use it on a bare FPGA without any embedded processors with a limited functionality. It uses a generated RAM block as **VGA Display Memory** to store the pixel data to be displayed over the screen. All you have to do is to fill memory blocks by either implementing a logic on FPGA context or using a embedded processor.

## Installing
This repository contains **main IP Core files**. Clone it in a directory named `display_handler_v1_00_a` under `pcores` directory in your project root or in global user peripheral repository of your EDK installation.

    $ cd [project dir or global repo]
    $ cd pcores
    $ git clone https://github.com/zxcmehran/FPGADisplay-ipcore.git display_handler_v1_00_a

After cloning, just add the IP core from IP Catalog, then connect PLB Bus connection, Clock reference, and external VGA DAC signals. Do not forget to edit project UCF file according to your hardware pins. Then you should assign an address range of 1M words long to `C_MEM0_BASEADDR` be able to access all memory blocks from application context.

You can also customize display resolution on IP configuration menu. You can refer to [pixel timings table](http://static.ahadi.me/projects/fpga-display/pixeltimings.html) to set sync signals in the proper way. Accordingly, you should choose proper multiplier and divider parameters for main clock signal to produce required pixel clock frequency. As an example, choosing the multiplier as `display_clk_m = 8` and the divider as `display_clk_d = 2` produces a 25MHz clock signal from 100MHz main clock which is a suitable setup for `640x480@60Hz` mode. Please note that the default memory size is considered `1,024 * 1,024 = 1,048,576` blocks long and output resolution would be limited to `1024x1024` points. Practically, maximum standard display resolution will be `1024x768`. You can use bigger memories to achieve higher resolutions if you have enough resources.

**Next Step:** You need IP Drivers to be able to use full programmatic functionality. Check [FPGADisplay-driver](https://github.com/zxcmehran/FPGADisplay-driver) repository for installation details.

## Using on bare FPGA
In order to use this as a component on bare FPGA without using any processors, You can include these files in your design to drive VGA display monitor. Component top module is defined on `Main.vhd` file.

    /hdl/vhdl/ClockMaker.vhd
    /hdl/vhdl/DisplayMemoryDual.vhd
    /hdl/vhdl/DisplayOut.vhd
    /hdl/vhdl/Main.vhd

The display memory placed on `DisplayMemoryDual.vhd` is a dual port memory. One set of the ports are used to set pixel data and the other ones, which are extracted as component ports named with `MEM` prefix, can be used by designer to edit memory blocks. You have to implement a suitable logic to manage display memory contents according to your needs. 

## Limitations
As the resources are limited in FPGAs, memory width is chosen just a single bit wide. Thus, each pixel can be either white or black. Plus, maximum supported resolution will be limited to memory length which is `1,024 * 1,024 = 1,048,576` blocks by default. If you have more resources or using a DDR module in your design, then you can use higher resoultions and even extend the width to 24 bits (8 for each signal of R, G, and B) to have full 16 million colors for each pixel. As another limitation, higher resolutions / refresh rates need higher ranges of frequency support by both FPGA and DAC.

## License
This is a B.Sc Project of Electrical Engineering by **[Mehran Ahadi](https://mehran.ahadi.me/)**. Its published under
**[MIT](https://tldrlegal.com/license/mit-license) license**. Please include the copyright and the license notice in all copies or substantial uses of the work.
