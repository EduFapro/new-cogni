class EvaluatorRegistrationData {
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
}
