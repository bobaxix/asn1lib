part of '../asn1lib.dart';

///
/// An ASN1 Null Object
///
class ASN1Null extends ASN1Object {
  @override
  Uint8List get _encodedBytes => Uint8List.fromList([...tag.bytes, 0x00]);

  ASN1Null({ASN1Tag? tag}) : super(tag: tag ?? ASN1Tag(NULL_TYPE));

  ASN1Null.fromBytes(
    super.bytes, {
    super.useX690,
  }) : super.fromBytes();

  @override
  Uint8List _encode() => Uint8List.fromList([...tag.bytes, 0x00]);
}
