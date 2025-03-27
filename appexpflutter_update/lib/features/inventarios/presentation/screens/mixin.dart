mixin VerificarCampos {
  bool isNotEmptyOrWhitespace(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
