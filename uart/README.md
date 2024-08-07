### Universal Asynchronous Receiver-Transmitter
UART (Universal Asynchronous Receiver/Transmitter) is a hardware communication protocol used for serial communication. The basic uart_rx and uart_tx are of '8-N-1' configuration, refers to the specific settings used for the data transmission:

- 8: 8 data bits per character.
- N: No parity bit (i.e. parity is not used for error checking).
- 1: 1 stop bit at the end of each character to signal the end of a data packet.

This is a common setting for many serial communication applications and is often used for straightforward and reliable data exchange between devices.

This is implemented using a youtube video by hhp3 as reference.
Link to the video: https://youtu.be/Wsou_zhCEYQ?si=FeXZFN3S9BWOEmwI

Todo: Add parity bit for data integrity.
Todo: Implement other uart modes with option of selection.
