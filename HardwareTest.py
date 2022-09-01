import serial
from crc import CrcCalculator, Crc8, Configuration
input_bytes=11
def send_fpga(ser, crc, data):
    
    checksum = bytes([crc.calculate_checksum(data)])
    print("\n\n====================================================")
    print("Data: 0x" + data.hex().upper() + " - Checksum: 0x" + checksum.hex().upper())
    ser.write(data)
    ser.write(checksum)
    response = ser.read()
    if(response == b'\x06'):
        print("Response: ACK")
    elif(response == b'\x15'):
        print("Response: NAK")
    else:
        print("Unknown Response: "+response.hex().upper())
    print("====================================================\n\n")
fpga_poly = Configuration(
    width=8,
    polynomial=0x2F,
    init_value=0x00,
    final_xor_value=0x00,
    reverse_input=False,
    reverse_output=False,
)

crc_obj = CrcCalculator(fpga_poly)
print('Baud Rate: ', end='')
baud = int(input())
print('Port: ', end='')
ser = serial.Serial(input(), baud)

while(1):
    print('Value to send: ', end='')
    b = int(input()).to_bytes(input_bytes, byteorder='big')
    send_fpga(ser, crc_obj, b)
