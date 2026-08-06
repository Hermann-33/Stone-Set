import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readdir, readFile} from 'node:fs/promises';
import path from 'node:path';
import test from 'node:test';

const repositoryRoot = path.resolve(import.meta.dirname, '..', '..');
const rankDirectory = path.join(repositoryRoot, 'assets', 'ranks');
const expectedRanks = [
  ['Bronze I', 0, '01_bronze_i.png'],
  ['Bronze II', 100, '02_bronze_ii.png'],
  ['Bronze III', 200, '03_bronze_iii.png'],
  ['Silver I', 325, '04_silver_i.png'],
  ['Silver II', 475, '05_silver_ii.png'],
  ['Silver III', 650, '06_silver_iii.png'],
  ['Gold I', 825, '07_gold_i.png'],
  ['Gold II', 1025, '08_gold_ii.png'],
  ['Gold III', 1250, '09_gold_iii.png'],
  ['Platinum I', 1500, '10_platinum_i.png'],
  ['Platinum II', 1775, '11_platinum_ii.png'],
  ['Platinum III', 2075, '12_platinum_iii.png'],
  ['Diamond I', 2400, '13_diamond_i.png'],
  ['Diamond II', 2750, '14_diamond_ii.png'],
  ['Diamond III', 3125, '15_diamond_iii.png'],
  ['Elite', 3525, '16_elite.png'],
  ['Champion', 3950, '17_champion.png'],
  ['Apex', 4400, '18_apex.png'],
  ['Prodigy', 4900, '19_prodigy.png'],
  ['Adonis', 5500, '20_adonis.png'],
];

test('rank manifest and canonical PNG files match stone-set-ranks-v1', async () => {
  const manifest = JSON.parse(await readFile(path.join(rankDirectory, 'manifest.json'), 'utf8'));

  assert.equal(manifest.schemaVersion, 1);
  assert.equal(manifest.rankConfiguration, 'rank-v6');
  assert.equal(manifest.assetSet, 'stone-set-ranks-v1');
  assert.equal(manifest.assets.length, expectedRanks.length);

  const manifestFilenames = new Set();
  for (const [index, expected] of expectedRanks.entries()) {
    const asset = manifest.assets[index];
    const [rank, minimumRR, filename] = expected;
    assert.deepEqual(
      [asset.order, asset.rank, asset.minimumRR, asset.filename],
      [index + 1, rank, minimumRR, filename],
    );
    assert.equal(manifestFilenames.has(filename), false, `duplicate manifest filename: ${filename}`);
    manifestFilenames.add(filename);

    const bytes = await readFile(path.join(rankDirectory, filename));
    assert.deepEqual([...bytes.subarray(0, 8)], [137, 80, 78, 71, 13, 10, 26, 10]);
    assert.equal(bytes.readUInt32BE(16), 256, `${filename} width`);
    assert.equal(bytes.readUInt32BE(20), 256, `${filename} height`);
    assert.equal(bytes[25], 6, `${filename} must be RGBA`);
    assert.equal(asset.dimensions.width, 256);
    assert.equal(asset.dimensions.height, 256);
    assert.equal(asset.alpha, true);
    assert.equal(createHash('sha256').update(bytes).digest('hex'), asset.sha256);
  }

  const pngFiles = (await readdir(rankDirectory)).filter((name) => name.endsWith('.png')).sort();
  assert.deepEqual(pngFiles, expectedRanks.map((entry) => entry[2]));
});
