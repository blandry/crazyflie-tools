
from numpy import dot, array, concatenate, eye, zeros
import numpy as np
from transforms import body2world, angularvel2rpydot, rpy2rotmat

class DoubleIntegrator():

    # (acc in Gs in body frame)
    # states: x y z dx dy dz accxbias accybias acczbias
    # inputs: roll pitch yaw accx accy accz
    # measurements: x y z dx dy dz

    def fx(self, state, control_input, dt):
        """ computes the next x[k+1] from x[k], u[k], dt 

        returns x[k+1] and dx[k+1]/dx[k]

        """
        
        g = array([0,0,-9.81]).reshape(3,1)

        rk = state[0:3].reshape(3,1)
        vk = state[3:6].reshape(3,1)
        bfk = 9.81*state[6:9].reshape(3,1)

        Ck = array(rpy2rotmat(control_input[0:3])).T
        ftildak = 9.81*control_input[3:6].reshape(3,1)

        fhatk = ftildak - bfk

        rk1 = rk + dt*vk + (dt**2/2)*(dot(Ck.T,fhatk)+g)
        vk1 = vk + dt*(dot(Ck.T,fhatk)+g)
        bfk1 = bfk

        xk1 = concatenate([rk1,vk1,bfk1],0)

        F1 = concatenate([eye(3),dt*eye(3),-(dt**2/2)*Ck.T],1)
        F2 = concatenate([zeros([3,3]),eye(3),-dt*Ck.T],1)
        F3 = concatenate([zeros([3,6]),eye(3)],1)
        F = concatenate([F1,F2,F3],0)

        return (xk1,F)

    def hx(self, x):
        """ transform state into measurement space 

        returns y[k] and dy[k]/dx[k]

        """
        
        h = x[0:6]
        H = concatenate([eye(6),zeros([6,3])],1)

        return (h,H)