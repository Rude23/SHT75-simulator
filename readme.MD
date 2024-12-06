# SHT75 Data Stream Simulator

This script simulates a data stream from the **SHT75** sensor sampled through an **Artix-7 FPGA**. This tool is designed for studying data acquisition techniques used in **lab classes** at **Università degli Studi di Napoli Federico II**, part of the **LM17 Master’s degree** program during the academic year **2024-2025**.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Requirements](#requirements)
5. [Copyleft](#copyleft)

---

## Introduction

The script allows you to simulate the data stream from an **SHT75 sensor** through a pair of virtual ports created using **socat**. The data is intended for use in lab classes to practice data acquisition techniques. The simulation allows you to test how software interacts with sensor data in a controlled environment.

---

## Installation

Before using the simulator, you need to create a pair of virtual ports. These will act as the communication channels for sending and receiving data.

1. **Create the virtual ports using `socat`:**

    ```bash
    socat -d -d pty,raw,echo=0 pty,raw,echo=0
    ```

    This command will output something like this:

    ```
    2024/11/18 17:14:16 socat[20128] N PTY is /dev/pts/3
    2024/11/18 17:14:16 socat[20128] N PTY is /dev/pts/4
    2024/11/18 17:14:16 socat[20128] N starting data transfer loop with FDs [5,5] and [7,7]
    ```

    This means you now have two virtual ports:
    - Write to `/dev/pts/3`
    - Listen on `/dev/pts/4`

    You can swap them based on your needs (e.g., write to `/dev/pts/4` and listen on `/dev/pts/3`).

---

## Usage

Now that you’ve set up the virtual ports, you can launch the simulator with the following command:

```bash
bash SHT7-simulator.sh --port '/dev/pts/3' --period 0.25
```
Here:

    --port '/dev/pts/3' specifies the port you want to use for writing the simulated sensor data.
    --period 0.25 specifies the period between each data sample in seconds (in this case, 0.25 seconds).

To check if it’s working, you can use hexdump to monitor the data being written to the port:

    hexdump -v -e '1/1 "%02x "' '/dev/pts/3'

This will display the data in hexadecimal format.
Requirements

To use this script, you'll need the following tools:

- socat: to create virtual ports.
- bash: which is standard shell on most POSIX systems.

### On Debian-based systems (Ubuntu, etc.):
```
sudo apt update
sudo apt install socat bash
```
### On RedHat-based systems (Fedora, CentOS, etc.):
```
sudo yum install socat bash
```
### On macOS:
```
brew install socat
brew install bash
```

## Copyleft

This software is released under the Copyleft license, which means you are free to use, modify, and distribute this software, provided that any derivative works are also licensed under the same terms.

You may copy, modify, and distribute the software, but any modified versions must remain open and share the same freedoms.
Please include this Copyleft notice in any copies of the software or modifications that you distribute.
