import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Circle avatar from a network photo, falling back to the name's initial
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final color = AppColors
        .avatarColors[name.hashCode.abs() % AppColors.avatarColors.length];
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      foregroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      // Shown while loading or if the photo fails
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
