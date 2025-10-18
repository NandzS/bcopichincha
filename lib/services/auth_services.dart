//Simulacion de un login
import '../models/user.dart';

class AuthService {
  // Simulacion de un usuario registrado
  final User _fakeUser = User(username: 'Gabriel', password: '123456');
  bool login(String username, String password) {
    return username == _fakeUser.username && password == _fakeUser.password;
  }
}