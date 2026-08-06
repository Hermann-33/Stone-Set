import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/stone_set_domain.dart';

void main() {
  test('permits a foundation-only repository implementation', () {
    const repository = _FoundationRepository();

    expect(repository, isA<StoneSetFoundationRepository>());
    expect(repository.domainFoundation, isA<StoneSetDomainFoundation>());
  });
}

final class _FoundationRepository implements StoneSetFoundationRepository {
  const _FoundationRepository();

  @override
  StoneSetDomainFoundation get domainFoundation => const StoneSetDomainFoundation();
}
