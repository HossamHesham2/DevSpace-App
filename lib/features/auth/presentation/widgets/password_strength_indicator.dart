import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  int get strength {
    int score = 0;

    if (password.length >= 8) score++;

    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) score++;

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    return score;
  }

  String get strengthText {
    if (password.isEmpty) return 'Password strength';

    switch (strength) {
      case 1:
        return 'Weak password';
      case 2:
        return 'Fair password';
      case 3:
        return 'Good password';
      case 4:
        return 'Strong security key';
      default:
        return 'Very weak password';
    }
  }

  Color get strengthColor {
    switch (strength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return const Color(0xFF18A873);
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.verified_user_outlined, color: strengthColor, size: 16),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                strengthText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '$strength/4',
              style: const TextStyle(color: Color(0xFF667085), fontSize: 14),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: index < strength
                        ? strengthColor
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
