import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The two families of energy products BARREL trades.
enum EnergySector { crude, gas, refined }

extension EnergySectorX on EnergySector {
  String get label {
    switch (this) {
      case EnergySector.crude:
        return 'Crude Oil';
      case EnergySector.gas:
        return 'Natural Gas';
      case EnergySector.refined:
        return 'Refined Products';
    }
  }

  Color get color {
    switch (this) {
      case EnergySector.crude:
        return AppColors.crude;
      case EnergySector.gas:
        return AppColors.gas;
      case EnergySector.refined:
        return const Color(0xFFB388FF);
    }
  }
}

/// A static definition of a tradable energy contract.
///
/// Prices are simulated locally (see `PriceEngine`), so [basePrice] and
/// [volatility] describe a plausible starting point and daily behaviour rather
/// than a live market feed.
class Instrument {
  final String id; // stable key, e.g. "CL"
  final String symbol; // ticker shown to the user, e.g. "CL"
  final String name; // full name, e.g. "WTI Crude Oil"
  final EnergySector sector;
  final String quoteUnit; // e.g. "/ bbl"
  final String contractLabel; // e.g. "100 bbl"
  final double contractSize; // multiplier: price move x size x lots = P&L
  final double basePrice; // starting simulated price
  final double volatility; // per-tick relative volatility (std dev)
  final double tickSize; // minimum price increment
  final String emoji;

  const Instrument({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.quoteUnit,
    required this.contractLabel,
    required this.contractSize,
    required this.basePrice,
    required this.volatility,
    required this.tickSize,
    required this.emoji,
  });

  Color get color => sector.color;

  /// Notional (cash) value of a single lot at [price].
  double notional(double price) => price * contractSize;
}

/// The BARREL universe: crude oil and natural gas at the core, plus the refined
/// products traders watch alongside them.
class Instruments {
  static const List<Instrument> all = [
    Instrument(
      id: 'CL',
      symbol: 'CL',
      name: 'WTI Crude Oil',
      sector: EnergySector.crude,
      quoteUnit: '/ bbl',
      contractLabel: '100 bbl',
      contractSize: 100,
      basePrice: 78.42,
      volatility: 0.0016,
      tickSize: 0.01,
      emoji: '🛢️',
    ),
    Instrument(
      id: 'BZ',
      symbol: 'BZ',
      name: 'Brent Crude Oil',
      sector: EnergySector.crude,
      quoteUnit: '/ bbl',
      contractLabel: '100 bbl',
      contractSize: 100,
      basePrice: 82.15,
      volatility: 0.0015,
      tickSize: 0.01,
      emoji: '🌍',
    ),
    Instrument(
      id: 'NG',
      symbol: 'NG',
      name: 'Henry Hub Natural Gas',
      sector: EnergySector.gas,
      quoteUnit: '/ MMBtu',
      contractLabel: '1,000 MMBtu',
      contractSize: 1000,
      basePrice: 2.84,
      volatility: 0.0032,
      tickSize: 0.001,
      emoji: '🔥',
    ),
    Instrument(
      id: 'TTF',
      symbol: 'TTF',
      name: 'Dutch TTF Gas',
      sector: EnergySector.gas,
      quoteUnit: '/ MWh',
      contractLabel: '100 MWh',
      contractSize: 100,
      basePrice: 31.20,
      volatility: 0.0040,
      tickSize: 0.01,
      emoji: '⛽',
    ),
    Instrument(
      id: 'HO',
      symbol: 'HO',
      name: 'Heating Oil',
      sector: EnergySector.refined,
      quoteUnit: '/ gal',
      contractLabel: '1,000 gal',
      contractSize: 1000,
      basePrice: 2.53,
      volatility: 0.0018,
      tickSize: 0.0001,
      emoji: '🏭',
    ),
    Instrument(
      id: 'RB',
      symbol: 'RB',
      name: 'RBOB Gasoline',
      sector: EnergySector.refined,
      quoteUnit: '/ gal',
      contractLabel: '1,000 gal',
      contractSize: 1000,
      basePrice: 2.41,
      volatility: 0.0020,
      tickSize: 0.0001,
      emoji: '⛽',
    ),
  ];

  static Instrument byId(String id) =>
      all.firstWhere((i) => i.id == id, orElse: () => all.first);

  static List<Instrument> inSector(EnergySector sector) =>
      all.where((i) => i.sector == sector).toList();
}
