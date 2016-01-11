import sys, threading, time

class ProgressBase(threading.Thread):
    """Base class - not to be instanciated."""

    def __init__(self):
        self.rlock = threading.RLock()
        self.cv = threading.Condition()
        threading.Thread.__init__(self)
        self.setDaemon(1)

    def __call__(self):
        self.start()

    def start(self):
        self.stopFlag = 0
        threading.Thread.start(self)

    def stop(self):
        """To be called by the 'main' thread: Method will block
        and wait for the thread to stop before returning control
        to 'main'."""

        self.stopFlag = 1

        # Wake up 'Sleeping Beauty' ahead of time (if it needs to)...
        self.cv.acquire()
        self.cv.notify()
        self.cv.release()

        # Block and wait here untill thread fully exits its run method.
        self.rlock.acquire()

class Dotter(ProgressBase):
    """Print 'animated' sequence of dots - one per sec."""

    def __init__(self, seq='. ', speed=1):
        self.__seq = seq
        self.__speed = speed
        self.inplace = 0
        ProgressBase.__init__(self)

    def run(self):
        self.cv.acquire()
        self.rlock.acquire()
        while 1:
            self.cv.wait(self.__speed)      # 'Sleeping Beauty' part
            if self.stopFlag:
                try:
                    return                              ### >>>
                finally:
                    # release lock immediatley after returning
                    self.rlock.release()
            if self.inplace: sys.stdout.write('\b')
            sys.stdout.write(self.__seq)
            sys.stdout.flush()

def dotIt(seq, fnct, *args, **kwargs):
    """Displays progress dots (1 per sec) while the fnct executes"""

    indicator = Dotter(seq, speed=1)
    indicator.start() # prints sequence of dots, 1 dot per second
    fnct(*args, **kwargs)
    indicator.stop()
