from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd
import numpy as np
from scipy.special import expit


class TrendFollower(Strategy):
    tics_for_lin_reg = 12
    tics_for_variance = 98
    variance_percentile_num = 11
    take_profit = 0.049582
    stop_loss = 0.043477
    pos_min_slope = 0.509725   
    pos_max_slope = 0.771271
    level_multi = 7
    variance_pecentil = None

    # only to view variance and lin_reg_slope on the same plot near the close price
    relative_ui_width = 1.01
    
    def create_indicator(self, type):
        max_num = max(self.tics_for_variance, self.tics_for_lin_reg)
        lin_reg_coefs = [-1] * max_num
        variances = [-1] * max_num
        close_prices = self.data['Close']
        for i in range(1, len(close_prices)):
            if i >= max(self.tics_for_lin_reg, self.tics_for_variance):
                close_window = close_prices[i - self.tics_for_lin_reg:i]
                x = np.arange(len(close_window))
                lin_reg_coefs.append(np.polyfit(x, close_window, 1)[0])
                price_diff = np.diff(close_window)
                pct_change = price_diff / close_window[:-1]
                log_returns = np.log(1 + pct_change)
                variance = np.var(log_returns)
                variances.append(variance)
        self.variance_pecentil = np.percentile(variances, self.variance_percentile_num)
        if type == 'lin_reg_slope':
            # return as numpy array
            ret =  (expit(np.array(lin_reg_coefs)) + self.data.Close) * self.relative_ui_width
            return ret
        
        elif type == 'variance':
            # return as numpy array
            return (np.array(variances) + self.data.Close) * self.relative_ui_width
    
   

    def init(self):
        self.reg_suggestion = self.I(self.create_indicator, 'lin_reg_slope')
        self.variance = self.I(self.create_indicator, 'variance')
        print(f'Trying new one strategy with new params: tics_for_lin_reg: {self.tics_for_lin_reg}, tics_for_variance: {self.tics_for_variance}, level_multi: {self.level_multi}, variance_percentile_num: {self.variance_percentile_num}, take_profit: {self.take_profit}, stop_loss: {self.stop_loss}, pos_min_slope: {self.pos_min_slope}, pos_max_slope: {self.pos_max_slope}')


    def next(self):
        current_price = self.data.Close[-1]
        if self.reg_suggestion[-1] == -1 or self.variance[-1] == -1:
            return
        
        normalized_reg_suggestion = self.reg_suggestion[-1] / self.relative_ui_width  - current_price
        normalized_variance = self.variance[-1] / self.relative_ui_width  - current_price
        if normalized_variance >= np.percentile(self.variance, 0.75):
            self.position.close()
            print(f'Normalized reg suggestion: {normalized_reg_suggestion}, normalized variance: {normalized_variance}')
        # skus crossover, skus potom variance high check, ak je velka tak zrus vsetko.
        
        if normalized_reg_suggestion > self.pos_min_slope and normalized_reg_suggestion < self.pos_max_slope and normalized_variance < self.variance_pecentil:
            # buy more the variance is lower than the percentile
            # check for non infinity and non nan
            if not np.isfinite(self.variance_pecentil / normalized_variance):

                return
            self.buy(size=round(( self.variance_pecentil / normalized_variance ) * self.level_multi),  tp=(self.take_profit + 1) * current_price, sl= (1 - self.stop_loss) * current_price)


        if normalized_reg_suggestion < -self.pos_min_slope and normalized_reg_suggestion > -self.pos_max_slope and normalized_variance < self.variance_pecentil:
            if not np.isfinite(self.variance_pecentil / normalized_variance):
                return
            self.sell(size=round((self.variance_pecentil / normalized_variance) * self.level_multi), tp=(1 - self.take_profit) * current_price, sl= (1 + self.stop_loss) * current_price)
