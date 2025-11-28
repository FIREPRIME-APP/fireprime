import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatefulWidget {
  // final double top;
  // final double left;

  final IconData icon;
  final double iconSize;
  final String text;
  final double fontSize;

  const InfoDialog({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.text,
    required this.fontSize,
  });

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTooltip(BuildContext context) {
    _removeOverlay();
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 30,
        left: position.dx - 70,
        right: 20,
        child: Material(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.fontSize,
                fontFamily: 'OpenSans',
              ),
              softWrap: true,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _removeOverlay();
    });
  }

  Future<void> _showInfoDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
              // softWrap: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr('close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: () => _showInfoDialog(),
      child: Icon(widget.icon, size: widget.iconSize),
    );
  }
}
