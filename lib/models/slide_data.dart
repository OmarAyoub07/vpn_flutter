// Model representing a single slide in the Onboarding Features carousel.
import 'package:flutter/material.dart';

class SlideData {
  final String title;
  final String description;
  final IconData icon;

  SlideData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
