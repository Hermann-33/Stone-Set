import 'package:flutter/foundation.dart';

import '../theme/stone_set_theme.dart';

/// Closed, presentation-only rank identity.
///
/// This is deliberately not the future authoritative database rank ID.
enum StoneSetRankPresentationId {
  bronzeI('bronze_i'),
  bronzeII('bronze_ii'),
  bronzeIII('bronze_iii'),
  silverI('silver_i'),
  silverII('silver_ii'),
  silverIII('silver_iii'),
  goldI('gold_i'),
  goldII('gold_ii'),
  goldIII('gold_iii'),
  platinumI('platinum_i'),
  platinumII('platinum_ii'),
  platinumIII('platinum_iii'),
  diamondI('diamond_i'),
  diamondII('diamond_ii'),
  diamondIII('diamond_iii'),
  elite('elite'),
  champion('champion'),
  apex('apex'),
  prodigy('prodigy'),
  adonis('adonis');

  const StoneSetRankPresentationId(this.wireId);
  final String wireId;
}

@immutable
class StoneSetRankAsset {
  const StoneSetRankAsset({
    required this.id,
    required this.displayName,
    required this.order,
    required this.minimumRankRating,
    required this.fileName,
    required this.family,
  });

  final StoneSetRankPresentationId id;
  final String displayName;
  final int order;
  final int minimumRankRating;
  final String fileName;
  final StoneSetRankFamily family;

  /// Runtime asset key verified for the mobile app's root-asset registration.
  String get assetKey => '.dart_tool/stone_set_assets/ranks/$fileName';
}

abstract final class StoneSetRankAssets {
  static const all = <StoneSetRankAsset>[
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.bronzeI,
      displayName: 'Bronze I',
      order: 1,
      minimumRankRating: 0,
      fileName: '01_bronze_i.png',
      family: StoneSetRankFamily.bronze,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.bronzeII,
      displayName: 'Bronze II',
      order: 2,
      minimumRankRating: 100,
      fileName: '02_bronze_ii.png',
      family: StoneSetRankFamily.bronze,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.bronzeIII,
      displayName: 'Bronze III',
      order: 3,
      minimumRankRating: 200,
      fileName: '03_bronze_iii.png',
      family: StoneSetRankFamily.bronze,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.silverI,
      displayName: 'Silver I',
      order: 4,
      minimumRankRating: 325,
      fileName: '04_silver_i.png',
      family: StoneSetRankFamily.silver,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.silverII,
      displayName: 'Silver II',
      order: 5,
      minimumRankRating: 475,
      fileName: '05_silver_ii.png',
      family: StoneSetRankFamily.silver,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.silverIII,
      displayName: 'Silver III',
      order: 6,
      minimumRankRating: 650,
      fileName: '06_silver_iii.png',
      family: StoneSetRankFamily.silver,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.goldI,
      displayName: 'Gold I',
      order: 7,
      minimumRankRating: 825,
      fileName: '07_gold_i.png',
      family: StoneSetRankFamily.gold,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.goldII,
      displayName: 'Gold II',
      order: 8,
      minimumRankRating: 1025,
      fileName: '08_gold_ii.png',
      family: StoneSetRankFamily.gold,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.goldIII,
      displayName: 'Gold III',
      order: 9,
      minimumRankRating: 1250,
      fileName: '09_gold_iii.png',
      family: StoneSetRankFamily.gold,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.platinumI,
      displayName: 'Platinum I',
      order: 10,
      minimumRankRating: 1500,
      fileName: '10_platinum_i.png',
      family: StoneSetRankFamily.platinum,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.platinumII,
      displayName: 'Platinum II',
      order: 11,
      minimumRankRating: 1775,
      fileName: '11_platinum_ii.png',
      family: StoneSetRankFamily.platinum,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.platinumIII,
      displayName: 'Platinum III',
      order: 12,
      minimumRankRating: 2075,
      fileName: '12_platinum_iii.png',
      family: StoneSetRankFamily.platinum,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.diamondI,
      displayName: 'Diamond I',
      order: 13,
      minimumRankRating: 2400,
      fileName: '13_diamond_i.png',
      family: StoneSetRankFamily.diamond,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.diamondII,
      displayName: 'Diamond II',
      order: 14,
      minimumRankRating: 2750,
      fileName: '14_diamond_ii.png',
      family: StoneSetRankFamily.diamond,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.diamondIII,
      displayName: 'Diamond III',
      order: 15,
      minimumRankRating: 3125,
      fileName: '15_diamond_iii.png',
      family: StoneSetRankFamily.diamond,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.elite,
      displayName: 'Elite',
      order: 16,
      minimumRankRating: 3525,
      fileName: '16_elite.png',
      family: StoneSetRankFamily.elite,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.champion,
      displayName: 'Champion',
      order: 17,
      minimumRankRating: 3950,
      fileName: '17_champion.png',
      family: StoneSetRankFamily.champion,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.apex,
      displayName: 'Apex',
      order: 18,
      minimumRankRating: 4400,
      fileName: '18_apex.png',
      family: StoneSetRankFamily.apex,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.prodigy,
      displayName: 'Prodigy',
      order: 19,
      minimumRankRating: 4900,
      fileName: '19_prodigy.png',
      family: StoneSetRankFamily.prodigy,
    ),
    StoneSetRankAsset(
      id: StoneSetRankPresentationId.adonis,
      displayName: 'Adonis',
      order: 20,
      minimumRankRating: 5500,
      fileName: '20_adonis.png',
      family: StoneSetRankFamily.adonis,
    ),
  ];

  static final Map<StoneSetRankPresentationId, StoneSetRankAsset> _byId =
      <StoneSetRankPresentationId, StoneSetRankAsset>{
        for (final asset in all) asset.id: asset,
      };

  static StoneSetRankAsset byId(StoneSetRankPresentationId id) => _byId[id]!;

  static StoneSetRankAsset parse(String wireId) {
    for (final asset in all) {
      if (asset.id.wireId == wireId) return asset;
    }
    throw ArgumentError.value(wireId, 'wireId', 'Unknown presentation-only rank ID');
  }
}
