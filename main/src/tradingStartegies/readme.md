# tradingStrategies
<!-- - all tradingStrategies logic:
    - uses perpetual futures contract data / classical futures contract with expiry in 3M (required)
    - core functionality (required)
    - obtains parameters from the training set (optional)
    - shows performance on testing set (optional)
    - shows additional performance against Monte Carlo simulation (optional) -->
- strategy inputs data
- strategy logic
- strategy results in the form of HTML files
- progress from first to last strategy via notebook.ipynb



## [algorithm](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/tree/main/main/src/tradingStartegies/algorithm)
- directory which owns the core logic for each strategy

## [reports](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/tree/main/main/src/tradingStartegies/reports)
- contains detailed result from using our calibrated strategy on test data as  HTML file which is interactive view for the whole strategy progression, [for example](https://uno-uno.netlify.app)

## [main.py](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/tradingStartegies/main.py)
- main file for any execution, in the case of development it was used mainly as a debug file ... 

## [notebook.ipynb](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/tradingStartegies/notebook.ipynb) (development mode)
- is a graphical view with code + result progression for each defined algorithm from the directory [algorithm](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/tree/main/main/src/tradingStartegies/algorithm) and was also used to generate all [reports](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/tree/main/main/src/tradingStartegies/reports)
- is not (yet) in typical pretty view for nice reading

## [utils.py](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/tradingStartegies/utils.py) 
- python utils used across any other files or notebook