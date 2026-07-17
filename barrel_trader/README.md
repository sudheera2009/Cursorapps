# 🛢️ BARREL — Oil & Gas Trading Desk

**Paper-trade crude oil & natural gas markets in real time.**

BARREL is a slick, self-contained energy trading simulator built with Flutter.
Start with a virtual **$100,000**, go long or short on WTI, Brent, Henry Hub
natural gas and refined products, and watch your P&L move as simulated prices
tick every second.

> ⚠️ **Simulation only.** Prices are randomly generated on-device. BARREL does
> not connect to any exchange and involves no real money or real markets. It is
> for education and entertainment.

## ✨ Highlights

- **Crude oil & natural gas at the core** — WTI (CL), Brent (BZ), Henry Hub
  natural gas (NG) and Dutch TTF gas (TTF), plus heating oil (HO) and RBOB
  gasoline (RB).
- **Live simulated tape** — a mean-reverting random-walk engine updates every
  instrument once a second, driving sparklines and full price charts.
- **Long & short** — profit whichever way the market moves, with a clean
  fully-funded (no-leverage) cash model so your account can never go negative.
- **Real P&L accounting** — mark-to-market equity, unrealized/realized P&L,
  average entry, day range and win rate.
- **Persistent account** — cash, positions, trade blotter and watchlist survive
  app restarts via `shared_preferences`.

## 🎮 Features

| Area | Details |
| --- | --- |
| Markets | Sector summary, All / Crude / Gas / Watchlist filters, live sparklines, LIVE/PAUSE toggle |
| Instrument | Big price + % change, area chart with your entry marker, session open/high/low range, contract specs |
| Trade ticket | Buy/Long or Sell/Short, lot stepper + quick amounts, order value vs free cash, buying-power guard |
| Portfolio | Account equity, all-time P&L, free cash vs invested, per-position cards with one-tap close |
| Activity | Trade count, win rate, realized P&L and a full trade blotter |
| Account | Live-feed toggle, reset account, about, risk disclaimer |

## 🧱 Architecture

```
lib/
├── core/            # theme & number/price formatting
├── models/          # instrument, quote, position, trade
├── services/        # price_engine (random-walk market simulator)
├── providers/       # TradingProvider (market + portfolio + persistence)
├── screens/         # splash, onboarding, home, market, instrument, trade,
│                    #   portfolio, history, account
└── widgets/         # panel card, change pill, sparkline, price chart, tiles
```

- **State**: `provider` + a single `TradingProvider` (the source of truth for
  the simulated market and the paper account).
- **Market engine**: `PriceEngine` runs an Ornstein-Uhlenbeck-style
  mean-reverting random walk per instrument; the provider ticks it on a timer.
- **Persistence**: `shared_preferences` (cash, positions, trades, watchlist).
- **Charts**: hand-rolled `CustomPainter`s — no chart dependencies.

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

Covers the instrument universe, quote math, long/short P&L accounting, the
price engine, and end-to-end order flow (open, close, short-cover, buying-power
rejection, reset).
