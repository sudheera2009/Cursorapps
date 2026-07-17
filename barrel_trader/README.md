# 🛢️ BARREL — Oil & Gas Trading & Signal Desk

**Paper-trade crude oil & natural gas — with an AI signal pipeline built in.**

BARREL is a self-contained Flutter energy trading app. Start with a virtual
**$100,000**, go long or short on WTI, Brent, Henry Hub natural gas and refined
products, and get **BUY / SELL / WAIT** signals with a confidence score from a
technical-indicator + fundamentals pipeline — with alerts pushed to an in-app
feed (and optionally Telegram).

> ⚠️ **Simulation only.** Prices are randomly generated on-device and signals
> are model estimates on that simulated data. BARREL does not connect to any
> exchange, uses no real money, and is not financial advice. For education and
> entertainment.

## 🧭 The pipeline

```
        Market Data (Zerodha Kite API)          ← MarketDataSource
                    |                              (SimulatedMarketDataSource today,
                    v                               KiteMarketDataSource stub)
         Historical OHLC + Volume                ← Candle
                    |
                    v
        Technical Indicator Engine              ← Indicators
   (EMA, VWAP, RSI, MACD, ATR, Bollinger, ADX)
                    |
                    v
          AI/ML Prediction Layer                ← PredictionModel
              |            |                       (logistic blend, interpretable)
       News Sentiment   Weather/EIA             ← ContextProvider / MarketContext
              |            |
              +-----+------+
                    v
         Signal Generation Engine               ← SignalEngine
        (BUY / SELL / WAIT + Confidence)        ← TradeSignal
                    |
                    v
         Mobile App / Web Dashboard             ← Signals & Instrument screens
                    |
                    v
    Telegram / WhatsApp / Email Alert           ← NotificationChannel
                                                   (In-app + Telegram real;
                                                    WhatsApp/Email stubs)
```

Every node exists as a small, swappable Dart component so you can replace the
simulator with live data or a trained model without touching the rest of the
app.

## ✨ Highlights

- **Crude oil & natural gas at the core** — WTI (`CL`), Brent (`BZ`), Henry Hub
  gas (`NG`), Dutch TTF gas (`TTF`), plus heating oil (`HO`) and RBOB gasoline
  (`RB`).
- **Real OHLC + volume** — the engine produces candles, not just ticks, so the
  indicator math is authentic.
- **Full technical indicator engine** — EMA(9/21/50), VWAP, RSI(14), MACD,
  ATR(14), Bollinger Bands, ADX/±DI — standard formulas (Wilder smoothing).
- **Interpretable prediction layer** — a logistic model blends technicals with
  news sentiment + EIA inventory + weather into a probability of an up-move, and
  **exposes every contribution** so signals come with plain-English reasons.
- **Signals dashboard** — BUY/SELL/WAIT per instrument with a confidence meter
  and the top drivers.
- **Alerts** — an in-app alert feed that fires when a signal crosses your
  confidence threshold, with an optional **real Telegram** channel and
  documented WhatsApp/Email adapters.
- **Full paper account** — long/short, mark-to-market equity, realized/unrealized
  P&L, trade blotter, watchlist, all persisted locally.

## 🎮 Screens

| Tab | What's there |
| --- | --- |
| Markets | Sector summary, filters, live sparklines, LIVE/PAUSE toggle |
| Signals | BUY/SELL/WAIT cards with confidence + reasons, alerts bell |
| Portfolio | Equity, all-time P&L, positions with one-tap close |
| Activity | Trade count, win rate, realized P&L, blotter |
| Account | Live-feed toggle, **Alerts & channels**, reset, about |

The **instrument screen** ties it together: price chart with your entry line,
the AI signal card, a full technical-indicator readout, a fundamentals panel
(sentiment / EIA / weather), session stats and contract specs.

## 🧱 Architecture

```
lib/
├── core/            # theme & number/price formatting
├── models/          # instrument, candle, quote, position, trade,
│                    #   market_context, trade_signal, signal_alert
├── services/        # market_data_source (Simulated + Kite stub), price_engine,
│                    #   indicators, context_provider, prediction_model,
│                    #   signal_engine, notification_channel
├── providers/       # TradingProvider (market + pipeline + account + alerts)
├── screens/         # splash, onboarding, home, market, instrument, trade,
│                    #   signals, alerts, alert_settings, portfolio, history, account
└── widgets/         # panel card, change pill, sparkline, price chart,
                     #   instrument tile, signal badge, stat box
```

- **State**: `provider` + a single `TradingProvider` (the source of truth).
- **Persistence**: `shared_preferences` (account, trades, alerts, settings).
- **Charts**: hand-rolled `CustomPainter`s — no chart dependencies.

## 🔌 Going live (integration guide)

Each pipeline node is an interface. To move from simulation to production:

1. **Market data → Zerodha Kite**: implement `KiteMarketDataSource`
   (`lib/services/market_data_source.dart`). Use Kite Connect's
   `getHistoricalData` for OHLC+volume and the Kite Ticker websocket (or `quote`
   polling) for live prices; map each row to a `Candle`. Pass it to
   `TradingProvider(dataSource: KiteMarketDataSource(...))`.
2. **News sentiment + Weather/EIA**: implement `ContextProvider` to call a news
   API + sentiment model and the EIA storage reports + a weather API, returning a
   `MarketContext` (all scores normalised to −1..+1, positive = bullish).
3. **AI/ML model**: swap `PredictionModel` for a trained model that returns a
   probability + feature attributions via the same `predict` contract.
4. **Alerts**: fill in `WhatsAppChannel` / `EmailChannel`
   (`lib/services/notification_channel.dart`); `TelegramChannel` already works —
   add a bot token + chat id in **Account → Alerts & channels**.

Supply all credentials via secure configuration — never hard-code them.

## 🚀 Getting started

```bash
cd barrel_trader
flutter pub get
flutter run           # or: flutter run -d chrome
```

Requires Flutter 3.8+.

## 🧪 Tests

```bash
flutter test
```

Covers the instrument universe, quote/position P&L math, the price/candle
engine, the technical indicators (EMA/RSI/Bollinger/ATR/ADX/VWAP), the signal
engine (BUY on uptrends / SELL on downtrends, confidence bounds), end-to-end
order flow, and UI navigation.
