# Load all imports and data
from algorithm.corellation_friends import CorrelationFriends
from algorithm.uno_uno import UnoUno
from algorithm.example import SmaCross
from algorithm.arbi_check import ArbiCheck
from algorithm.klam import Klam
from backtesting import Backtest
from backtesting.test import GOOG
import pandas as pd
import numpy as np
import backtesting
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
date_string = '220325'
contactt_data = pd.read_csv(f'./data/arbitrageDataCheck/futures{date_string}.csv', parse_dates=True, infer_datetime_format=True)
contactt_data['spot_price'] = pd.read_csv(f'./data/arbitrageDataCheck/btcSpot{date_string}.csv')['Close']
contactt_data['theoretical_futures'] = pd.read_csv(f'./data/klam/theoreticalFutures{date_string}.csv')['Close']
print(contactt_data.head())
for index, value in enumerate(contactt_data['open_time']):
    try:
        pd.to_datetime(value, unit='ms')
    except ValueError:
        print(f"Value at index {index} is problematic: {value}")

contactt_data['open_time'] = pd.to_datetime(contactt_data['open_time'], unit='ms')
contactt_data.set_index('open_time', inplace=True)

klam = Backtest(contactt_data, Klam, cash=1_000_000, commission=.002)
print(klam.run())
klam.plot(resample=False, plot_volume=True, plot_drawdown=True)

# sl = [0.01, 0.02, 0.04, 0.07]
# tp = [0.01, 0.02, 0.04, 0.07]
# min_base_diff = [1, 10, 100, 200, 400, 600, 900]
# optimal_size = [0.1, 0.2, 0.5, 1, 2]
# optimize_result = klam.optimize(
#             optimal_size = optimal_size,
#             sl=sl,
#             tp=tp,
#             min_base_diff=min_base_diff,
#             maximize='Equity Final [$]',
#             method='skopt',
#             max_tries=1500,
#             random_state=0,
#             return_optimization=True,
#             return_heatmap=True,
#         )

# # print(optimize_result)