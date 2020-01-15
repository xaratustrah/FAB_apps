# FIB\_AGC User Manual

### Introduction
This document describes the main functions of the FIB\_AGC module.

### Firmware

The top level entity of the firmware is shown in attachment.


### Registers

Registers in FIB\_AGC are depicted in Table 1.

| Register Number | Register Address | Default Value | Register name From AGC to System | Register name From System to AGC |
|-----------------|------------------|---------------|----------------------------------|----------------------------------|
| 0               | 0x00             | 0xA0          | ←                                | desired\_value\_adc1 (LB)          |
| 1               | 0x01             | 0x0F          | ←                                | desired\_value\_adc1 (HB)          |
| 2               | 0x02             | --            | actual\_value\_adc1 (LB)           | x                                |
| 3               | 0x03             | --            | actual\_value\_adc1 (LB)           | x                                |
| 4               | 0x04             | 0xA0          | ←                                | desired\_value\_adc2 (LB)          |
| 5               | 0x05             | 0x0F          | ←                                | desired\_value\_adc2 (LB)          |
| 6               | 0x06             | --            | actual\_value\_adc2 (LB)           | x                                |
| 7               | 0x07             | --            | actual\_value\_adc2 (HB)           | x                                |
| 8               | 0x08             | 0x98          | ←                                | update\_rate (LWLB)               |
| 9               | 0x09             | 0x3A          | ←                                | update\_rate (LWHB)               |
| 10              | 0x0A             | 0x00          | ←                                | update\_rate (HWLB)               |
| 11              | 0x0B             | 0x00          | ←                                | update\_rate (HWHB)               |
| 12              | 0x0C             | 0xF4          | ←                                | desired\_amplitude\_window (LB)    |
| 13              | 0x0D             | 0x01          | ←                                | desired\_amplitude\_window (HB)    |
| 14              | 0x0E             | 0x32          | ←                                | manual\_gain\_ch1                  |
| 15              | 0x0F             | 0x32          | ←                                | manual\_gain\_ch2                  |
| 16              | 0x10             | --            | actual\_gain\_ch1                  | x                                |
| 17              | 0x11             | --            | actual\_gain\_ch2                  | x                                |
| 18              | 0x12             | 0x00          | ←                                | control\_register                 |
| 19              | 0x13             | --            | status\_register                  | x                                |

The cells with an arrow in the middle column copy the value form the respective cells in the third column.

#### Control Register

| Bit 7        | Bit 6    | Bit 5    | Bit 4    | Bit 3    | Bit 2         | Bit 1         | Bit 0 |
|--------------|----------|----------|----------|----------|---------------|---------------|-------|
| Set Trig Out | Reserved | Reserved | Reserved | Reserved | nAuto/man ch1 | nAuto/man ch2 | reset |

#### Status Register

| Bit 7 | Bit 6      | Bit 5       | Bit 4      | Bit 3       | Bit 2 | Bit 1 | Bit 0 |
|-------|------------|-------------|------------|-------------|-------|-------|-------|
| v     | led\_ch2\_hi | led\_ch2\_low | led\_ch1\_hi | led\_ch1\_low | v     | v     | v     |

The cells with a "v" in the status register copy the value form the respective cells in the control register.

The default values are for the following settings:

* update rate: 300 us
* amplitude window for both channels: 500 (decimal)
* desired amplitude: 4000 (decimal)
* Automatic Gain Control for both channels: on
	* Trigger Output: off
	* Active High Reset: off