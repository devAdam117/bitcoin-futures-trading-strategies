from backtesting.test import SMA
from backtesting import Strategy
import pandas as pd
from backtesting.lib import crossover

def std_3(arr, n):
    return pd.Series(arr).rolling(n).std() * 3




def rolling_prob_quantity(arr, n):
    arr = pd.Series(arr).diff().apply(lambda x: 1 if x > 0 else -1)
    ret = pd.Series(arr).rolling(n).apply(lambda x: x.mean())
    return ret

def std(arr, n):
    return pd.Series(arr).rolling(n).std()

# TODO maybe remove the tp an sl due to pontentional cut profit, but it is used a lot in mean reverison startegies
class RevertIt(Strategy):
    # roll = 962
    # prob_roll = 26
    # critical_prob = 0.34374503792859223
    # tp = 0.06
    # sl = 0.04
    # min_std = 1000
    # Monte Carlo fitted
    # roll = 475
    # prob_roll = 127
    # critical_prob = 0.4635363047260549
    # min_std = 1211

    roll = 402
    prob_roll = 273
    critical_prob = 0.29001548005003697
    min_std = 242    


    def init(self):
        self.he = self.data['Close']
        self.he_mean = self.I(SMA, self.he, self.roll)
        self.rolling_prob_quantity = self.I(rolling_prob_quantity, self.he, self.prob_roll)
        self.std = self.I(std, self.he, self.roll)
        print(f"Init with self params: roll: {self.roll}, prob_roll: {self.prob_roll}, critical_prob: {self.critical_prob}, min_std: {self.min_std}")

    def next(self):
        current_price = self.data['Close'][-1]
        current_mean = self.he_mean[-1]
        current_prob = self.rolling_prob_quantity[-1]
        if abs(current_prob) > self.critical_prob:
            return 
        if self.std[-1] < self.min_std:
            return
        if crossover(self.data['Close'], self.he_mean) or crossover(self.he_mean, self.data['Close']): 
            if current_price > current_mean and current_prob < 0 :
                self.sell(
                        size=1,
                    )
                

            if current_price < current_mean and current_prob > 0 :
                self.buy(
                    size=1,
                )