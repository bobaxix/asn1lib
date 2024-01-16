part of '../asn1lib.dart';

///
/// An enum is encoded as an Integer.
///
class ASN1Enumerated extends ASN1Integer {
  ASN1Enumerated(int i, {ASN1Tag? tag})
      : super(BigInt.from(i), tag: tag ?? ASN1Tag(ENUMERATED_TYPE));
}
