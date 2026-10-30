import 'package:material_ui/material_ui.dart';

import 'hobby.dart';

enum ListingType {
  sale('For sale', 'Sell', Icons.sell_outlined, Color(0xFF2F5D45)),
  trade('Trade', 'Trade', Icons.swap_horiz_rounded, Color(0xFF4F6A85)),
  lend('Lend', 'Lend', Icons.handshake_outlined, Color(0xFF8A6A4A)),
  free('Free', 'Free', Icons.volunteer_activism_outlined, Color(0xFFB85C38));

  const ListingType(this.label, this.verb, this.icon, this.color);

  final String label;
  final String verb;
  final IconData icon;
  final Color color;
}

class Listing {
  const Listing({
    required this.id,
    required this.hobbyId,
    required this.title,
    required this.description,
    required this.type,
    required this.sellerName,
    required this.sellerLevel,
    required this.condition,
    required this.postedAt,
    this.price,
  });

  final String id;
  final String hobbyId;
  final String title;
  final String description;
  final ListingType type;
  final double? price;
  final String sellerName;
  final SkillLevel sellerLevel;
  final String condition;
  final DateTime postedAt;

  String get priceLabel => switch (type) {
    ListingType.sale => '\$${price?.toStringAsFixed(0) ?? '—'}',
    ListingType.trade => 'Open to trades',
    ListingType.lend => 'Borrow',
    ListingType.free => 'Free',
  };
}
