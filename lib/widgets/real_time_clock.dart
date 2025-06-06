import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealTimeClock extends StatefulWidget {
  final String zona; // Contoh: 'WIB'

  const RealTimeClock({super.key, this.zona = 'WIB'});

  @override
  State<RealTimeClock> createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late Timer _timer;
  late DateTime _now;

  final Map<String, int> _offsets = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'London': 1,
  };

  @override
  void initState() {
    super.initState();
    _now = DateTime.now().toUtc().add(Duration(hours: _offsets[widget.zona]!));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now().toUtc().add(Duration(hours: _offsets[widget.zona]!));
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm:ss').format(_now);
    final dateString = DateFormat('dd MMMM yyyy').format(_now);

    return Text(
      '🕒 Sekarang: $timeString ${widget.zona} – $dateString',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)]),
    );
  }
}
