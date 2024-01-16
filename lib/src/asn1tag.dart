part of '../asn1lib.dart';

class ASN1Tag {
  ASN1Tag(int value) {
    var index = 0;
    var currentByte = (value >> (8 * index)) & 0xFF;
    final bytes = <int>[];

    while (index == 0 || currentByte != 0) {
      bytes.insert(0, currentByte);
      currentByte = (value >> (8 * ++index)) & 0xFF;
    }

    _bytes = Uint8List.fromList(bytes);
    throwIfInvalid(_bytes);
  }

  ASN1Tag.short({
    required TagClass tagClass,
    required bool isConstructed,
    required int tagNumber,
  }) {
    RangeError.range(tagNumber, 0, 0x1F);

    final value = tagClass.value | (isConstructed ? 1 : 0) << 5 | tagNumber;
    _bytes = Uint8List.fromList(
      [value],
    );
  }

  factory ASN1Tag.descriptive({
    required TagClass tagClass,
    required bool isConstructed,
    required int tagNumber,
  }) {
    if (tagClass == TagClass.UNIVERSAL_CLASS && tagNumber >= 0x1F) {
      throw ASN1Exception('Tag number cannot be gt 0x1F for UNIVERSAL class');
    }

    if (tagNumber < 0x1F) {
      return ASN1Tag.short(
        tagClass: tagClass,
        isConstructed: isConstructed,
        tagNumber: tagNumber,
      );
    }

    final bytes = <int>[tagNumber & 0x7F];

    var value = tagNumber >> 7;

    while (value != 0) {
      bytes.insert(0, (value & 0x7F) | 0x80);
      value >>= 7;
    }

    final firstByte = tagClass.value | (isConstructed ? 1 : 0) << 5 | 0x1F;
    return ASN1Tag.decode(
      Uint8List.fromList(
        [firstByte, ...bytes],
      ),
    );
  }

  ASN1Tag.decode(Uint8List encoded, {int offset = 0}) {
    final isLongForm = encoded[offset] & 0x1F == 0x1F;

    if (!isLongForm) {
      _bytes = Uint8List.sublistView(encoded, offset, offset + 1);
    } else {
      for (var i = offset + 1; i < encoded.lengthInBytes; ++i) {
        if (encoded[i] & 0x80 != 0x80) {
          _bytes = Uint8List.sublistView(encoded, offset, i + 1);
          break;
        }
      }
    }

    throwIfInvalid(_bytes);
  }

  late final Uint8List _bytes;

  static void throwIfInvalid(
    Uint8List encoded, {
    int offset = 0,
  }) {
    final isLongForm = (encoded[offset] & 0x1F) == 0x1F;

    if (!isLongForm) {
      if (encoded.length > 1) {
        throw ArgumentError('Invalid tag value');
      } else {
        return;
      }
    }

    final isLastCorrect = (encoded[encoded.length + offset - 1] & 0x80) != 0x80;

    if (!isLastCorrect) {
      throw ArgumentError('Invalid tag value');
    }

    final internal = encoded
        .skip(offset + 1) //
        .take(encoded.length - 2);

    final isCorrect = internal.isEmpty || internal.every((e) => e & 0x80 != 0);

    if (!isCorrect) {
      throw ArgumentError('Invalid tag value');
    }
  }

  /// Tag class of current class, example `BIT STRING`
  TagClass get tagClass => //
      TagClass.values.firstWhere((e) => (_bytes.first & 0xC0) == e.value);

  /// Numeric value of tag
  ///
  /// Example:
  /// ```
  /// final tag = ASN1Tag(0x7F21);
  /// print(tag.value.toRadixString(16)); // f721
  /// ```
  int get value => //
      _bytes.fold(0, (p, n) => p = (p << 8) + n);

  /// The contents octets contain 0, 1, or more encodings.
  bool get isConstructed => //
      (_bytes.first & 0x20) != 0;

  /// The type is native to ASN.1
  bool get isUniversal => //
      tagClass == TagClass.UNIVERSAL_CLASS;

  /// The type is only valid for one specific application
  bool get isApplication => //
      tagClass == TagClass.APPLICATION_CLASS;

  /// Meaning of this type depends on the context (such as within a sequence, set or choice)
  bool get isContextSpecific => //
      tagClass == TagClass.CONTEXT_SPECIFIC_CLASS;

  /// Defined in private specifications
  bool get isPrivate => //
      tagClass == TagClass.PRIVATE_CLASS;

  /// Total length of tag in bytes
  int get length => //
      _bytes.length;

  /// Identifier of encoding
  ///
  /// Example:
  /// ```dart
  /// final tag = ASN1Tag(0x7F21);
  /// print(tag.typeBits.toRadixString(16)); // 1f21
  /// ```
  int get typeBits {
    var result = _bytes.first & 0x1F;

    for (final e in _bytes.skip(1)) {
      result = (result << 8) | e;
    }

    return result;
  }

  /// Return number of tag in Big-Endian order with X.690 tag octets encoding
  ///
  /// Example:
  /// ```dart
  /// final tag = ASN1Tag(0x7F8121);
  /// final tagHex = tag.tagNumber.toRadixString(16);
  /// assert(tagHex, equals(0x121)); // 121
  /// ```
  int get tagNumber {
    if (!isLongType) {
      return _bytes.first & 0x1F;
    } else {
      var result = 0;
      for (final e in bytes.skip(1)) {
        result = (result << 7) | (e & 0x7F);
      }
      return result;
    }
  }

  bool get isLongType => //
      _bytes.first & 0x1F == 0x1F;

  /// Content of encoding (tag + length + data)
  Uint8List get bytes => //
      _bytes;

  String toRadixString([int radix = 10]) {
    return value.toRadixString(radix);
  }

  @override
  String toString() {
    return 'ASN1Tag(class=$tagClass, '
        'isConstructed=$isConstructed, '
        'number=${tagNumber.toRadixString(16)})';
  }

  @override
  bool operator ==(covariant ASN1Tag other) {
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
