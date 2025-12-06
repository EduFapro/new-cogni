class EvaluatorEntity {
  final int? evaluatorId;
  final String name;
  final String surname;
  final String email;
  final String birthDate;
  final String specialty;
  final String cpfOrNif;
  final String username;
  final String password;
  final bool firstLogin;
  final String? token;

  const EvaluatorEntity({
    this.evaluatorId,
    required this.name,
    required this.surname,
    required this.email,
    required this.birthDate,
    required this.specialty,
    required this.cpfOrNif,
    required this.username,
    required this.password,
    this.firstLogin = true,
    this.token,
  });
}
