from backtesting.test import SMA
from backtesting import Strategy
import pandas as pd
from backtesting.lib import crossover
from datetime import datetime
from dateutil import relativedelta

class ArbiCheck(Strategy):
    short_rate = 0.0393
    fees = 0.002

    # used internally
    count = 0
    last_date_time = None
    eps = 0


    debt = 0

    lent = 0

    def init(self):
        self.spot_price = self.I(create_sport_price, self.data)
        self.debt_cumulative = self.I(debt_cumulative, self.data, short_rate=self.short_rate, fees=self.fees)
        self.lent_cumulative = self.I(lent_cumulative, self.data, short_rate=self.short_rate, fees=self.fees)
        self.last_date_time = self.data.index[-1]
        self.diff = self.data['Close'] - self.spot_price
        self.diff_mean = self.I(diff, self.data)
        self.initial_equity = self.equity

    def year_difference(self, dt1, dt2):
        delta = relativedelta.relativedelta(dt2, dt1)
        return delta.years + delta.months / 12 + delta.days / 365 + delta.hours / (365*24) + delta.minutes / (365*24*60)
    
    



    def next(self):
        if self.last_date_time == self.data.index[-1]:
            print("We reached the maturity of futures contract all setlemenets will be handled ....")
            print("But we care only about the lent - debt difference")
            print(f"Lent: {self.lent}, Debt: {self.debt}, total profit: {self.lent - self.debt}, yield: {(self.lent - self.debt) / self.initial_equity}, number of trades: {self.count}")
         
        current_contract_price = self.data['Close'][-1]
        current_spot_price = self.spot_price[-1]
        if current_contract_price < current_spot_price:
            return
        debt_interval = self.year_difference(self.data.index[-1], self.last_date_time)
        short_rate_for_interval = self.short_rate * debt_interval
        all_fees = (current_spot_price * (short_rate_for_interval + self.fees) + current_contract_price * self.fees + self.eps)
        if current_contract_price - current_spot_price <= all_fees:
            return
        
        self.count += 1
       
        self.debt += current_spot_price * (1 + short_rate_for_interval)
        self.lent += current_contract_price * (1 - 2 * self.fees)
        # This is only for graphical purposes to see how many times we have traded ( the size is not relevant here), even though not all trades are displayed ... we cache them by ourselves
        self.sell(
            size=1,
        )
        
           

def create_sport_price(data):
    return pd.Series(data['spot_price'])
def diff(data):
    return data['Close'] - data['spot_price']


import pandas as pd
from dateutil import relativedelta
def debt_cumulative(data, short_rate=0.0393, fees=0.002):
    return calculate_cumulative_debt_lent(data, short_rate=short_rate, fees=fees, ret_type=1)
def lent_cumulative(data, short_rate=0.0393, fees=0.002):
    return calculate_cumulative_debt_lent(data, short_rate=short_rate, fees=fees, ret_type=2)

def calculate_cumulative_debt_lent(data, short_rate=0.0393, fees=0.002, ret_type=1):
    def year_difference(dt1, dt2):
        delta = relativedelta.relativedelta(dt2, dt1)
        return delta.years + delta.months / 12 + delta.days / 365 + delta.hours / (365*24) + delta.minutes / (365*24*60)
    
    cumulative_debt = []
    cumulative_lent = []
    last_date_time = data.index[-1]  # Set last_date_time to the absolute last time in the data
    debt = 0
    lent = 0
    
    for index, date in enumerate(data.index):
        current_contract_price = data['Close'][index]
        current_spot_price = data['spot_price'][index]
        
        if last_date_time == date:
            cumulative_debt.append(debt)
            cumulative_lent.append(lent)
            continue
        
        debt_interval = year_difference(date, last_date_time)
        short_rate_for_interval = short_rate * debt_interval
        all_fees = (current_spot_price * (short_rate_for_interval + fees) + current_contract_price * fees)
        
        if current_contract_price > current_spot_price and current_contract_price - current_spot_price > all_fees:
            debt += current_spot_price * (1 + short_rate_for_interval)
            lent += current_contract_price * (1 - 2 * fees)
            cumulative_debt.append(debt)
            cumulative_lent.append(lent)
        else:
            cumulative_debt.append(debt)
            cumulative_lent.append(lent)
        
        
    if ret_type == 1:
        return pd.Series(cumulative_debt, index=data.index)
    elif ret_type == 2:
        return pd.Series(cumulative_lent, index=data.index)
