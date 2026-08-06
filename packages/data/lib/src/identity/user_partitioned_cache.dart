final class UserPartitionedCache<T> {
  final Map<String, Map<String, T>> _values = <String, Map<String, T>>{};

  T? read({required String userId, required String key}) => _values[userId]?[key];

  void write({required String userId, required String key, required T value}) {
    _values.putIfAbsent(userId, () => <String, T>{})[key] = value;
  }

  void clearUser(String userId) => _values.remove(userId);

  void clearAll() => _values.clear();
}
