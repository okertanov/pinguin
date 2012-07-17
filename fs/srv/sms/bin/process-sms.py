#!/usr/bin/env python

##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

import os
import sys
import tempfile

def readInput(ifd):
    buffer = None
    try:
        buffer = ifd.readlines()
    except:
        raise
    return buffer

def dumpMessage(ofd, msg):
    try:
	os.write(ofd, msg)
    except:
        raise
    

def main():
    try:
        message = ''.join( readInput(sys.stdin) )
        if len(message):
            tmpfd, tmpname = tempfile.mkstemp(prefix='sms-', text=True) 
	    dumpMessage(tmpfd, message)
	    os.close(tmpfd)
	    print 'Dump file: {} ok.\n'.format(tmpname)
	    print 'Message: \n {}\n'.format(message)
	else:
	    print 'Dump file: {} failed.\n'.format(tmpname)
	    print 'Message: \n {}\n'.format(message)
    except:
        raise
    sys.exit(0)

if __name__ == '__main__':
    main()


