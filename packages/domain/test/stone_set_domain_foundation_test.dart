import 'package:stone_set_domain/stone_set_domain.dart';
import 'package:test/test.dart';

void main() {
  test('identifies the domain foundation package', () {
    const foundation = StoneSetDomainFoundation();

    expect(foundation, isA<StoneSetDomainFoundation>());
    expect(StoneSetDomainFoundation.packageName, 'stone_set_domain');
  });
}
