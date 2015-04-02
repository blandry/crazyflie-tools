from distutils.core import setup, Extension

setup(name = 'estimation',
	  version = '0.1',
	  author = 'Benoit Landry',
	  description = 'State estimation for the crazyflie, implements Mahony sensor fusion and Kalman Filter among other things.',
	  ext_modules = [Extension('MahonyAHRS', sources=['MahonyAHRS.c'])])