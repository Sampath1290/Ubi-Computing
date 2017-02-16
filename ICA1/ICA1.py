import serial, numpy, struct, time
from collections import deque
import matplotlib.pyplot as plt

ser = serial.Serial(port = '/dev/cu.usbmodem14422', baudrate = 9600)
print(ser.isOpen()) 

ser.flush()

size_of_queue = 300
init_queue_value = -1
data = deque([init_queue_value] * size_of_queue)

ax = plt.axes(xlim = (0, 300), ylim = (-10, 270))
line, = plt.plot(data)

plt.ion()
plt.show()

try:
	while True:
		if(ser.inWaiting() > 0):
			new_input = ser.read(1)
			value = int.from_bytes(new_input, byteorder='big')
			print(value)

			data.appendleft(value)
			data.pop()

			line.set_ydata(data)
			plt.draw()

			plt.pause(.0001)

			#print(value)
finally:
	ser.close()