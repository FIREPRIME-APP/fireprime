import 'package:fireprime/firebase/event_manage.dart';
import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String screenId;
  final String buttonId;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.screenId,
    required this.buttonId,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFocusChange() {
    print('Focus: ${_focusNode.hasFocus}');
    if (_focusNode.hasFocus) {
      saveEventdata(screenId: widget.screenId, buttonId: widget.buttonId);
    }
  }
}
