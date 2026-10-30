import 'dart:typed_data';

import 'package:cake_wallet/entities/qr_scanner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ur/ur.dart';
import 'package:ur/ur_decoder.dart';
import 'package:ur/ur_encoder.dart';

void main() {
  test('frames in firmware order decode, including the uppercase first frame', () {
    final payload = Uint8List.fromList(List.generate(500, (i) => i % 256));
    final encoder = UREncoder(UR('xmr-keyimage', payload), 200);
    final frames = [for (var i = 0; i < 3; i++) encoder.nextPart()];
    expect(frames.first, startsWith('ur:xmr-keyimage/1-3/'));

    // firmware order: uppercase first frame, the rest, then the loop wraps
    final scanned = [frames.first.toUpperCase(), ...frames.skip(1), frames.first];
    expect(scanned.every(isURFrame), isTrue);

    final decoder = URDecoder();
    scanned.forEach(decoder.receivePart);
    expect(decoder.estimatedPercentComplete(), 1);
    expect(URQRToURQRData(scanned).count, 3);
  });

  test('non-UR content is left to the plain QR path', () {
    expect(isURFrame('{"version":0,"primaryAddress":"4..."}'), isFalse);
    expect(isURFrame('ur'), isFalse);
  });
}
