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
    // required this.top,
    // required this.left,
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
    final Offset position =
        renderBox.localToGlobal(Offset.zero); // Posición en la pantalla
    //final Size size = renderBox.size; // Tamaño del botón
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 30,
        left: position.dx - 40,
        right: 20,
        child: Material(
          color: Colors.transparent,
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

    Future.delayed(const Duration(seconds: 2), () {
      _removeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: () => _showTooltip(context),
      child: Icon(widget.icon, size: widget.iconSize),
    );
  }
}
