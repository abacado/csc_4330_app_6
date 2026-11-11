import 'package:material_ui/material_ui.dart';

/// Icons a member can pick for a community they start. Stored by key so the
/// database never holds platform-specific icon codes.
const communityIcons = <String, IconData>{
  'eco': Icons.eco_outlined,
  'terrain': Icons.terrain_outlined,
  'hiking': Icons.hiking_outlined,
  'run': Icons.directions_run_rounded,
  'yoga': Icons.self_improvement_outlined,
  'ball': Icons.sports_basketball_outlined,
  'music': Icons.music_note_outlined,
  'art': Icons.palette_outlined,
  'camera': Icons.camera_alt_outlined,
  'craft': Icons.gesture_rounded,
  'wood': Icons.carpenter_outlined,
  'garden': Icons.yard_outlined,
  'baking': Icons.bakery_dining_outlined,
  'cooking': Icons.restaurant_outlined,
  'books': Icons.menu_book_outlined,
  'games': Icons.sports_esports_outlined,
  'code': Icons.code_rounded,
  'pets': Icons.pets_outlined,
  'theatre': Icons.theater_comedy_outlined,
  'travel': Icons.flight_takeoff_rounded,
};

/// Tints a member can pick. Stored as 0xRRGGBB; the UI derives the pastel
/// tile colour and the readable dark shade from each one.
const communityTints = <int>[
  0x4E7A4F, // sage green
  0x3F7C80, // teal
  0x4F6A85, // slate blue
  0x6B5288, // violet
  0xB0577A, // rose
  0xB8643F, // terracotta
  0xC08A2E, // ochre
  0x8A6A4A, // walnut
];

IconData communityIcon(String? key) =>
    communityIcons[key] ?? Icons.eco_outlined;

Color communityTint(int rgb) => Color(0xFF000000 | rgb);
