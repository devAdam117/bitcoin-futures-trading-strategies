from collections import deque
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd
import numpy as np
from scipy.special import expit
from backtesting.test import SMA
from collections import deque

class UnoUno(Strategy):
    

    # tics_for_prob = 19
    # min_prob =  0.2502759987887752
    # max_position_size = 12
    # take_profit = 0.04280966248893105 
    # stop_loss = 0.048823497652287905 
    # level_multi = 10 
    # sma_n = 55  
    # threshold = 0.02044002889125441

    # tics_for_prob = 63
    # min_prob = 0.4815920660822193
    # take_profit = 0.19893576418402854 
    # stop_loss = 0.013127814922768793
    # tics_for_volatility = 134
    # volatility_max = 0.01551364732325691
    # level_multi = 10

    tics_for_prob= 17
    min_prob= 0.34583148171747613
    max_position_size= 15
    take_profit= 0.048230000198955014
    stop_loss= 0.047266730871922506
    level_multi= 10
    sma_n= 9
    threshold= 0.017135494597135464

    up_up = []
    up_down = []
    down_up = []
    down_down = []
    zero_zero = []
    volatility = []
    diff_mean = []

    def create_indicator(self):
        close_prices = self.data['Close']
        price_changes = np.sign(np.diff(close_prices))
        
        up_up = []
        up_down = []
        down_up = []
        down_down = []
        zero_zero = []
        relative_trend_diff = []


        for i in range(self.tics_for_prob, len(close_prices)):
            recent_ticks = price_changes[i-self.tics_for_prob:i]
            count_up_up = sum([1 for j in range(len(recent_ticks)-1) if recent_ticks[j] == 1 and recent_ticks[j+1] == 1])
            count_up_down = sum([1 for j in range(len(recent_ticks)-1) if recent_ticks[j] == 1 and recent_ticks[j+1] == -1])
            count_down_up = sum([1 for j in range(len(recent_ticks)-1) if recent_ticks[j] == -1 and recent_ticks[j+1] == 1])
            count_down_down = sum([1 for j in range(len(recent_ticks)-1) if recent_ticks[j] == -1 and recent_ticks[j+1] == -1])
            count_zero_zero = sum([1 for j in range(len(recent_ticks)-1) if recent_ticks[j] == 0 or recent_ticks[j+1] == 0])
            
            total_ticks = len(recent_ticks) - 1
            up_up_prob = count_up_up / total_ticks
            up_down_prob = count_up_down / total_ticks
            down_up_prob = count_down_up / total_ticks
            down_down_prob = count_down_down / total_ticks
            zero_zero_prob = count_zero_zero / total_ticks
            up_up.append(up_up_prob)
            up_down.append(up_down_prob)
            down_up.append(down_up_prob)
            down_down.append(down_down_prob)
            zero_zero.append(zero_zero_prob)

            sma_n = np.mean(close_prices[i-self.sma_n:i])
            # Calculate relative trend difference
            relative_diff = sma_n
            relative_trend_diff.append(relative_diff)
           
        
        # prepend ntics - 1 zeros to the beginning of the list
        self.diff_mean = [0] * self.tics_for_prob + relative_trend_diff
        self.up_up = [0] * (self.tics_for_prob) + up_up
        self.up_down = [0] * (self.tics_for_prob) + up_down
        self.down_up = [0] * (self.tics_for_prob ) + down_up
        self.down_down = [0] * (self.tics_for_prob ) + down_down
        self.zero_zero = [0] * (self.tics_for_prob ) + zero_zero

        
    def get_indicator(self, name):
        if name == 'up_up':
            return self.up_up
        elif name == 'up_down':
            return self.up_down
        elif name == 'down_up':
            return self.down_up
        elif name == 'down_down':
            return self.down_down
        elif name == 'zero_zero':
            return self.zero_zero
        elif name == 'diff_mean':
            return self.diff_mean

    def init(self):
        print(f"Init params are: tics_for_prob: {self.tics_for_prob} and min_prob: {self.min_prob}, max_position_size: {self.max_position_size} and take_profit: {self.take_profit} and stop_loss: {self.stop_loss} and level_multi: {self.level_multi} and sma_n: {self.sma_n} and threshold: {self.threshold}")
        self.create_indicator()
        self.up_up_indicator = self.I(self.get_indicator, 'up_up')
        self.up_down_indicator = self.I(self.get_indicator, 'up_down')
        self.down_up_indicator = self.I(self.get_indicator, 'down_up')
        self.down_down_indicator = self.I(self.get_indicator, 'down_down')
        self.zero_zero = self.I(self.get_indicator, 'zero_zero')
        self.diff_mean = self.I(self.get_indicator, 'diff_mean')

    def next(self):
        current_price = self.data.Close[-1]
        prev_price = self.data.Close[-2]
        sma_current = self.diff_mean[-1]
        movement = np.sign(current_price - prev_price)

        if self.position.is_long or self.position.is_short:
            return
        
        
        
        
        if self.up_up_indicator[-1] == 0 or self.up_down_indicator[-1] == 0 or self.down_up_indicator[-1] == 0 or self.down_down_indicator[-1] == 0 :
            return

      
        
        if movement == 1 and self.up_up_indicator[-1] > self.min_prob and self.up_up_indicator[-1] > self.up_down_indicator[-1] and sma_current > current_price * (1 + self.threshold):
            size_to_action = round((self.up_up_indicator[-1] / self.min_prob) * self.level_multi)
            self.buy(tp=(1 + self.take_profit) * current_price, sl=(1 - self.stop_loss) * current_price, size=size_to_action)
        elif movement == 1 and self.up_down_indicator[-1] > self.min_prob and self.up_down_indicator[-1] > self.up_up_indicator[-1] and sma_current < current_price * (1 - self.threshold):
            size_to_action = round((self.up_down_indicator[-1] / self.min_prob) * self.level_multi)
            self.sell(tp=(1 - self.take_profit) * current_price, sl=(1 + self.stop_loss) * current_price, size=size_to_action)

        elif movement == -1 and self.down_down_indicator[-1] > self.min_prob and self.down_down_indicator[-1] > self.down_up_indicator[-1] and sma_current > current_price * (1 + self.threshold):
            size_to_action = round((self.down_down_indicator[-1] / self.min_prob) * self.level_multi)
            self.sell(tp=(1 - self.take_profit) * current_price, sl=(1 + self.stop_loss) * current_price, size=size_to_action)
        elif movement == -1 and self.down_up_indicator[-1] > self.min_prob and self.down_up_indicator[-1] > self.down_down_indicator[-1] and sma_current < current_price * (1 - self.threshold):
            size_to_action = round((self.down_up_indicator[-1] / self.min_prob) * self.level_multi)
            self.buy(tp=(1 + self.take_profit) * current_price, sl=(1 - self.stop_loss) * current_price, size=size_to_action)
