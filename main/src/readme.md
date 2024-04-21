# src
- whole code of calibration is done in R lang, trading strategies in python

## [tradingStartegies](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/tree/main/main/src/tradingStartegies)
- directory which contains separate logic for handling all connected trading strategies (practical part of diploma thesis)

## [BtcCalibration.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/BtcCalibration.R)
- functionality for generating paths for BTC price based on the GBM approach

## [calibrationFunctions.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/calibrationFunctions.R)
- core defined calibration functions
- they are used in many other files from the 'load from context' approach, meaning this file should be run first

## [calibrationScript.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/calibrationScript.R)
- core script for assigning all variables (correlation, P_t, sigma_t, ...) in to the R lang context 
- should be run right after the [calibrationFunctions.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/calibrationFunctions.R) and can be debugged to see a different type of outputs.

## [futurePrice.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/futuresPrice.R) (deprecated)
- use instead futureModel.R
- file which uses already set variables from [calibrationScript.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/calibrationScript.R) for estimating theoretical futures price

## [futureModel.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/futuresModel.R)
- newer and correct version of [futurePrice.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/futuresPrice.R)
- shows how theoretical futures model moves using idea from [../paper.pdf](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/paper.pdf) 
- shows also theoretical forward price
- compares it to the spot price S_t, exchange price for futures contact

## [volatilitySmile.R](https://github.com/devAdam117/futures-trading-strategies-bitcoin-dp/blob/main/main/src/volatilitySmile.R)
- logic for calculating implicit sigma_S via option strategy
- show our own created volatility smile using exchange data