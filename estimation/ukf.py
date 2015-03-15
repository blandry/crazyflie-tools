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
Modified on March 2015 by Benoit Landry
Robot Locomotion Laboratory, MIT
****************************************

"""

from numpy.linalg import inv, cholesky
import numpy as np
from numpy import asarray, eye, zeros, dot, isscalar, outer, diag, array
from filterpy.common import dot3


class UnscentedKalmanFilter(object):

    def __init__(self, dim_x, dim_z, plant, kappa=0):

        self.plant = plant
        self.fx = plant.fx
        self.hx = plant.hx

        self._dim_x = dim_x
        self._dim_z = dim_z

        self.x = zeros(dim_x)
        self.P = eye(dim_x)

        self.R = 1.0e-03 * array([
            [0.000003549299086,-0.000002442814972,-0.000004480024840,0.000267707847733,-0.000144518246735,-0.000212282673978],
            [-0.000002442814972,0.000005899512446,0.000006498387107,-0.000138622536892,0.000440883366233,0.000388550687603],
            [-0.000004480024840,0.000006498387107,0.000014749347917,-0.000218834499062,0.000402004146826,0.000932091499876],
            [0.000267707847733,-0.000138622536892,-0.000218834499062,0.042452413803684,-0.022718840083072,-0.034590131072346],
            [-0.000144518246735,0.000440883366233,0.000402004146826,-0.022718840083072,0.071342980281184,0.064549199777213],
            [-0.000212282673978,0.000388550687603,0.000932091499876,-0.034590131072346,0.064549199777213,0.149298685351403],
            ])

        self.Q = 1.0e-09*eye(dim_x) 

        self._num_sigmas = 2*dim_x + 1
        self.kappa = kappa

        # weights for the sigma points
        self.W = self.weights(dim_x, kappa)
        
        # sigma points transformed through f(x) and h(x)
        # variables for efficiency so we don't recreate every update
        self.sigmas_f = zeros((self._num_sigmas, self._dim_x))

    def predict(self, control_input, dt):

        # calculate sigma points for given mean and covariance
        sigmas = self.sigma_points(self.x, self.P, self.kappa)

        for i in range(self._num_sigmas):
            [xk1,F,Q] = self.fx(sigmas[i], control_input, dt)
            self.sigmas_f[i] = xk1.reshape(9)

        self.x, self.P = unscented_transform(self.sigmas_f, self.W, self.W, self.Q)

    def update(self, z, R=None, residual=np.subtract, UT=None):

        if isscalar(z):
            dim_z = 1
        else:
            dim_z = len(z)

        if R is None:
            R = self.R
        elif np.isscalar(R):
            R = eye(self._dim_z) * R

        # rename for readability
        sigmas_f = self.sigmas_f
        sigmas_h = zeros((self._num_sigmas, dim_z))

        if UT is None:
            UT = unscented_transform

        # transform sigma points into measurement space
        for i in range(self._num_sigmas):
            [sigmas_h[i], H] = self.hx(sigmas_f[i])

        # mean and covariance of prediction passed through unscented transform
        zp, Pz = UT(sigmas_h, self.W, self.W, R)

        # compute cross variance of the state and the measurements
        '''self.Pxz = zeros((self._dim_x, dim_z))
        for i in range(self._num_sigmas):
            self.Pxz += self.W[i] * np.outer(sigmas_f[i] - self.x,
                                        residual(sigmas_h[i], zp))'''

        # this is the unreadable but fast implementation of the
        # commented out loop above
        yh = sigmas_f - self.x[np.newaxis, :]
        yz = residual(sigmas_h, zp[np.newaxis, :])
        self.Pxz = yh.T.dot(np.diag(self.W)).dot(yz)

        K = dot(self.Pxz, inv(Pz)) # Kalman gain
        y = residual(z, zp)

        self.x = self.x + dot(K, y)
        self.P = self.P - dot3(K, Pz, K.T)

    @staticmethod
    def weights(n, kappa):
        """ Computes the weights for an unscented Kalman filter. See
        __init__() for meaning of parameters.
        """
        assert n > 0, "n must be greater than 0, it's value is {}".format(n)
        k = .5 / (n+kappa)
        W = np.full(2*n+1, k)
        W[0] = kappa / (n+kappa)
        return W

    @staticmethod
    def sigma_points(x, P, kappa):
        """ Computes the sigma points for an unscented Kalman filter
        given the mean (x) and covariance(P) of the filter.
        kappa is an arbitrary constant. Returns sigma points.

        Works with both scalar and array inputs:
        sigma_points (5, 9, 2) # mean 5, covariance 9
        sigma_points ([5, 2], 9*eye(2), 2) # means 5 and 2, covariance 9I

        **Parameters**

        X An array-like object of the means of length n
            Can be a scalar if 1D.
            examples: 1, [1,2], np.array([1,2])

        P : scalar, or np.array
           Covariance of the filter. If scalar, is treated as eye(n)*P.

        kappa : float
            Scaling factor.

        **Returns**

        sigmas : np.array, of size (n, 2n+1)
            2D array of sigma points. Each column contains all of
            the sigmas for one dimension in the problem space. They
            are ordered as:

            .. math::
                sigmas[0]    = x \n
                sigmas[1..n] = x + [\sqrt{(n+\kappa)P}]_k \n
                sigmas[n+1..2n] = x - [\sqrt{(n+\kappa)P}]_k
        """

        if np.isscalar(x):
            x = asarray([x])
        n = np.size(x)  # dimension of problem

        if np.isscalar(P):
            P = eye(n)*P

        sigmas = zeros((2*n+1, n))

        # implements U'*U = (n+kappa)*P. Returns lower triangular matrix.
        # Take transpose so we can access with U[i]
        U = cholesky((n+kappa)*P).T
        #U = sqrtm((n+kappa)*P).T

        sigmas[0] = x
        sigmas[1:n+1]     = x + U
        sigmas[n+1:2*n+2] = x - U

        return sigmas

def unscented_transform(Sigmas, Wm, Wc, noise_cov):
    """ Computes unscented transform of a set of sigma points and weights.
    returns the mean and covariance in a tuple.
    """

    kmax, n = Sigmas.shape

    # new mean is just the sum of the sigmas * weight
    x = dot(Wm, Sigmas)    # dot = \Sigma^n_1 (W[k]*Xi[k])

    # new covariance is the sum of the outer product of the residuals
    # times the weights
    '''P = zeros((n, n))
    for k in range(kmax):
        y = Sigmas[k] - x
        P += Wc[k] * np.outer(y, y)'''

    # this is the fast way to do the commented out code above
    y = Sigmas - x[np.newaxis,:]
    P = y.T.dot(np.diag(Wc)).dot(y)

    if noise_cov is not None:
        P += noise_cov

    return (x, P)