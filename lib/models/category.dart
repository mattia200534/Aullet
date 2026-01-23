import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required String colorHex,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'] as String,
    name: map['name'] as String,
    icon: map['icon'] as String,
    color: map['color'] as String,
    colorHex: '',
  );
}
