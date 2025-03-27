/// Un mixin que proporciona métodos de conversión entre objetos de entidad y modelo.
///
/// El mixin `EntityConvertible` define dos métodos:
/// - `toEntity()`: convierte el objeto de implementación en un objeto de entidad.
/// - `fromEntity()`: convierte un objeto de entidad en el objeto de implementación.
///
/// Example usage:
/// ```dart
/// class UserEntity {
/// final String id;
/// final String name;
///
/// UserEntity(this.id, this.name);
/// }
///
/// class UserModel with EntityConvertible<UserEntity, UserModel> {
/// final String id;
/// final String name;
///
/// UserModel(this.id, this.name);
///
/// @override
/// UserEntity toEntity() {
/// return UserEntity(id, name);
/// }
///
/// @override
/// UserModel fromEntity(UserEntity entity) {
/// return UserModel(entity.id, entity.name);
/// }
/// }
/// ```
mixin EntityConvertible<I, O> {
  O toEntity();
  I fromEntity(O model) => throw UnimplementedError();
}
