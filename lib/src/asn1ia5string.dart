part of '../asn1lib.dart';

///
/// An ASN1 IA5 String.
///
/// A IA5String is a restricted character string type in the ASN.1 notation. We are treating it as ASCII data
///
class ASN1IA5String extends ASN1Object {
  /// The decoded string value
  late final String stringValue;

  ///
  /// Create an [ASN1IA5String] initialized with String value.
  /// Optionally override the tag
  ///
  ASN1IA5String(this.stringValue, {ASN1Tag? tag})
      : super(tag: tag ?? ASN1Tag(IA5_STRING_TYPE));

  ///
  /// Create an [ASN1IA5String] from an encoded list of bytes
  ///
  ASN1IA5String.fromBytes(
    super.bytes, {
    super.useX690,
  }) : super.fromBytes() {
    var octets = valueBytes();
    stringValue = ascii.decode(octets);
  }

  @override
  Uint8List _encode() {
    var octets = ascii.encode(stringValue);
    _valueByteLength = octets.length;
    _encodeHeader();
    _setValueBytes(octets);
    return _encodedBytes!;
  }

  @override
  String toString() => 'IA5String($stringValue)';
}
