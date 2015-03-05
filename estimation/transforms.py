
import numpy as np
from math import atan2, asin, cos, sin


def quat2rpy(q):
	q_norm = (q[0]**2+q[1]**2+q[2]**2+q[3]**2)
	q = [q_i/q_norm for q_i in q]
	w = q[0]
	x = q[1]
	y = q[2]
	z = q[3]
	rpy = [atan2(2*(w*x + y*z), w*w + z*z - (x*x + y*y)),
  		   asin(2*(w*y - z*x)),
           atan2(2*(w*z + x*y), w*w + x*x - (y*y + z*z))]
	return rpy

def rotx(theta):
    c = cos(theta)
    s = sin(theta)
    M = np.matrix([[1,0,0],[0,c,-s],[0,s,c]])
    return M

def roty(theta):
    c = cos(-theta)
    s = sin(-theta)
    M = np.matrix([[c,0,-s],[0,1,0],[s,0,c]])
    return M

def rotz(theta):
    c = cos(theta)
    s = sin(theta)
    M = np.matrix([[c,-s,0],[s,c,0],[0,0,1]])
    return M

def rpy2rotmat(rpy):
    R = np.dot(rotz(rpy[2]),np.dot(roty(rpy[1]),rotx(rpy[0])))
    return R

def body2world(rpy, xyz):
    R = rpy2rotmat(rpy)
    xyz_world = np.dot(R,np.array(xyz).transpose())
    return (np.array(xyz_world)[0]).tolist()

def angularvel2rpydot(rpy, omega):
	p = rpy[1]
	y = rpy[2]
	sy = sin(y)
	cy = cos(y)
	sp = sin(p)
	cp = cos(p)
	tp = sp/cp
	Phi = np.matrix([[cy/cp, sy/cp, 0],[-sy, cy, 0],[cy*tp, tp*sy, 1]])
	rpydot = np.dot(Phi,np.array(omega).transpose())
	return (np.array(rpydot)[0]).tolist()