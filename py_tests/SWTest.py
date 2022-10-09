import serial #pyserial
from crc import CrcCalculator, Crc8, Configuration
from LabFPGA import send_fpga

input_bytes = 11
fpga_poly = Configuration(
    width=8,
    polynomial=0x2F,
    init_value=0x00,
    final_xor_value=0x00,
    reverse_input=False,
    reverse_output=False,
)

def int_input(str):
    while True:
        try:
            print(str, end='')
            a = int(input())
            return a
        except Exception:
            print("Error reading input.")

def port_input(str):
    while True:
        try:
            print(str, end='')
            a = serial.Serial(input(), baud)
            return a
        except Exception:
            print("Error acquiring port.")

crc_obj = CrcCalculator(fpga_poly)
baud = int_input('Baud Rate: ')
ser = port_input('Port: ')
while(1):
    b = int_input('Value to send: ').to_bytes(2, byteorder='big')
    b = b + b'\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    print(send_fpga(input_bytes, ser, crc_obj, b))