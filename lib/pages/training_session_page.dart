// lib/pages/training_session_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_log_model.dart';
import './training_summary_page.dart';
import '../services/database_helper.dart';

class TrainingSessionPage extends StatefulWidget {
  final Exercise exercise;
  final int totalSets;
  final int restTimeInSeconds;
  final BodyPart bodyPart;

  const TrainingSessionPage({
    super.key,
    required this.exercise,
    required this.totalSets,
    required this.restTimeInSeconds,
    required this.bodyPart,
  });

  @override
  State<TrainingSessionPage> createState() => _TrainingSessionPageState();
}

class _TrainingSessionPageState extends State<TrainingSessionPage> {
  Timer? _timer;
  int _currentSet = 1;
  int _countdownSeconds = 5;
  bool _isResting = false;
  bool _isPreparing = true; // 【修改】用一個更精確的變數名替換 _isStarted

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    // 【修正】不再設定 _isStarted，由 initState 和 _finishSet 控制狀態
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          // 倒數結束後，無論是準備還是休息，都將對應的狀態設為 false
          if (_isPreparing) {
            _isPreparing = false;
          }
          if (_isResting) {
            _isResting = false;
          }
        });
      }
    });
  }
  
  // 【新增】跳過休息的方法
  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
    });
  }

  void _finishSet() async {
    if (_currentSet < widget.totalSets) {
      setState(() {
        _isResting = true;
        _currentSet++;
        _countdownSeconds = widget.restTimeInSeconds;
      });
      _startCountdown();
    } else {
      final workoutLog = WorkoutLog(
        exerciseName: widget.exercise.name,
        totalSets: widget.totalSets,
        completedAt: DateTime.now(),
        bodyPart: widget.bodyPart,
      );

      await DatabaseHelper.instance.insertWorkoutLog(workoutLog);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TrainingSummaryPage(log: workoutLog),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String statusText;
    if (_isPreparing) {
      statusText = '準備開始...';
    } else if (_isResting) {
      statusText = '休息中';
    } else {
      statusText = '第 $_currentSet / ${widget.totalSets} 組';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusText,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 20),
            if (_isPreparing || _isResting)
              Text(
                '$_countdownSeconds',
                style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold),
              )
            else
              const Text(
                '訓練中',
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            
            // 【修改】調整佈局，讓按鈕區塊稍微上移
            const Expanded(child: SizedBox()), // 佔用剩餘空間

            // --- 按鈕區塊 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // 【修改】用 Row 來容納兩個按鈕
              child: Row(
                children: [
                  // 如果正在休息，顯示「跳過休息」按鈕
                  if (_isResting)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _skipRest,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('跳過休息', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  // 如果正在休息且有跳過按鈕，加入間距
                  if (_isResting) const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isPreparing || _isResting) ? null : _finishSet,
                    
                      style: ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 20),
  backgroundColor: Theme.of(context).colorScheme.primary,
  // 【修改】將 withOpacity 換成 withAlpha，更現代的寫法
  disabledBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(77), // 30% 透明度
  disabledForegroundColor: Colors.white.withAlpha(128), // 50% 透明度
),
                      child: Text(
                        _isResting ? '休息中...' : '完成一組',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 【修改】在按鈕下方加入一些空間，讓它不會貼底
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}