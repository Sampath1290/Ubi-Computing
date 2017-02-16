import serial
import ringbuffer
import numpy as np
import time
import threading
import matplotlib
#matplotlib.use('TKAgg')
from matplotlib import animation
from matplotlib.lines import Line2D
from matplotlib import pyplot as plt

BUFFER_SIZE = 500
data = ringbuffer.RingBuffer(BUFFER_SIZE)

serial_port = serial.Serial('/dev/cu.usbmodem14322', baudrate=57600, timeout=1)
serial_port.flush()

fig = plt.figure()

# setup the plot
# ax1 = fig.add_subplot(2, 1, 1)
# ax1.set_xlim(0, BUFFER_SIZE-1)
# ax1.set_ylim(-5, 300)
# line1 = Line2D([], [], color='red', linewidth=0.5)
# ax1.add_line(line1)

ax1 = plt.axes(xlim=(0, BUFFER_SIZE-1),ylim=(-5, 300))
line1 = Line2D([], [], color='red', linewidth=0.5)
ax1.add_line(line1)

print("before stuff goes down")

def read_serial_forever():
    global data
    while True:
        try:
            values = serial_port.read(1)
        except:
            print('Exiting thread')
            break
            
        if values:
            tmp = np.array(list(values))

            data.insert_new(tmp.astype(np.int))

            _min = np.min(data.get_samples)
            _max = np.max(data.get_samples)

            #print(_min, _max)

            if _min < 5 and _max > 250:
            	print("touching")
            elif _min < 5: 
            	print("touching and grounded")
            elif _min < 50:
            	print("hovering")
            else:
            	print("nothing")


t = threading.Thread(target=read_serial_forever, args=())
t.start()

# initialization, plot nothing (this is also called on resize)
def init():
    # called on first plot or redraw
    line1.set_data([], [])  # just draw blank background
    return line1,


# animation function.  This is called sequentially, after calling plt.show() (on main thread)
def animate(i):
    # generate some data to draw
    x = np.linspace(0, BUFFER_SIZE-1, BUFFER_SIZE)
    y = data.get_samples
    line1.set_data(x, y)
    # return line(s) to be drawn
    return line1,

# call the animator.  blit=True means only re-draw the parts that have changed.
anim = animation.FuncAnimation(fig,  # the figure to use
                               animate,  # the function to call
                               init_func=init,  # the function to init the drawing with
                               frames=BUFFER_SIZE,  # the max value of "i" in the animate function, before resetting
                               interval=20,  # 20 ms between each call
                               blit=False)  # do not redraw anything that stays the same between animations

plt.show()

serial_port.close() # will cause error, forcing close of thread
t.join() # wait for thread to exit