// lib/models/user_model.dart

// 【移除】enum FitnessLevel

class User {
  final int? id;
  final String account;
  final String password;
  final String height;
  final String weight;
  final String age;
  final String bmi;
  final String? fat;
  final String? gender;
  final String? bmr;
  final String? goalWeight;
  // 【移除】final String? fitnessLevel;

  User({
    this.id,
    required this.account,
    required this.password,
    required this.height,
    required this.weight,
    required this.age,
    required this.bmi,
    this.fat,
    this.gender,
    this.bmr,
    this.goalWeight,
    // 【移除】this.fitnessLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account': account,
      'password': password,
      'height': height,
      'weight': weight,
      'age': age,
      'bmi': bmi,
      'fat': fat,
      'gender': gender,
      'bmr': bmr,
      'goalWeight': goalWeight,
      // 【移除】'fitnessLevel': fitnessLevel,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      account: map['account'],
      password: map['password'],
      height: map['height'],
      weight: map['weight'],
      age: map['age'],
      bmi: map['bmi'],
      fat: map['fat'],
      gender: map['gender'],
      bmr: map['bmr'],
      goalWeight: map['goalWeight'],
      // 【移除】fitnessLevel: map['fitnessLevel'],
    );
  }

  User copyWith({
    int? id,
    String? account,
    String? password,
    String? height,
    String? weight,
    String? age,
    String? bmi,
    String? fat,
    String? gender,
    String? bmr,
    String? goalWeight,
    // 【移除】String? fitnessLevel,
  }) {
    return User(
      id: id ?? this.id,
      account: account ?? this.account,
      password: password ?? this.password,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      bmi: bmi ?? this.bmi,
      fat: fat ?? this.fat,
      gender: gender ?? this.gender,
      bmr: bmr ?? this.bmr,
      goalWeight: goalWeight ?? this.goalWeight,
      // 【移除】fitnessLevel: fitnessLevel ?? this.fitnessLevel,
    );
  }
}