from distutils.core import setup, Extension

setup(name = 'sensorfusion',
	  version = '0.1',
	  author = 'Benoit Landry, SOH Madgwick',
	  description = '6DOF sensor fusion based on Mahony sensor fusion algorithm, C implementation by Madgwick, Python API by Landry',
	  py_modules = ['sensorfusion'],
	  ext_modules = [Extension('MahonyAHRS', sources=['MahonyAHRS.c'])])