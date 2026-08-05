abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(dynamic id);
  Future<T?> add(T item);
  Future<bool> updateItem(dynamic id, T item);
  Future<bool> deleteItem(dynamic id);
}
