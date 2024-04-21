# Load all imports and data
from algorithm.corellation_friends import CorrelationFriends
from algorithm.example import SmaCross
from backtesting import Backtest
from backtesting.test import GOOG
import pandas as pd
import numpy as np
import backtesting
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

btc_data = pd.read_csv('data/15m2024_02_04_to_2024_02_10/BTC.csv', parse_dates=True, infer_datetime_format=True)
btc_data['friend_0'] = pd.read_csv('data/15m2024_02_04_to_2024_02_10/XRP.csv')['Close']
btc_data['friend_1'] = pd.read_csv('data/15m2024_02_04_to_2024_02_10/ETH.csv')['Close']
btc_data['friend_2'] = pd.read_csv('data/15m2024_02_04_to_2024_02_10/ADA.csv')['Close']
btc_data['friend_3'] = pd.read_csv('data/15m2024_02_04_to_2024_02_10/SOL.csv')['Close']
print(btc_data.head())

for index, value in enumerate(btc_data['open_time']):
    try:
        pd.to_datetime(value, unit='ms')
    except ValueError:
        print(f"Value at index {index} is problematic: {value}")
btc_data['open_time'] = pd.to_datetime(btc_data['open_time'], unit='ms') 
btc_data.set_index('open_time', inplace=True)



btc_data = btc_data.iloc[:73920]
train_btc_data = btc_data.iloc[:30000]
test_btc_data = btc_data.iloc[30000:73920]

algos = dict(
    example = Backtest(GOOG, SmaCross, cash=10_000, commission=.002),
    correlation_friends_v_01 = Backtest(train_btc_data, CorrelationFriends, cash=1_000_000, commission=.002),
    correlation_friends_v_02 = None # this will be created later on
)


from algorithm.trend_follower import TrendFollower

test = Backtest(train_btc_data, TrendFollower,  cash=1_000_000, commission=.002)
result = test.run()
print(result)
test.plot(resample=False, plot_volume=True, plot_drawdown=True, )

tics_for_lin_reg = [10, 15, 30, 50, 100]
tics_for_variance = [10, 15, 30, 50, 100]
variance_percentile_num = [40, 50]
# [10, 20, 30, 

take_profit = [0.01, 0.02]
stop_loss = [0.01, 0.02]
pos_min_slope = [0.2, 0.5]
pos_max_slope = [0.7, 0.9]


# optimize1
# result = test.optimize(
#     tics_for_lin_reg=tics_for_lin_reg,
#     tics_for_variance=tics_for_variance,
#     variance_percentile_num=variance_percentile_num,
#     take_profit=take_profit,
#     stop_loss=stop_loss,
#     pos_min_slope=pos_min_slope,
#     pos_max_slope=pos_max_slope,
#     maximize='Equity Final [$]',
# )
# print(result)
# test.plot(resample=False, plot_volume=True, plot_equity=True, plot_drawdown=True, )


# optimize2
# stats_skopt, heatmap, optimize_result = test.optimize(
#     tics_for_lin_reg=[10, 20, 50],
#     tics_for_variance=[20, 100,50],
#     variance_percentile_num=[40,50,60],
#     take_profit=[0.02, 0.03, 0.04],
#     stop_loss=[0.02, 0.03, 0.04],
#     pos_min_slope=[0.5, 0.55],
#     pos_max_slope=[0.7, 0.75],
#     level_multi=[3,5,10],
#     maximize='Equity Final [$]',
#     method='skopt',
#     max_tries=5,
#     random_state=0,
#     return_optimization=True,
#     return_heatmap=True,
# )
# print(heatmap.sort_values().iloc[-3:])
# print(stats_skopt)
# test.plot(resample=False, plot_volume=True, plot_equity=True, plot_drawdown=True, )

# from skopt.plots import plot_objective
# _ = plot_objective(optimize_result, n_points=10)

# test_final = Backtest(test_btc_data, TrendFollower,  cash=1_000_000, commission=.002)

# result = test_final.optimize(
#     tics_for_lin_reg=10,
#     tics_for_variance=100,
#     variance_percentile_num=40,
#     take_profit=0.02,
#     stop_loss=0.02,
#     pos_min_slope=0.5,
#     pos_max_slope=0.7,
#     level_multi=3,
#     maximize='Equity Final [$]',
# )
# result = test_final.run()
# print(result)
# test_final.plot(resample=False, plot_volume=True, plot_equity=True, plot_drawdown=True, )


trend_follower_test = Backtest(test_btc_data, TrendFollower, cash=1_000_000, commission=.002)
result = trend_follower_test.run()
print(result)