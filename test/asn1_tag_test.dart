import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:test/test.dart';

void main() {
  // parameterizedTest1('Throw ASN1Exception when invalid tag', [
  //   [0x7F, ]
  // ] {});
  test('Test universal tag', () {
    final tag = ASN1Tag.descriptive(
      tagClass: TagClass.UNIVERSAL_CLASS,
      isConstructed: false,
      tagNumber: 0x17,
    );

    expect(tag.isUniversal, isTrue);
    expect(tag.isConstructed, isFalse);
    expect(tag.tagNumber, equals(0x17));
  });

  test('Test private tag with long form', () {
    final tag = ASN1Tag.descriptive(
      tagClass: TagClass.PRIVATE_CLASS,
      isConstructed: false,
      tagNumber: 0x1234,
    );

    expect(tag.isUniversal, isFalse);
    expect(tag.isConstructed, isFalse);

    expect(tag.typeBits, equals(0x1FA434));
    expect(tag.tagNumber, equals(0x1234));
  });

  test('Test private tag with long form from number', () {
    final tag = ASN1Tag(14656564);

    expect(tag.isUniversal, isFalse);
    expect(tag.isConstructed, isFalse);

    expect(tag.typeBits, equals(0x1FA434));
    expect(tag.tagNumber, equals(0x1234));
  });

  test('Test private tag with long form from array', () {
    final tag = ASN1Tag.decode(
      Uint8List.fromList(
        [0xDF, 0xA4, 0x34],
      ),
    );

    expect(tag.isUniversal, isFalse);
    expect(tag.isConstructed, isFalse);

    expect(tag.typeBits, equals(0x1FA434));
    expect(tag.tagNumber, equals(0x1234));
  });
}
