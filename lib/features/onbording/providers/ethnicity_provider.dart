import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model
class Ethnicity {
  final int id;
  final String name;
  final String emoji;
  final String? colorHint;

  Ethnicity({required this.id, required this.name, required this.emoji, this.colorHint});

  factory Ethnicity.fromJson(Map<String, dynamic> json) {
    return Ethnicity(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      colorHint: json['color_hint'],
    );
  }
}

final ethnicitiesProvider =
    FutureProvider.family<List<Ethnicity>, String>((ref, countryCode) async {
  final response = await Supabase.instance.client
      .from('ethnicities')
      .select()
      .eq('country_code', countryCode)
      .order('name');

  return response.map<Ethnicity>((json) => Ethnicity.fromJson(json)).toList();
});

 Color getColorFromHint(String? hint) {
  switch (hint) {
    case 'orange': return Colors.orange.shade100;
    case 'green': return Colors.green.shade100;
    case 'blue': return Colors.blue.shade100;
    case 'purple': return Colors.purple.shade100;
    case 'pink': return Colors.pink.shade100;
    case 'teal': return Colors.teal.shade100;
    default: return Colors.grey.shade100;
  }
}