import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String hintText;

  const SearchBar({
    Key? key,
    this.initialValue = '',
    required this.onChanged,
    this.hintText = 'Search...',
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(24),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}