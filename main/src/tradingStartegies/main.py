# Load all imports and data
from algorithm.corellation_friends import CorrelationFriends
from algorithm.uno_uno import UnoUno
from algorithm.example import SmaCross
from algorithm.arbi_check import ArbiCheck
from backtesting import Backtest
from backtesting.test import GOOG
import pandas as pd
import numpy as np
import backtesting
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

btc_data = pd.read_csv('./data/15m2024_02_04_to_2024_02_10/BTC.csv', parse_dates=True, infer_datetime_format=True)
contactt_data = pd.read_csv('./data/arbitrageDataCheck/futures231229.csv', parse_dates=True, infer_datetime_format=True)
contactt_data['spot_price'] = pd.read_csv('./data/arbitrageDataCheck/btcSpot231229.csv')['Close']
print(contactt_data.head())
for index, value in enumerate(btc_data['open_time']):
    try:
        pd.to_datetime(value, unit='ms')
    except ValueError:
        print(f"Value at index {index} is problematic: {value}")
btc_data['open_time'] = pd.to_datetime(btc_data['open_time'], unit='ms') 
btc_data.set_index('open_time', inplace=True)


for index, value in enumerate(contactt_data['open_time']):
    try:
        pd.to_datetime(value, unit='ms')
    except ValueError:
        print(f"Value at index {index} is problematic: {value}")

contactt_data['open_time'] = pd.to_datetime(contactt_data['open_time'], unit='ms')
contactt_data.set_index('open_time', inplace=True)



print(contactt_data.head())

btc_data = btc_data.iloc[:73920]
train_btc_datAa = btc_data.iloc[:30000]
test_btc_data = btc_data.iloc[30000:73920]

# train_btc_datAa['safe_area_width'] = 0.01
# train_btc_datAa['profit_take'] = 0.01
# train_btc_datAa['loss_take'] = 0.01
# train_btc_datAa['level_multi'] = 3
# print(train_btc_datAa.head())

train_contract_data = contactt_data.iloc[:30000]
algos = dict(
    example = Backtest(GOOG, SmaCross, cash=10_000, commission=.002),
    correlation_friends_v_01 = Backtest(train_btc_datAa, CorrelationFriends, cash=1_000_000, commission=.002),
    correlation_friends_v_02 = None, # this will be created later on,
    uno_uno = Backtest(train_contract_data, UnoUno, cash = 1_000_000, commission=.002),
    arbi_check = Backtest(train_contract_data, ArbiCheck, cash=100_000_000, commission=0)
)
ret = algos['arbi_check'].run()
algos['arbi_check'].plot(resample=False, plot_volume=True, plot_drawdown=True)
print(ret)





