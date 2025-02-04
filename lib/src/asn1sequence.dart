part of '../asn1lib.dart';

///
/// Represents a ASN1 BER encoded sequence.
///
/// A sequence is a container for other ASN1 objects
/// Objects are serialized sequentially to the stream
///
class ASN1Sequence extends ASN1Object {
  List<ASN1Object> elements = <ASN1Object>[];

  ///
  /// Create a sequence fromt the byte array [bytes].
  ///
  /// Note that bytes array b could be longer than the actual encoded sequence - in which case
  /// we ignore any remaining bytes.
  ///
  ASN1Sequence.fromBytes(
    super.bytes, {
    bool useX690 = false,
  }) : super.fromBytes(useX690: useX690) {
    if (tag.isUniversal && !isSequence(tag)) {
      throw ASN1Exception('The tag $tag does not look like a sequence type');
    }
    _decodeSeq(
      useX690: useX690,
    );
  }

  ///
  /// Create a new empty ASN1 Sequence. Optionally override the default tag
  ///
  ASN1Sequence({ASN1Tag? tag})
      : super(tag: tag ?? ASN1Tag(CONSTRUCTED_SEQUENCE_TYPE));

  ///
  /// Add an [ASN1Object] to the sequence. Objects will be serialized to BER in the order they were added
  ///
  void add(ASN1Object o) {
    elements.add(o);
  }

  @override
  Uint8List _encode() {
    _valueByteLength = _childLength();
    super._encodeHeader();
    var i = _valueStartPosition;
    // encode each element
    for (var obj in elements) {
      var b = obj.encodedBytes;
      encodedBytes.setRange(i, i + b.length, b);
      i += b.length;
    }
    return _encodedBytes!;
  }

  ///
  /// Calculate encoded length of all children
  ///
  int _childLength() {
    var l = 0;
    for (var obj in elements) {
      l += obj._encode().length;
    }
    return l;
  }

  void _decodeSeq({
    bool useX690 = false,
  }) {
    /*
      var l = ASN1Length.decodeLength(encodedBytes);
      this.valueStartPosition = l.valueStartPosition;
      this.valueByteLength = l.length;
      // now we know our value - but we need to scan for further embedded elements...
       */
    var parser = ASN1Parser(valueBytes(), useX690: useX690);

    while (parser.hasNext()) {
      final nextObject = parser.nextObject();
      elements.add(nextObject);
    }
  }

  @override
  String toString() {
    var b = StringBuffer('Seq(tag=${tag.toRadixString(16)})[');
    for (var e in elements) {
      b.write(e.toString());
      b.write(' ');
    }
    b.write(']');
    return b.toString();
  }
}
