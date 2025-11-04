import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool hasSwitch;
  final bool showArrow;
  final Color primaryColor;
  final Color cardColor;
  final Color hoverColor;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.hasSwitch = false,
    this.showArrow = false,
    required this.primaryColor,
    required this.cardColor,
    required this.hoverColor,
  });

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool isSwitched = true;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isPressed ? widget.hoverColor : widget.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 5,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTapDown: (_) => setState(() => isPressed = true),
        onTapCancel: () => setState(() => isPressed = false),
        onTapUp: (_) => setState(() => isPressed = false),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.primaryColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (widget.hasSwitch)
                Switch(
                  value: isSwitched,
                  activeColor: widget.primaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade800,
                  onChanged: (value) => setState(() => isSwitched = value),
                ),
              if (widget.showArrow)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
            ],
          ),
        ),
      ),
    );
  }
}