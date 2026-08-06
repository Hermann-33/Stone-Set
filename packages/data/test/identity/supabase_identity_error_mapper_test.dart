import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/identity.dart';

void main() {
  test('maps rate limiting without exposing source details', () {
    final failure = mapSupabaseIdentityFailure(Exception('HTTP 429 secret detail'));

    expect(failure.code, IdentityErrorCode.rateLimited);
    expect(failure.toString(), isNot(contains('secret detail')));
  });

  test('maps transport errors to network unavailable', () {
    final failure = mapSupabaseIdentityFailure(Exception('Socket connection failed'));

    expect(failure.code, IdentityErrorCode.networkUnavailable);
  });
}
