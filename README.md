# FPGA Display (IP Core)

FPGA Display lets you drive VGA Displays using a VGA DAC connected to the FPGA. It's mainly designed to run along a PowerPC embedded processor. It should be possible to run on MicroBlaze Cores but it have not been tested.

You can use it on a bare FPGA without any embedded processors with a limited functionality. Refer to documentation for more info.

It uses a generated RAM block as VGA Display Memory to store pixel data to be displayed.

TODO: Add documentation.

## Installing
This repository contains **main IP Core files**. Clone it in a directory named `display_handler_v1_00_a` under `pcores` directory in your project root or in global user peripheral repository of your EDK installation.

    $ cd [project dir or global repo]
    $ cd pcores
    $ git clone https://github.com/zxcmehran/FPGADisplay-ipcore.git display_handler_v1_00_a

After cloning, just add the IP core from IP Catalog, then connect PLB Bus connection, Clock reference, and external VGA DAC signals. You can also customize display resolution on IP configuration menu.

**Note:** You need IP Drivers to be able to use full programmatic functionality. Check [FPGADisplay-driver](https://github.com/zxcmehran/FPGADisplay-driver) repository for installation details.


## License
This is a B.Sc Project of Electrical Engineering by **Mehran Ahadi**. Its published under
**[MIT](https://tldrlegal.com/license/mit-license) license**. Please include the copyright and the license notice in all copies or substantial uses of the work.
