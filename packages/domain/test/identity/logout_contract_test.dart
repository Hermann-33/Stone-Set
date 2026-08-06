import 'package:stone_set_domain/identity.dart';
import 'package:test/test.dart';

void main() {
  test('foundation reports no unsynchronized feature work', () async {
    const work = NoUnsynchronizedPrivateWork();

    expect(await work.hasUnsynchronizedPrivateWork('synthetic-user'), isFalse);
  });
}
