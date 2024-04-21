from algorithm.corellation_friends import CorrelationFriends
from algorithm.example import SmaCross
from backtesting import Backtest
from backtesting.test import GOOG
import pandas as pd
import backtesting

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
training_btc_data = btc_data.iloc[:10000]
test_btc_data = btc_data.iloc[10000:73920]


algos = dict(
    example = Backtest(GOOG, SmaCross, cash=10_000, commission=.002),
    correlation_friends = Backtest(btc_data, CorrelationFriends, cash=1_000_000, commission=.002)
)

''' Example test for backtesting '''
# result_stats = algos['example'].run()
# algos['example'].plot()



''' Corelation Friends v0.1 '''

correlation_friends = algos['correlation_friends']
safe_area_width_values = [x / 1000 for x in range(5, 20, 1)]  # Range from 0.005 to 0.1 with step size of 0.005
profit_take =  [0.01, 0.02, 0.03, 0.04]
loss_take = [0.01, 0.02, 0.03, 0.04]
level_multi = [10, 9, 8, 7, 6, 5]
result_stats = correlation_friends.run()
# Finding optimal values on training part
# stats = correlation_friends.optimize(
#     safe_area_width=safe_area_width_values,
#     profit_take=profit_take,
#     loss_take=loss_take,
#     level_multi=level_multi,
#     maximize='Equity Final [$]',
# )
# print(stats)

print(result_stats)
correlation_friends.plot(resample=True, plot_volume=True, plot_drawdown=True, )

# ''' Correlation Friends v0.2 '''
# same like before but now we will try the optimal moving time frime which will be applied on the test data
time_frame_capacity = [x for x in range(1, 10)]
btc_data_training_set = btc_data.iloc[:round(len(btc_data) / 2)]

for time_frame in time_frame_capacity:
   if len(time_frame * 2) > len(btc_data_training_set):
         break
   mini_training_set = btc_data_training_set.iloc[:time_frame]
   mini_test_set = btc_data_training_set.iloc[time_frame: time_frame * 2]
   while len(mini_test_set) < len(btc_data_training_set):
         mini_training_set = btc_data_training_set.iloc[:time_frame]
         mini_test_set = btc_data_training_set.iloc[time_frame: time_frame * 2]
         time_frame += 1

print(f"Optimal time frame: {optimal_time_frame}, Profit: {optimal_profit}")