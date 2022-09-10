import serial, random
from datetime import datetime, timedelta
from crc import CrcCalculator, Configuration

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
    
    fail = [0,0]
    ret = b''
    checksum = bytes([crc.calculate_checksum(data)])
    ser.write(data)
    ser.write(checksum)
    response = ser.read()
    if(response != b'\x06'):
        print("Transmission error occurred. FPGA did not ACK.")
        fail[0] = 1
    for i in range(input_bytes):
        ret = ret + ser.read()
    checksum1 = ser.read()
    if((checksum1 != checksum or ret != data) and not fail[0]):
            print("Reception error occurred. Data sent did not match data received.")
            fail[1] = 1
    #print("Sent: 0x" + data.hex().upper() + " Recv: 0x"+ret.hex().upper())
    return fail

crc_obj = CrcCalculator(fpga_poly)
baud = int_input('Baud Rate: ')
ser = port_input('Port: ')
input_bytes = int_input('Packet payload in bytes: ')
delta_s = int_input('Time to wait in seconds: ')
time_now = datetime.now()
finish_time = time_now + timedelta(seconds = delta_s)
print("Running FPGA design test from " + time_now.strftime("%H:%M:%S") + " until " + finish_time.strftime("%H:%M:%S") + "...")
failures = [0, 0]
tests = 0
while finish_time > time_now:
    T = random.getrandbits(input_bytes*8).to_bytes(input_bytes, "big")
    failures = failures + send_fpga(ser, crc_obj, T)
    time_now = datetime.now()
    tests = tests + 1
print("\nTesting time elapsed, here are the test results: ")
print("Overall tests: " + str(tests))
print("Transmission errors: " + str(failures[0]))
print("Reception errors: " + str(failures[1]))
while True:
    pass