import 'package:cake_wallet/view_model/restore/restore_mode.dart';
import 'package:cake_wallet/view_model/restore/restore_wallet.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:flutter_test/flutter_test.dart';

RestoredWallet wallet(
  WalletRestoreMode mode, {
  WalletType type = WalletType.monero,
  int? height,
  String? seed,
}) =>
    RestoredWallet(
        restoreMode: mode, type: type, address: null, height: height, mnemonicSeed: seed);

void main() {
  test('monero keys need a height unless the QR has a real one', () {
    expect(wallet(WalletRestoreMode.keys, height: 0).needsHeight, isTrue);
    expect(wallet(WalletRestoreMode.keys).needsHeight, isTrue);
    expect(wallet(WalletRestoreMode.keys, height: 3000000).needsHeight, isFalse);
  });

  test('monero seeds need a height unless the QR has a real one', () {
    expect(wallet(WalletRestoreMode.seed, seed: 'not a polyseed').needsHeight, isTrue);
    expect(
      wallet(WalletRestoreMode.seed, height: 3000000, seed: 'not a polyseed').needsHeight,
      isFalse,
    );
  });

  test('other wallet types are unaffected', () {
    expect(
        wallet(WalletRestoreMode.keys, type: WalletType.bitcoin, height: 0).needsHeight, isFalse);
  });
}
