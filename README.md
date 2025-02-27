The project implements a wheeled vehicle controller on an FPGA. As part of this, control of DC motors, servomechanisms, and ultrasonic sensors has been developed. Control data is received via UART from a Bluetooth module placed on the vehicle.

The communication method can be changed. Since both the UART receiver and transmitter are described, it is possible to use other communication modules.

The project is designed to run on a Cyclone IV E family FPGA. Due to the absence of IP cores, the project can be transferred between devices from different vendors. The only necessary adjustment is replacing certain constant values related to the 50 MHz clock (specific locations are marked with comments).
