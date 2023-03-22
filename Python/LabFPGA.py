import serial #pyserial
from crc import Crc8, Configuration

def send_fpga(input_bytes, ser, crc, data):

    ##Transmission
    response = b'\x15'
    sent_checksum = bytes([crc.calculate_checksum(data)])
    tx_fails = -1
    rx_fails = -1
    print("\n\n====================================================")
    print("Sent Data: 0x" + data.hex().upper() + " - Checksum: 0x" + sent_checksum.hex().upper())
    while(response != b'\x06'):
        tx_fails += 1
        ser.write(data)
        ser.write(sent_checksum)
        response = ser.read()
        if(response == b'\x06'):
            print("Response: ACK")
        elif(response == b'\x15'):
            print("Response: NAK")
        else:
            print("Unknown Response: "+response.hex().upper())

    print("FPGA Data: 0x", end='')

    ##Reception
    while(True):
        rx_fails += 1
        recv_msg = b''
        for i in range(input_bytes):
            recv_msg = recv_msg + ser.read()
        fpga_checksum = ser.read()
        print(recv_msg.hex().upper(), end='')
        print(" - Checksum: 0x" + fpga_checksum.hex().upper())
        checksum = bytes([crc.calculate_checksum(recv_msg)])
        if(checksum == fpga_checksum):
            print("Message acknowledged: Sending ACK.")
            ser.write(b'\x06')
            break
        print("Message corrupted: Sending NAK.")
        ser.write(b'\x15')
    print("====================================================\n\n")

    ret_dict = {
        "SentData" : data,
        "RecvData" : recv_msg,
        "TransmissionRetries" : tx_fails,
        "ReceptionRetries" : rx_fails
    }
    return ret_dict