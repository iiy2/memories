import 'dart:async';
import 'package:flutter/material.dart';

class LifeTimer extends StatefulWidget {
  final DateTime eventDate;
  final Color color;
  final Color textColor;

  const LifeTimer({
    Key? key,
    required this.eventDate,
    required this.color,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  State<LifeTimer> createState() => _LifeTimerState();
}

class _LifeTimerState extends State<LifeTimer> {
  late Timer _timer;
  String _timeString = 'Calculating...';

  @override
  void initState() {
    super.initState();
    
    // Calculate initially
    _calculateTimeSince();
    
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    
    // For debugging
    print('Updating timer: $seconds seconds elapsed');
    
    setState(() {
      if (years > 0) {
        final remainingMonths = ((days - (years * 365.25)) / 30.4375).floor();
        _timeString = '$years year${years != 1 ? 's' : ''}';
        if (remainingMonths > 0) {
          _timeString += ', $remainingMonths month${remainingMonths != 1 ? 's' : ''}';
        }
      } else if (months > 0) {
        final remainingDays = (days - (months * 30.4375)).floor();
        _timeString = '$months month${months != 1 ? 's' : ''}';
        if (remainingDays > 0) {
          _timeString += ', $remainingDays day${remainingDays != 1 ? 's' : ''}';
        }
      } else if (days > 0) {
        final remainingHours = hours - (days * 24);
        _timeString = '$days day${days != 1 ? 's' : ''}';
        if (remainingHours > 0) {
          _timeString += ', $remainingHours hour${remainingHours != 1 ? 's' : ''}';
        }
      } else if (hours > 0) {
        final remainingMinutes = minutes - (hours * 60);
        _timeString = '$hours hour${hours != 1 ? 's' : ''}';
        if (remainingMinutes > 0) {
          _timeString += ', $remainingMinutes minute${remainingMinutes != 1 ? 's' : ''}';
        }
      } else if (minutes > 0) {
        final remainingSeconds = seconds - (minutes * 60);
        _timeString = '$minutes minute${minutes != 1 ? 's' : ''}';
        if (remainingSeconds > 0) {
          _timeString += ', $remainingSeconds second${remainingSeconds != 1 ? 's' : ''}';
        }
      } else {
        _timeString = '$seconds second${seconds != 1 ? 's' : ''}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: widget.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: widget.textColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time Since Event',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _timeString,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: widget.textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}