abstract interface class AuthDatasource {
  Future<String> login(String email, String password);
}
