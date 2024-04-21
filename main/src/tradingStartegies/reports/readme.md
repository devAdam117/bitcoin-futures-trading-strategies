# reports
- each folder contains these parts
    - ## ./*/*.html  (required)
        - interactive view ho given algo was performing eg. [Example strategy](https://uno-uno.netlify.app) 
    - ## ./*/stats.txt (optional)
        - represent basic stats of how given algo performed on testing data set
        eg: 
        ```
        Start                     2022-10-31 12:00:00
        End                       2024-01-31 23:45:00
        Duration                    457 days 11:45:00
        Exposure Time [%]                   96.714481
        Equity Final [$]                    1384509.2
        Equity Peak [$]                     1537892.2
        Return [%]                           38.45092
        Buy & Hold Return [%]              106.003359
        Return (Ann.) [%]                    29.59993
        Volatility (Ann.) [%]               28.854774
        Sharpe Ratio                         1.025824
        Sortino Ratio                        2.086462
        Calmar Ratio                         1.665374
        Max. Drawdown [%]                  -17.773743
        Avg. Drawdown [%]                   -1.212335
        Max. Drawdown Duration      100 days 18:45:00
        Avg. Drawdown Duration        4 days 09:54:00
        # Trades                                  143
        Win Rate [%]                        64.335664
        Best Trade [%]                      58.950719
        Worst Trade [%]                    -19.360378
        Avg. Trade [%]                       7.901263
        Max. Trade Duration          94 days 09:00:00
        Avg. Trade Duration          42 days 00:56:00
        Profit Factor                        4.955687
        Expectancy [%]                       9.198385
        SQN                                  6.304681
        _strategy                       RevertIt
        _equity_curve                             ...
        _trades                        Size  Entry...
    
    - ## ./*/stats.png (optional)
        - captured screenshot of stats.txt