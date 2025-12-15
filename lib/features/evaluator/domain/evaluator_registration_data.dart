class EvaluatorRegistrationData {
  final String? id; // Optional ID for synchronization
  final String name;
  final String surname;
  final String email;
  final String birthDate;
  final String specialty;
  final String cpf;
  final String username;
  final String password;
  final bool isAdmin;
  final bool firstLogin;

  EvaluatorRegistrationData({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.birthDate,
    required this.specialty,
    required this.cpf,
    required this.username,
    required this.password,
    this.isAdmin = false,
    this.firstLogin = true,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'surname': surname,
    'email': email,
    'birthDate': birthDate,
    'specialty': specialty,
    'cpfOrNif': cpf,
    'username': username,
    'password': password,
    'isAdmin': isAdmin,
    'firstLogin': firstLogin,
  };

  // For sending to backend API (same as toMap)
  Map<String, dynamic> toJson() => toMap();

  // For receiving from backend API
  factory EvaluatorRegistrationData.fromJson(Map<String, dynamic> json) {
    return EvaluatorRegistrationData(
      id: json['id'] as String?,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      birthDate: json['birthDate'] as String,
      specialty: json['specialty'] as String,
      cpf: json['cpfOrNif'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
      firstLogin: json['firstLogin'] as bool? ?? true,
    );
  }
}
