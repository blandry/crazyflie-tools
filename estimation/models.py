
from numpy import dot, array, concatenate, eye, zeros, ones, cross
import numpy as np
from transforms import body2world, angularvel2rpydot, rpy2rotmat

class DoubleIntegrator():

    # states: x y z dx dy dz accxbias accybias acczbias
    # inputs: roll pitch yaw accx accy accz
    # measurements: x y z

    def __init__(self):
        # noise covariance of the accelerometer
        self.Qf = 1.0e-05*array([
            [0.091517244935232,0.056603535693738,0.007133936098991],
            [0.056603535693738,0.221460824578487,0.079347515535003],
            [0.007133936098991,0.079347515535003,0.296561306839593],
            ])
        # noise covariance of the accelerometer bias
        self.Qbf = array([
            [.1, .05, .05],
            [.05, .1, .05],
            [.05, .05, .5],
            ])

    def fx(self, state, control_input, dt):
        """ computes the next x[k+1] from x[k], u[k], dt 

        returns x[k+1], dx[k+1]/dx[k] and the process covariance

        """
        
        g = array([0,0,-9.81]).reshape(3,1)

        rk = state[0:3].reshape(3,1)
        vk = state[3:6].reshape(3,1)
        bfk = state[6:9].reshape(3,1)

        Ck = rpy2rotmat(control_input[0:3]).T
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
        
        h = x[0:3]
        H = concatenate([eye(3),zeros([3,6])],1)

        return (h,H)


class Crazyflie2():

    def __init__(self):
        self.Ixx = 1.434265000000000e-04
        self.Iyy = 1.434265000000000e-04
        self.Izz = 1.140711000000000e-04
        self.Ixy = 0

        self.Kf = 0.005022393588278
        self.Km = 6.492561742143926e-05

        self.u_min = [0.0, 0.0, 0.0, 0.0]
        self.u_max = [40.87, 40.87, 40.87, 40.87]

        self.m = 0.03337
        self.L = 0.046
        self.I = np.array([[self.Ixx, self.Ixy, 0.0 ],
                           [self.Ixy, self.Iyy, 0.0 ],
                           [0.0, 0.0, self.Izz]])
        self.invI = np.linalg.inv(self.I)

    def dynamics(self, state, control_input):
        """ returns xdot """

        [x,y,z,roll,pitch,yaw,dx,dy,dz,omegax,omegay,omegaz] = state
        [w1,w2,w3,w4] = control_input

        w1 = min(max(self.u_min[0],w1),self.u_max[0])
        w2 = min(max(self.u_min[1],w2),self.u_max[1])
        w3 = min(max(self.u_min[2],w3),self.u_max[2])
        w4 = min(max(self.u_min[3],w4),self.u_max[3])

        F1 = self.Kf*w1
        F2 = self.Kf*w2
        F3 = self.Kf*w3
        F4 = self.Kf*w4
        M1 = self.Km*w1
        M2 = self.Km*w2
        M3 = self.Km*w3
        M4 = self.Km*w4

        [ddx,ddy,ddz] = (1/self.m)*(array([0,0,-self.m*9.81]) + array(body2world([roll,pitch,yaw],[0,0,F1+F2+F3+F4])))
        [alphax,alphay,alphaz] = dot(self.invI,(array([self.L*(F4-F2),self.L*(F3-F1),(M2+M4-M1-M3)])-cross([omegax,omegay,omegaz],dot(self.I,[omegax,omegay,omegaz]))))

        [droll,dpitch,dyaw] = angularvel2rpydot([roll,pitch,yaw],[omegax,omegay,omegaz])

        return [dx,dy,dz,droll,dpitch,dyaw,ddx,ddy,ddz,alphax,alphay,alphaz]

    def simulate(self, x0, u0, tspan):
        """ simulates the input u0 as a zero-order hold starting at x0 """

        dt = 0.005 # time-step size in seconds
        nstep = int(tspan/dt)
        x = array(x0)
        for n in range(nstep):
            x += dt*array(self.dynamics(x,u0))

        return x.tolist()