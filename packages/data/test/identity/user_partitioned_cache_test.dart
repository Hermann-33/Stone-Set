import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';

void main() {
  test('partitions values by authenticated user ID', () {
    final cache = UserPartitionedCache<String>()
      ..write(userId: 'user-a', key: 'profile', value: 'profile-a')
      ..write(userId: 'user-b', key: 'profile', value: 'profile-b');

    expect(cache.read(userId: 'user-a', key: 'profile'), 'profile-a');
    expect(cache.read(userId: 'user-b', key: 'profile'), 'profile-b');

    cache.clearUser('user-a');

    expect(cache.read(userId: 'user-a', key: 'profile'), isNull);
    expect(cache.read(userId: 'user-b', key: 'profile'), 'profile-b');
  });
}
