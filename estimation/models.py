
import numpy as np
from transforms import body2world, angularvel2rpydot

class Crazyflie2Model():

    def __init__(self):
    
        self.Ixx = 2.15e-006
        self.Iyy = 2.15e-006
        self.Izz = 4.29e-006
        self.Ixy = 2.37e-007 

        self.Kf = 0.004522393588278
        self.Km = 1.400164274777642e-06

        self.u_min = [2.8, 2.8, 2.8, 2.8]
        self.u_max = [40.87, 40.87, 40.87, 40.87]

        self.L = 0.046
        self.I = np.array([[self.Ixx, self.Ixy, 0.0     ],
                           [self.Ixy, self.Iyy, 0.0     ],
                           [0.0,      0.0,      self.Izz]])
        self.invI = np.linalg.inv(self.I)

    def hx(self, x):
        """ transform state into measurement space """
        return x

    def fx(self, x, u, dt):
        """ computes the next x[k+1] from x[k], u[k] and dt """

        [x,y,z,dx,dy,dz] = x
        [r,p,y,ax,ay,az] = u
        
        new_x = x + dx*dt
        new_y = y + dy*dt
        new_z = z + dz*dt

        [axw,ayw,azw] = body2world([r,p,y],[ax,ay,az])
        new_dx = dx + axw*dt
        new_dy = dy + ayw*dt
        new_dz = dz + azw*dt

        return np.array([new_x, new_y, new_z, new_dx, new_dy, new_dz])

        # [x,y,z,r,p,y,dx,dy,dz,gx,gy,gz] = x
        # [w1,w2,w3,w4,ax,ay,az] = u

        # w1 = min(max(self.u_min[0],w1),self.u_max[0])
        # w2 = min(max(self.u_min[1],w1),self.u_max[1])
        # w3 = min(max(self.u_min[2],w1),self.u_max[2])
        # w4 = min(max(self.u_min[3],w1),self.u_max[3])

        # new_x = x + dx*dt
        # new_y = y + dy*dt
        # new_z = z + dz*dt

        # [dr,dp,dy] = angularvel2rpydot([r,p,y],body2world([r,p,y],[gx,gy,gz]))
        # new_r = r + dr*dt 
        # new_p = p + dp*dt
        # new_y = y + dy*dt

        # # using the accelerometer data, not the dynamics for dx, dy and dz
        # [axw,ayw,azw] = body2world([r,p,y],[ax,ay,az])
        # new_dx = dx + axw*dt
        # new_dy = dy + ayw*dt
        # new_dz = dz + azw*dt

        # F1 = self.Kf*w1;
        # F2 = self.Kf*w2;
        # F3 = self.Kf*w3;
        # F4 = self.Kf*w4;
        # M1 = self.Km*w1
        # M2 = self.Km*w2
        # M3 = self.Km*w3
        # M4 = self.Km*w4
        # [dgx,dgy,dgz] = np.dot(self.invI,(np.array([self.L*(F4-F2),self.L*(F3-F1),(M2+M4-M1-M3)])-np.cross([gx,gy,gz],np.dot(self.I,[gx,gy,gz]))))
        # new_gx = gx #+ dgx*dt
        # new_gy = gy #+ dgy*dt
        # new_gz = gz #+ dgz*dt

        # return np.array([new_x, new_y, new_z, new_r, new_p, new_y, new_dx, new_dy, new_dz, new_dz, new_gy, new_gz])