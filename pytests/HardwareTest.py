import serial #pyserial
from crc import CrcCalculator, Crc8, Configuration

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

def send_fpga(ser, crc, data):
    
    checksum = bytes([crc.calculate_checksum(data)])
    print("\n\n====================================================")
    print("Sent Data: 0x" + data.hex().upper() + " - Checksum: 0x" + checksum.hex().upper())
    ser.write(data)
    ser.write(checksum)
    ##response = b'\x06'
    response = ser.read()
    if(response == b'\x06'):
        print("Response: ACK")
    elif(response == b'\x15'):
        print("Response: NAK")
    else:
        print("Unknown Response: "+response.hex().upper())
    print("FPGA Data: 0x", end='')
    for i in range(input_bytes):
        ret = ser.read()
        print(ret.hex().upper(), end='')
    print(" - Checksum: 0x" + ser.read().hex().upper())
    print("====================================================\n\n")

crc_obj = CrcCalculator(fpga_poly)
baud = int_input('Baud Rate: ')
ser = port_input('Port: ')
input_bytes = int_input('Packet payload in bytes: ')
while(1):
    b = int_input('Value to send: ').to_bytes(input_bytes, byteorder='big')
    send_fpga(ser, crc_obj, b)