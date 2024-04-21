from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd
import numpy as np

class CorrelationFriends(Strategy):
    # creates indicator boundries for long and short position
    safe_area_width = 0.008
    profit_take = .02
    loss_take = .02
    level_multi = 10
    def create_indicator(self, area_increase):
        ret = []
        for i in range(1, len(self.main_crypto_currency)):
            temp_friends_progress = 0
            for j in range(0, len(self.arr_of_correlation_friends)):
                temp_friends_progress += (self.arr_of_correlation_friends[j][i] / self.arr_of_correlation_friends[j][i-1])
            temp_friends_progress = temp_friends_progress / len(self.arr_of_correlation_friends)
            ret.append(temp_friends_progress * (area_increase) * self.main_crypto_currency[i-1])
        ret = [self.data.Close[0]]  + ret
        return np.array(ret)
    def initiate_variables(self):
        i = 0
        friends = []
        try:
            while self.data['friend_{}'.format(i)]:
                friends.append(self.data['friend_{}'.format(i)])
                i += 1
        except:
            self.arr_of_correlation_friends = friends
            self.main_crypto_currency = self.data['Close']
           
    def init(self):
            self.initiate_variables()
            self.upper_bound = self.I(self.create_indicator, 1 + self.safe_area_width)
            self.bottom_bound = self.I(self.create_indicator, 1 - self.safe_area_width)
            # print('Using safe area width: {} with take_profit: {} and stop_lost: {}'.format(self.safe_area_width, self.profit_take, self.loss_take))
            # print(self.safe_area_width)
        


    def next(self):
         current_price = self.data.Close[-1]
         if self.upper_bound == -1 or self.bottom_bound == -1:
            return
         if current_price > self.upper_bound[-1]:
                over_level =  self.upper_bound[-1] / current_price 
                self.sell(size= (1 - over_level) * self.level_multi, tp=(1 - self.profit_take) * current_price, sl=(1 + self.loss_take) * current_price)
         if current_price < self.bottom_bound[-1]:
                under_level = current_price / self.bottom_bound[-1] 
                self.buy(size= (1 - under_level) * self.level_multi, tp=(1 + self.profit_take) * current_price, sl=(1 - self.loss_take) * current_price)
       

       
