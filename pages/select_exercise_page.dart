// lib/pages/select_exercise_page.dart

import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import './exercise_setup_page.dart';

class SelectExercisePage extends StatefulWidget {
  final BodyPart bodyPart;
  const SelectExercisePage({super.key, required this.bodyPart});

  @override
  State<SelectExercisePage> createState() => _SelectExercisePageState();
}

class _SelectExercisePageState extends State<SelectExercisePage> {
  // 用來控制輸入框的 Controller
  final TextEditingController _exerciseNameController = TextEditingController();
  // 用來驗證表單的 Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    // 檢查輸入是否有效
    if (_formKey.currentState!.validate()) {
      // 建立一個自訂的 Exercise 物件
      final customExercise = Exercise(
        name: _exerciseNameController.text.trim(),
        // description 和 imagePath 我們可以不給，因為它們現在是選填的
      );

      // 導航到下一個設定頁面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseSetupPage(
            exercise: customExercise,
            bodyPart: widget.bodyPart,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得部位的中文名稱
    final bodyPartName = widget.bodyPart.displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text('選擇 $bodyPartName 動作'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '請輸入您要訓練的動作名稱',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _exerciseNameController,
                decoration: const InputDecoration(
                  labelText: '例如：啞鈴彎舉',
                ),
                // 驗證規則：不能為空
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入動作名稱';
                  }
                  return null;
                },
                // 讓鍵盤的「完成」按鈕可以直接觸發下一步
                onFieldSubmitted: (_) => _goToNextStep(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _goToNextStep,
                child: const Text('下一步'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
