part of '../asn1lib.dart';

///
/// An ASN1Set.
///
class ASN1Set extends ASN1Object {
  Set<ASN1Object> elements = <ASN1Object>{};

  ///
  /// Create a set from the bytes
  ///
  /// Note that bytes could be longer than the actual sequence - in which case we would ignore any remaining bytes
  ///
  ASN1Set.fromBytes(
    super.bytes, {
    super.useX690,
  }) : super.fromBytes() {
    if (!isSet(tag)) {
      throw ASN1Exception('The tag $tag does not look like a set type');
    }
    _decodeSet();
  }

  ASN1Set({ASN1Tag? tag}) : super(tag: tag ?? ASN1Tag(CONSTRUCTED_SET_TYPE));

  ///
  /// Add an element to the set
  ///
  void add(ASN1Object o) {
    elements.add(o);
  }

  @override
  Uint8List _encode() {
    _valueByteLength = _childLength();
    //super._encode();

    super._encodeHeader();
    var i = _valueStartPosition;
    for (var obj in elements) {
      var b = obj.encodedBytes;
      encodedBytes.setRange(i, i + b.length, b);
      i += b.length;
    }
    return _encodedBytes!;
  }

  ///
  /// TODO: Merge with Sequence code
  ///
  int _childLength() {
    var l = 0;
    for (var obj in elements) {
      obj._encode();
      l += obj.encodedBytes.length;
    }
    return l;
  }

  void _decodeSet() {
    /*
      var l = ASN1Length.decodeLength(encodedBytes);
      this.valueStartPosition = l.valueStartPosition;
      this.valueByteLength = l.length;
      // now we know our value - but we need to scan for further embedded elements...
       */
    var parser = ASN1Parser(valueBytes());

    while (parser.hasNext()) {
      elements.add(parser.nextObject());
    }
  }

  @override
  String toString() {
    var b = StringBuffer('Set[');
    for (var e in elements) {
      b.write(e.toString());
      b.write(' ');
    }
    b.write(']');
    return b.toString();
  }
}
