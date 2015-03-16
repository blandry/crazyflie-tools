
from numpy import dot, array, concatenate, eye, zeros
import numpy as np
from transforms import body2world, angularvel2rpydot, rpy2rotmat

class DoubleIntegrator():

    # states: x y z dx dy dz accxbias accybias acczbias
    # inputs: roll pitch yaw accx accy accz
    # measurements: x y z dx dy dz

    def __init__(self):
        # noise covariance of the accelerometer
        self.Qf = 1.0e-05*array([
            [0.091517244935232,0.056603535693738,0.007133936098991],
            [0.056603535693738,0.221460824578487,0.079347515535003],
            [0.007133936098991,0.079347515535003,0.296561306839593],
            ])
        # noise covariance of the accelerometer bias
        self.Qbf = zeros([3,3])

    def fx(self, state, control_input, dt):
        """ computes the next x[k+1] from x[k], u[k], dt 

        returns x[k+1], dx[k+1]/dx[k] and the process covariance

        """
        
        g = array([0,0,-9.81]).reshape(3,1)

        rk = state[0:3].reshape(3,1)
        vk = state[3:6].reshape(3,1)
        bfk = state[6:9].reshape(3,1)

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

        Qf = self.Qf
        Qbf = self.Qbf
        Q1 = concatenate([(dt**3/3)*Qf+(dt**5/20)*Qbf,(dt**2/2)*Qf+(dt**4/8)*Qbf,-(dt**3/6)*dot(Ck.T,Qbf)],1)
        Q2 = concatenate([(dt**2/2)*Qf+(dt**4/8)*Qbf,dt*Qf+(dt**3/3)*Qbf,-(dt**2/2)*dot(Ck.T,Qbf)],1)
        Q3 = concatenate([(dt**3/6)*dot(Qbf,Ck),-(dt**2/2)*dot(Qbf,Ck),dt*Qbf],1)
        Q = concatenate([Q1,Q2,Q3],0)

        return (xk1,F,Q)

    def hx(self, x):
        """ transform state into measurement space 

        returns y[k] and dy[k]/dx[k]

        """
        
        h = x[0:6]
        H = concatenate([eye(6),zeros([6,3])],1)

        return (h,H)