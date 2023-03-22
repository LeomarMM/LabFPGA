import serial, random
from datetime import datetime, timedelta
from crc import Calculator, Configuration
from LabFPGA import send_fpga

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

crc_obj = Calculator(fpga_poly)
baud = int_input('Baud Rate: ')
ser = port_input('Port: ')
input_bytes = int_input('Packet payload in bytes: ')
delta_s = int_input('Time to wait in seconds: ')
time_now = datetime.now()
finish_time = time_now + timedelta(seconds = delta_s)
print("Running FPGA design test from " + time_now.strftime("[%d/%b/%Y - %H:%M:%S]") + " until " + finish_time.strftime("[%d/%b/%Y - %H:%M:%S]") + "...")
failures = [0, 0, 0]
tests = 0

while finish_time > time_now:
    T = random.getrandbits(input_bytes*8).to_bytes(input_bytes, "big")
    ret_fpga = send_fpga(input_bytes, ser, crc_obj, T)
    failures[0] += ret_fpga["TransmissionRetries"]
    failures[1] += ret_fpga["ReceptionRetries"]
    failures[2] += (ret_fpga["SentData"] != ret_fpga["RecvData"])
    time_now = datetime.now()
    tests = tests + 1
print("\nTesting time elapsed, here are the test results: ")
print("Overall tests: " + str(tests))
print("Transmission errors: " + str(failures[0]))
print("Reception errors: " + str(failures[1]))
print("Data mismatch errors: " + str(failures[2]))
while True:
    pass