import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class MyPreWidget extends StatefulWidget {
  final dynamic data;
  final double maxHeight;
  final int debounceMs;
  final VoidCallback?
  onRefresh; // 💡 Callback cho phép trang cha update lại data khi bấm refresh

  const MyPreWidget({
    super.key,
    required this.data,
    this.maxHeight = 300,
    this.debounceMs = 300,
    this.onRefresh,
  });

  @override
  State<MyPreWidget> createState() => _MyPreWidgetState();
}

class _MyPreWidgetState extends State<MyPreWidget> {
  Timer? _debounceTimer;
  late String _formattedJson;

  @override
  void initState() {
    super.initState();
    _formattedJson = _formatJson(widget.data);
  }

  @override
  void didUpdateWidget(covariant MyPreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data != oldWidget.data) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
        if (mounted) {
          _refreshData();
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _formattedJson = _formatJson(widget.data);
    });
  }

  String _formatJson(dynamic rawData) {
    if (rawData == null) return 'null';
    try {
      final object = rawData is String ? jsonDecode(rawData) : rawData;
      return const JsonEncoder.withIndent('  ').convert(object);
    } catch (e) {
      return rawData.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Stack(
        children: [
          // Phần nội dung JSON
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  _formattedJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFF9CDCFE),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          // 💡 Nút Refresh ở góc trên bên phải
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  if (widget.onRefresh != null) {
                    widget.onRefresh!(); // Gọi callback từ trang cha nếu có
                  }
                  _refreshData(); // Refresh UI của MyPreWidget
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
