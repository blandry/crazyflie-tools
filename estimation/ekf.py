# -*- coding: utf-8 -*-

"""Copyright 2014 Roger R Labbe Jr.

filterpy library.
http://github.com/rlabbe/filterpy

Documentation at:
https://filterpy.readthedocs.org

Supporting book at:
https://github.com/rlabbe/Kalman-and-Bayesian-Filters-in-Python

This is licensed under an MIT license. See the readme.MD file
for more information.

****************************************
Modified on March 2015 by Benoit Landry, Robot Locomotion Laboratory, MIT
using [State Estimation for Legged Robots, Bloesch 2012]
****************************************

"""

import numpy as np
import scipy.linalg as linalg
from numpy import dot, zeros, eye, array
from filterpy.common import setter, setter_1d, setter_scalar, dot3


class ExtendedKalmanFilter(object):

    def __init__(self, dim_x, dim_z, plant):
        
        self.plant = plant
        self.fx = plant.fx
        self.hx = plant.hx

        self.dim_x = dim_x
        self.dim_z = dim_z

        self._x = zeros((dim_x,1))
        self._P = eye(dim_x) 

        # measurement covariance
        self._R = 1.0e-03 * array([
            [0.000003549299086,-0.000002442814972,-0.000004480024840,0.000267707847733,-0.000144518246735,-0.000212282673978],
            [-0.000002442814972,0.000005899512446,0.000006498387107,-0.000138622536892,0.000440883366233,0.000388550687603],
            [-0.000004480024840,0.000006498387107,0.000014749347917,-0.000218834499062,0.000402004146826,0.000932091499876],
            [0.000267707847733,-0.000138622536892,-0.000218834499062,0.042452413803684,-0.022718840083072,-0.034590131072346],
            [-0.000144518246735,0.000440883366233,0.000402004146826,-0.022718840083072,0.071342980281184,0.064549199777213],
            [-0.000212282673978,0.000388550687603,0.000932091499876,-0.034590131072346,0.064549199777213,0.149298685351403],
            ])

        self._y = zeros((dim_z, 1))

        # identity matrix. Do not alter this.
        self._I = np.eye(dim_x)

    def predict(self, control_input, dt):
        """ Predict next position. """

        [self._x, F, Q] = self.fx(self._x, control_input, dt)
        self._P = dot3(F, self._P, F.T) + Q

    def update(self, z, R=None):
        """ Performs the update innovation of the extended Kalman filter. """

        P = self._P
        if R is None:
            R = self._R
        elif np.isscalar(R):
            R = eye(self.dim_z) * R

        if np.isscalar(z) and self.dim_z == 1:
            z = np.asarray([z], float)

        x = self._x

        [h,H] = self.hx(x)

        S = dot3(H, P, H.T) + R
        K = dot3(P, H.T, linalg.inv(S))

        y = z.reshape(self.dim_z,1) - h
        self._x = x + dot(K, y)

        I_KH = self._I - dot(K, H)
        self._P = dot3(I_KH, P, I_KH.T) + dot3(K, R, K.T)

    @property
    def P(self):
        """ covariance matrix"""
        return self._P

    @P.setter
    def P(self, value):
        self._P = setter_scalar(value, self.dim_x)

    @property
    def R(self):
        """ measurement uncertainty"""
        return self._R

    @R.setter
    def R(self, value):
        self._R = setter_scalar(value, self.dim_z)

    @property
    def x(self):
        return self._x

    @x.setter
    def x(self, value):
        self._x = setter_1d(value, self.dim_x)

    @property
    def K(self):
        """ Kalman gain """
        return self._K

    @property
    def y(self):
        """ measurement residual (innovation) """
        return self._y

    @property
    def S(self):
        """ system uncertainty in measurement space """
        return self._S
