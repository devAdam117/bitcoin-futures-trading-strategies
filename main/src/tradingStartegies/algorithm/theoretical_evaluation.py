from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd
import numpy as np

class TheoreticalEvaluation(Strategy):
    def create_indicator(self, area_increase):
        pass
        
    
           
    def init(self):
            pass
        


    def next(self):
         pass


       
        
           

    



import numpy as np

def getMLEVasicek(r, dt=1/12):
    n = len(r) - 1
    alpha_hat = (n*np.sum(r[1:] * r[:n]) - np.sum(r[1:]) * np.sum(r[:n])) / (n*np.sum(r[:n]**2) - np.sum(r[:n])**2)
    beta_hat = np.sum(r[1:] - alpha_hat * r[:n]) / (n*(1 - alpha_hat))
    v2_hat = 1/n * np.sum((r[1:] - alpha_hat * r[:n] - beta_hat*(1 - alpha_hat))**2)
    kappa_hat = -np.log(alpha_hat) / dt
    theta_hat = beta_hat
    sigma_hat = (v2_hat * 2 * kappa_hat) / (1 - np.exp(-2 * kappa_hat * dt))
    
    alphaVasicek = kappa_hat
    thetaVasicek = (kappa_hat * theta_hat + sigma_hat * 1) / kappa_hat
    sigmaVasicek = sigma_hat
    
    return {'alpha': alphaVasicek, 'theta': thetaVasicek, 'sigma': sigmaVasicek}

def compute_sigma_t(mleVasicek, T, t):
    sigma_t = np.sqrt(mleVasicek['sigma']**2 * (T - t) - 2 * mleVasicek['sigma']**2 * (1 - np.exp(-(T - t))) + mleVasicek['sigma']**2 * (1 - np.exp(-2*(T - t))))
    return sigma_t

def compute_P_t(mleVasicek, r_t, T, t):
    sigma_t = compute_sigma_t(mleVasicek, T, t)
    P_t = np.exp(
        -((mleVasicek['theta'] / mleVasicek['alpha']) * (T - t) +
          1 / mleVasicek['alpha'] * (r_t - mleVasicek['theta'] / mleVasicek['alpha']) * (1 - np.exp(-mleVasicek['alpha'] * (T - t))) -
          1 / 2 * sigma_t**2)
    )
    return P_t

# Example usage:
r = np.array([0.05, 0.04, 0.03, 0.035, 0.04, 0.045])
mleVasicek = getMLEVasicek(r)
T = 1
t = 0.5
r_t = 0.035
sigma_t = compute_sigma_t(mleVasicek, T, t)
P_t = compute_P_t(mleVasicek, r_t, T, t)
print("Sigma_t:", sigma_t)
print("P_t:", P_t)
