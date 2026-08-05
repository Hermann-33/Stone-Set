import 'package:stone_set_domain/stone_set_domain.dart';

/// Foundation-only repository boundary with no product or persistence API.
abstract interface class StoneSetFoundationRepository {
  StoneSetDomainFoundation get domainFoundation;
}
