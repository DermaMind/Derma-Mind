import 'user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;

  const AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ??
        json['accessToken'] ??
        json['access_token'] ??
        json['jwt'] ??
        '';

    final userJson = (json['user'] ??
            json['userData'] ??
            json['data'] ??
            json) as Map<String, dynamic>;

    return AuthResponseModel(
      token: token.toString(),
      user: UserModel.fromJson(userJson),
    );
  }
}
