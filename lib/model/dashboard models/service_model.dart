import 'package:flutter/material.dart';

class ServiceModel {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final String imagePath;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  ServiceModel({
    required this.title,
    this.subtitle,
    this.badgeText,
    required this.imagePath,
    this.backgroundColor,
    this.onPressed,
  });
}