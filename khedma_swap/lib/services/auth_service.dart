import '../models/app_user.dart';

class AuthService {
  static final List<AppUser> _users = [
    AppUser(
      name: 'Test User',
      email: 'test@test.com',
      password: '123456',
    ),
  ];

  static AppUser? _currentUser;
  static AppUser? get currentUser => _currentUser;

  static void register({
    required String name,
    required String email,
    required String password,
  }) {
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      throw Exception('Email déjà utilisé');
    }

    final user = AppUser(name: name, email: email, password: password);
    _users.add(user);
  }

  static void login({
    required String email,
    required String password,
  }) {
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Utilisateur non trouvé'),
    );

    if (user.password != password) {
      throw Exception('Mot de passe incorrect');
    }

    _currentUser = user;
  }

  static void logout() {
    _currentUser = null;
  }
}
