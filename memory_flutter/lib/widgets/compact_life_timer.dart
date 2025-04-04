import 'dart:async';
import 'package:flutter/material.dart';

class CompactLifeTimer extends StatefulWidget {
  final DateTime eventDate;
  final TextStyle? textStyle;
  final bool compact;
  final Color? textColor;
  
  const CompactLifeTimer({
    Key? key,
    required this.eventDate,
    this.textStyle,
    this.compact = true,
    this.textColor,
  }) : super(key: key);

  @override
  State<CompactLifeTimer> createState() => _CompactLifeTimerState();
}

class _CompactLifeTimerState extends State<CompactLifeTimer> {
  late Timer _timer;
  String _timeString = '';
  
  // Update interval - every minute for compact view to save resources
  final Duration _updateInterval = const Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    
    // Calculate initially
    _calculateTimeSince();
    
    // Update periodically
    _timer = Timer.periodic(widget.compact ? _updateInterval : const Duration(seconds: 1), (timer) {
      _calculateTimeSince();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeSince() {
    final now = DateTime.now();
    final difference = now.difference(widget.eventDate);
    
    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    
    // Calculate months and years
    final months = (days / 30.4375).floor(); // Average month length
    final years = (days / 365.25).floor(); // Account for leap years
    
    setState(() {
      if (widget.compact) {
        // Compact format: 2y 3m, 4d 5h, etc.
        if (years > 0) {
          _timeString = '${years}y';
          if (years < 10) {
            final remainingMonths = ((days - (years * 365.25)) / 30.4375).floor();
            if (remainingMonths > 0) {
              _timeString += ' ${remainingMonths}m';
            }
          }
        } else if (months > 0) {
          _timeString = '${months}m';
          if (months < 10) {
            final remainingDays = (days - (months * 30.4375)).floor();
            if (remainingDays > 0) {
              _timeString += ' ${remainingDays}d';
            }
          }
        } else if (days > 0) {
          _timeString = '${days}d';
        } else if (hours > 0) {
          _timeString = '${hours}h';
        } else if (minutes > 0) {
          _timeString = '${minutes}m';
        } else {
          _timeString = '${seconds}s';
        }
      } else {
        // Full format for detail view
        if (years > 0) {
          final remainingMonths = ((days - (years * 365.25)) / 30.4375).floor();
          _timeString = '$years ${years == 1 ? 'year' : 'years'}';
          if (remainingMonths > 0) {
            _timeString += ', $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
          }
        } else if (months > 0) {
          final remainingDays = (days - (months * 30.4375)).floor();
          _timeString = '$months ${months == 1 ? 'month' : 'months'}';
          if (remainingDays > 0) {
            _timeString += ', $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
          }
        } else if (days > 0) {
          final remainingHours = hours - (days * 24);
          _timeString = '$days ${days == 1 ? 'day' : 'days'}';
          if (remainingHours > 0) {
            _timeString += ', $remainingHours ${remainingHours == 1 ? 'hour' : 'hours'}';
          }
        } else if (hours > 0) {
          final remainingMinutes = minutes - (hours * 60);
          _timeString = '$hours ${hours == 1 ? 'hour' : 'hours'}';
          if (remainingMinutes > 0) {
            _timeString += ', $remainingMinutes ${remainingMinutes == 1 ? 'minute' : 'minutes'}';
          }
        } else if (minutes > 0) {
          final remainingSeconds = seconds - (minutes * 60);
          _timeString = '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
          if (remainingSeconds > 0) {
            _timeString += ', $remainingSeconds ${remainingSeconds == 1 ? 'second' : 'seconds'}';
          }
        } else {
          _timeString = '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 12,
          color: widget.textColor ?? widget.textStyle?.color ?? Colors.blue,
        ),
        const SizedBox(width: 4),
        Text(
          _timeString,
          style: widget.textStyle ?? TextStyle(
            fontSize: 12,
            color: widget.textColor ?? Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}