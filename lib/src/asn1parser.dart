part of '../asn1lib.dart';

///
/// Parses ASN1 BER Encoded bytes to create ASN1 Objects
///
class ASN1Parser {
  /// stream of bytes to parse. This might be a view into a longer stream
  final Uint8List _bytes;
  final bool _relaxedParsing;
  final bool _useX690;

  /// Create a new parser for the stream of [_bytes]
  /// if [relaxedParsing] is true, dont throw an exception if we encounter
  /// unknown ASN1 objects. Just encode them as an ASN1Object.
  ASN1Parser(this._bytes, {bool relaxedParsing = false, bool useX690 = false})
      : _relaxedParsing = relaxedParsing,
        _useX690 = useX690;

  /// current position in the byte array
  int _position = 0;

  bool hasNext() {
    //return _position < ASN1Length.decodeLength(_bytes).length;
    return _position < _bytes.length;
  }

  ///
  /// Return the next ASN1Object in the stream
  ///
  ASN1Object nextObject({
    ASN1Tag? tag,
  }) {
    var lTag = ASN1Tag.decode(
      _bytes,
      offset: _position,
    ); // get current tag in stream

    if (lTag.value > 255 && !_useX690) {
      throw ASN1Exception('useX690 is off');
    }

    if (tag != null && lTag != tag) {
      throw ASN1Exception('$lTag is different than expected $tag');
    }

    // decode the length, and use this to create a view into the
    // byte stream that contains the next object
    var length = ASN1Length.decodeLength(
      _bytes.sublist(_position),
      useX690: _useX690,
    );
    var len = length.length + length.valueStartPosition;

    // create a view into the larger stream that includes the remaining un-parsed bytes
    var offset = _position + _bytes.offsetInBytes;
    var subBytes = Uint8List.view(_bytes.buffer, offset, len);
    //print("parser _bytes=${_bytes} position=${_position} len=$l  bytes=${hex(subBytes)}");

    final ASN1Object obj;

    switch (lTag.tagClass) {
      // get highest 2 bits - these are the type
      case TagClass.UNIVERSAL_CLASS:
        obj = _doPrimitive(lTag.value, subBytes);
        break;
      case TagClass.APPLICATION_CLASS:
        // LDAP tags are APPLICATION specific. Need to parse sequences
        if (lTag.isConstructed) {
          obj = ASN1Sequence.fromBytes(
            subBytes,
            useX690: _useX690,
          );
          break;
        }
        obj = ASN1Application.fromBytes(
          subBytes,
          useX690: _useX690,
        );
        break;
      case TagClass.PRIVATE_CLASS:
        obj = ASN1Private.fromBytes(
          subBytes,
          useX690: _useX690,
        );
        break;
      case TagClass.CONTEXT_SPECIFIC_CLASS:
        obj = ASN1Object.fromBytes(
          subBytes,
          useX690: _useX690,
        );
        break;
      default:
        throw UnimplementedError();
    }

    _position = _position + obj.totalEncodedByteLength;
    return obj;
  }

  ASN1Object _doPrimitive(int tag, Uint8List b) {
    //print("Primitive tag=${hex(tag)}");
    switch (tag) {
      case CONSTRUCTED_SEQUENCE_TYPE: // sequence
        return ASN1Sequence.fromBytes(
          b,
          useX690: _useX690,
        );

      case OCTET_STRING_TYPE:
        return ASN1OctetString.fromBytes(b);

      case UTF8_STRING_TYPE:
        return ASN1UTF8String.fromBytes(b);

      case IA5_STRING_TYPE:
        return ASN1IA5String.fromBytes(b);

      case INTEGER_TYPE:
      case ENUMERATED_TYPE:
        return ASN1Integer.fromBytes(b);

      case CONSTRUCTED_SET_TYPE:
        return ASN1Set.fromBytes(b);

      case BOOLEAN_TYPE:
        return ASN1Boolean.fromBytes(b);

      case OBJECT_IDENTIFIER:
        return ASN1ObjectIdentifier.fromBytes(b);

      case BIT_STRING_TYPE:
        return ASN1BitString.fromBytes(b);

      case NULL_TYPE:
        return ASN1Null.fromBytes(b);

      case NUMERIC_STRING_TYPE:
        return ASN1NumericString.fromBytes(b);

      case PRINTABLE_STRING_TYPE:
        return ASN1PrintableString.fromBytes(b);

      case UTC_TIME_TYPE:
        return ASN1UtcTime.fromBytes(b);

      case BMP_STRING_TYPE:
        return ASN1BMPString.fromBytes(b);

      case GENERALIZED_TIME:
        return ASN1GeneralizedTime.fromBytes(b);

      case TELETEXT_STRING:
        return ASN1TeletextString.fromBytes(b);

      default:
        if (_relaxedParsing) {
          return ASN1Object.fromBytes(b);
        }
        throw ASN1Exception(
            'Parser for tag $tag not implemented yet and relaxedParsing is off');
    }
  }
}
