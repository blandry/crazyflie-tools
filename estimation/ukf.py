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
from numpy import asarray, eye, zeros, dot, isscalar, outer, diag
from filterpy.common import dot3


class UnscentedKalmanFilter(object):

    def __init__(self, dim_x, dim_z, plant, kappa=0):

        self.plant = plant
        self.fx = plant.fx
        self.hx = plant.hx

        self.Q = eye(dim_x)
        self.R = diag([10, 10, 10, 100, 100, 100])
        self.x = zeros(dim_x)
        self.P = eye(dim_x)
        self._dim_x = dim_x
        self._dim_z = dim_z
        self._num_sigmas = 2*dim_x + 1
        self.kappa = kappa

        # weights for the sigma points
        self.W = self.weights(dim_x, kappa)
        
        # sigma points transformed through f(x) and h(x)
        # variables for efficiency so we don't recreate every update
        self.sigmas_f = zeros((self._num_sigmas, self._dim_x))


    def predict(self, control_input, dt):
        """ Performs the predict step of the UKF. On return, self.xp and
        self.Pp contain the predicted state (xp) and covariance (Pp). 'p'
        stands for prediction.

        **Parameters**

        input : np.array
                The input sent to the plant for dt

        dt : double
            The time step to be used for this prediction.

        Important: this MUST be called before update() is called for the
        first time.
        """

        # calculate sigma points for given mean and covariance
        sigmas = self.sigma_points(self.x, self.P, self.kappa)

        for i in range(self._num_sigmas):
            self.sigmas_f[i] = self.fx(sigmas[i], control_input, dt)

        self.x, self.P = unscented_transform(self.sigmas_f, self.W, self.W, self.Q)


    def update(self, z, R=None, residual=np.subtract, UT=None):
        """ Update the UKF with the given measurements. On return,
        self.x and self.P contain the new mean and covariance of the filter.

        **Parameters**

        z : numpy.array of shape (dim_z)
            measurement vector

        R : numpy.array((dim_z, dim_z)), optional
            Measurement noise. If provided, overrides self.R for
            this function call.

        residual : function (z, z2), optional
            Optional function that computes the residual (difference) between
            the two measurement vectors. If you do not provide this, then the
            built in minus operator will be used. You will normally want to use
            the built in unless your residual computation is nonlinear (for
            example, if they are angles)

        UT : function(sigmas, Wm, Wc, noise_cov), optional
            Optional function to compute the unscented transform for the sigma
            points passed through hx. Typically the default function will
            work, but if for example you are using angles the default method
            of computing means and residuals will not work, and you will have
            to define how to compute it.
        """

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
            sigmas_h[i] = self.hx(sigmas_f[i])

        # mean and covariance of prediction passed through inscented transform
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