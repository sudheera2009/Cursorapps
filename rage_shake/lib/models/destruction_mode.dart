import 'package:flutter/material.dart';

class DestructionMode {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredLevel;
  final List<DestructibleObject> objects;
  final String backgroundGradientStart;
  final String backgroundGradientEnd;

  const DestructionMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredLevel,
    required this.objects,
    required this.backgroundGradientStart,
    required this.backgroundGradientEnd,
  });

  bool isUnlocked(int userLevel) => userLevel >= requiredLevel;
}

class DestructibleObject {
  final String name;
  final IconData icon;
  final int baseValue;
  final double size;

  const DestructibleObject({
    required this.name,
    required this.icon,
    required this.baseValue,
    this.size = 1.0,
  });
}

class DestructionModes {
  static const office = DestructionMode(
    id: 'office',
    name: 'OFFICE RAMPAGE',
    description: 'Destroy cubicles, computers, and that printer that always jams.',
    icon: Icons.business,
    color: Color(0xFF4A90D9),
    requiredLevel: 1,
    backgroundGradientStart: '#1a1a2e',
    backgroundGradientEnd: '#16213e',
    objects: [
      DestructibleObject(name: 'Computer', icon: Icons.computer, baseValue: 500),
      DestructibleObject(name: 'Monitor', icon: Icons.desktop_windows, baseValue: 300),
      DestructibleObject(name: 'Printer', icon: Icons.print, baseValue: 800),
      DestructibleObject(name: 'Chair', icon: Icons.chair, baseValue: 200),
      DestructibleObject(name: 'Desk', icon: Icons.table_restaurant, baseValue: 600),
      DestructibleObject(name: 'Coffee Machine', icon: Icons.coffee, baseValue: 400),
    ],
  );

  static const kitchen = DestructionMode(
    id: 'kitchen',
    name: 'KITCHEN CHAOS',
    description: 'Smash dishes, appliances, and make a beautiful mess.',
    icon: Icons.kitchen,
    color: Color(0xFFE57373),
    requiredLevel: 1,
    backgroundGradientStart: '#2d1b1b',
    backgroundGradientEnd: '#1a1010',
    objects: [
      DestructibleObject(name: 'Plate', icon: Icons.circle_outlined, baseValue: 50),
      DestructibleObject(name: 'Glass', icon: Icons.local_bar, baseValue: 75),
      DestructibleObject(name: 'Pot', icon: Icons.soup_kitchen, baseValue: 150),
      DestructibleObject(name: 'Blender', icon: Icons.blender, baseValue: 200),
      DestructibleObject(name: 'Microwave', icon: Icons.microwave, baseValue: 400),
      DestructibleObject(name: 'Refrigerator', icon: Icons.kitchen, baseValue: 1000, size: 1.5),
    ],
  );

  static const cars = DestructionMode(
    id: 'cars',
    name: 'CAR CRUSHER',
    description: 'Total vehicles in an epic junkyard rampage.',
    icon: Icons.directions_car,
    color: Color(0xFFFFB74D),
    requiredLevel: 3,
    backgroundGradientStart: '#2d2416',
    backgroundGradientEnd: '#1a1510',
    objects: [
      DestructibleObject(name: 'Sedan', icon: Icons.directions_car, baseValue: 5000),
      DestructibleObject(name: 'SUV', icon: Icons.directions_car_filled, baseValue: 8000, size: 1.3),
      DestructibleObject(name: 'Sports Car', icon: Icons.sports_motorsports, baseValue: 15000),
      DestructibleObject(name: 'Truck', icon: Icons.local_shipping, baseValue: 12000, size: 1.5),
      DestructibleObject(name: 'Motorcycle', icon: Icons.two_wheeler, baseValue: 3000, size: 0.7),
      DestructibleObject(name: 'Bus', icon: Icons.directions_bus, baseValue: 25000, size: 2.0),
    ],
  );

  static const city = DestructionMode(
    id: 'city',
    name: 'CITY DESTROYER',
    description: 'Become a force of nature. Level entire buildings.',
    icon: Icons.location_city,
    color: Color(0xFF9575CD),
    requiredLevel: 5,
    backgroundGradientStart: '#1a1a2e',
    backgroundGradientEnd: '#0f0f1a',
    objects: [
      DestructibleObject(name: 'House', icon: Icons.home, baseValue: 50000),
      DestructibleObject(name: 'Apartment', icon: Icons.apartment, baseValue: 150000, size: 1.5),
      DestructibleObject(name: 'Skyscraper', icon: Icons.business, baseValue: 500000, size: 2.0),
      DestructibleObject(name: 'Bridge', icon: Icons.stairs, baseValue: 300000, size: 1.8),
      DestructibleObject(name: 'Stadium', icon: Icons.stadium, baseValue: 800000, size: 2.5),
      DestructibleObject(name: 'Monument', icon: Icons.account_balance, baseValue: 1000000),
    ],
  );

  static const space = DestructionMode(
    id: 'space',
    name: 'SPACE ANNIHILATOR',
    description: 'Obliterate planets, stars, and entire galaxies.',
    icon: Icons.rocket_launch,
    color: Color(0xFF4DD0E1),
    requiredLevel: 10,
    backgroundGradientStart: '#0a0a1a',
    backgroundGradientEnd: '#000005',
    objects: [
      DestructibleObject(name: 'Asteroid', icon: Icons.blur_circular, baseValue: 100000),
      DestructibleObject(name: 'Moon', icon: Icons.nightlight_round, baseValue: 500000, size: 1.2),
      DestructibleObject(name: 'Planet', icon: Icons.public, baseValue: 2000000, size: 1.5),
      DestructibleObject(name: 'Star', icon: Icons.star, baseValue: 10000000, size: 2.0),
      DestructibleObject(name: 'Black Hole', icon: Icons.lens_blur, baseValue: 50000000, size: 2.5),
      DestructibleObject(name: 'Galaxy', icon: Icons.all_inclusive, baseValue: 100000000, size: 3.0),
    ],
  );

  static const volcano = DestructionMode(
    id: 'volcano',
    name: 'VOLCANO FURY',
    description: 'Unleash volcanic destruction. Melt everything in your path.',
    icon: Icons.volcano,
    color: Color(0xFFFF5722),
    requiredLevel: 7,
    backgroundGradientStart: '#3d1a0a',
    backgroundGradientEnd: '#1a0a05',
    objects: [
      DestructibleObject(name: 'Boulder', icon: Icons.circle, baseValue: 5000),
      DestructibleObject(name: 'Lava Rock', icon: Icons.hexagon, baseValue: 8000),
      DestructibleObject(name: 'Volcano', icon: Icons.volcano, baseValue: 50000, size: 2.0),
      DestructibleObject(name: 'Mountain', icon: Icons.terrain, baseValue: 100000, size: 2.5),
      DestructibleObject(name: 'Island', icon: Icons.landscape, baseValue: 200000, size: 2.0),
      DestructibleObject(name: 'Tectonic Plate', icon: Icons.layers, baseValue: 500000, size: 3.0),
    ],
  );

  static const underwater = DestructionMode(
    id: 'underwater',
    name: 'DEEP SEA HAVOC',
    description: 'Wreck submarines, ships, and ancient underwater ruins.',
    icon: Icons.water,
    color: Color(0xFF26C6DA),
    requiredLevel: 8,
    backgroundGradientStart: '#0a2a3a',
    backgroundGradientEnd: '#051520',
    objects: [
      DestructibleObject(name: 'Coral', icon: Icons.park, baseValue: 2000),
      DestructibleObject(name: 'Submarine', icon: Icons.directions_boat, baseValue: 30000, size: 1.5),
      DestructibleObject(name: 'Shipwreck', icon: Icons.sailing, baseValue: 50000, size: 1.8),
      DestructibleObject(name: 'Oil Rig', icon: Icons.oil_barrel, baseValue: 150000, size: 2.0),
      DestructibleObject(name: 'Underwater City', icon: Icons.location_city, baseValue: 500000, size: 2.5),
      DestructibleObject(name: 'Kraken', icon: Icons.pest_control, baseValue: 1000000, size: 3.0),
    ],
  );

  static const haunted = DestructionMode(
    id: 'haunted',
    name: 'HAUNTED HORROR',
    description: 'Destroy cursed objects and banish supernatural entities.',
    icon: Icons.castle,
    color: Color(0xFF7E57C2),
    requiredLevel: 12,
    backgroundGradientStart: '#1a0a2a',
    backgroundGradientEnd: '#0a0515',
    objects: [
      DestructibleObject(name: 'Coffin', icon: Icons.inbox, baseValue: 10000),
      DestructibleObject(name: 'Tombstone', icon: Icons.space_bar, baseValue: 15000),
      DestructibleObject(name: 'Ghost', icon: Icons.blur_on, baseValue: 50000),
      DestructibleObject(name: 'Haunted Mansion', icon: Icons.castle, baseValue: 200000, size: 2.0),
      DestructibleObject(name: 'Demon Portal', icon: Icons.blur_circular, baseValue: 500000, size: 1.5),
      DestructibleObject(name: 'Ancient Curse', icon: Icons.auto_fix_high, baseValue: 1000000, size: 2.5),
    ],
  );

  static List<DestructionMode> get all => [office, kitchen, cars, city, volcano, underwater, space, haunted];

  static DestructionMode getById(String id) {
    return all.firstWhere((mode) => mode.id == id, orElse: () => office);
  }
}
