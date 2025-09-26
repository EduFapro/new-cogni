import 'package:sqflite/sqflite.dart';

class Admin {
  final int? id;
  final String name;
  final String surname;
  final String birthDate;
  final String specialty;
  final String cpfOrNif;
  final String username;
  final String password;
  final bool firstLogin;
  final bool isAdmin;

  Admin({
    this.id,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.specialty,
    required this.cpfOrNif,
    required this.username,
    required this.password,
    this.firstLogin = true,
    this.isAdmin = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate,
      'specialty': specialty,
      'cpfOrNif': cpfOrNif,
      'username': username,
      'password': password,
      'firstLogin': firstLogin ? 1 : 0,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'] as int?,
      name: map['name'],
      surname: map['surname'],
      birthDate: map['birthDate'],
      specialty: map['specialty'],
      cpfOrNif: map['cpfOrNif'],
      username: map['username'],
      password: map['password'],
      firstLogin: (map['firstLogin'] as int) == 1,
      isAdmin: (map['isAdmin'] as int) == 1,
    );
  }
}

class AdminDao {
  final Database db;

  AdminDao(this.db);

  Future<int> insertAdmin(Admin admin) async {
    return await db.insert('admins', admin.toMap());
  }

  Future<Admin?> getFirstAdmin() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'admins',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Admin.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> hasAnyAdmin() async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM admins'),
    );
    return (count ?? 0) > 0;
  }
}
