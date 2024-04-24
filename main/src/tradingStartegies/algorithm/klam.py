from backtesting.test import SMA
from backtesting import Strategy
import pandas as pd
from backtesting.lib import crossover
from datetime import datetime
from dateutil import relativedelta

# Knowledge-Enhanced Algorithmic Leverage Management (KLAM) strategy
class Klam(Strategy):
    tp = 0.014271645747978047
    sl = 0.06677678180692997
    min_base_diff = 52
    optimal_size = 0.3765542123135671


    def init(self):
        self.theoretical_futures = self.I(theoretical_futures_price, self.data)
        self.real_futures = self.data['Close']
        print(f'Intitialized with tp: {self.tp}, sl: {self.sl}, min_base_diff: {self.min_base_diff}, optimal_size: {self.optimal_size}')

    def next(self):
        current_real_price = self.data['Close'][-1]
        current_theoretical_price = self.theoretical_futures[-1]
        
        base_diff = current_theoretical_price - current_real_price
        if abs(base_diff) < self.min_base_diff:
            return
        dev =  current_real_price / (abs(base_diff) + 1)
        portion = np.round(dev * self.optimal_size)
        if base_diff > 0:
            print(f" Current real price: {current_real_price}, current theoretical price: {current_theoretical_price}, base_diff: {base_diff}")
            if self.position.is_short:
                self.position.close()
            self.buy(size= portion, sl = current_real_price * (1 - self.sl), tp = current_real_price * (1 + self.tp))

        if base_diff < 0:
            if self.position.is_long:
                self.position.close()
            self.sell(size = portion, sl = current_real_price * (1 + self.sl), tp = current_real_price * (1 - self.tp))
       
        




import numpy as np



def theoretical_futures_price(data):
    return data['theoretical_futures']



