part of '../asn1lib.dart';

// Sere https://luca.ntop.org/Teaching/Appunti/asn1.html
// tag bytes for various ASN1 BER objects

// Value to AND against to test for the constructed bit (sequence, set)
// This is bit 6
// Binary 0010 0000
const int CONSTRUCTED_BIT = 0x20;

const int BOOLEAN_TYPE = 0x01;
const int INTEGER_TYPE = 0x02;
const int BIT_STRING_TYPE = 0x03;
const int OCTET_STRING_TYPE = 0x04;
const int NULL_TYPE = 0x05;
const int OBJECT_DESCRIPTOR_TYPE = 0x07;
const int ENUMERATED_TYPE = 0x0A;
const int UTF8_STRING_TYPE = 0x0C;
const int NUMERIC_STRING_TYPE = 0x12;
const int PRINTABLE_STRING_TYPE = 0x13;
const int IA5_STRING_TYPE = 0x16;
const int UTC_TIME_TYPE = 0x17;
const int BMP_STRING_TYPE = 0x1e;
// SET and SEQUENCE TYPES include the constructed bit set.
// 0001 0000
const int SEQUENCE_TYPE = 0x10;
const int SET_TYPE = 0x11;
const int CONSTRUCTED_SEQUENCE_TYPE =
    CONSTRUCTED_BIT | SEQUENCE_TYPE; // 0x10 + constructed bit
const int CONSTRUCTED_SET_TYPE =
    CONSTRUCTED_BIT | SET_TYPE; // 0x11 + constructed bit
const int OBJECT_IDENTIFIER = 0x06;
const int GENERALIZED_TIME = 0x18;
const int TELETEXT_STRING = 0x14;

const int BOOLEAN_TRUE_VALUE = 0xff;
const int BOOLEAN_FALSE_VALUE = 0x00;

// application-specific tag bytes for SNMP protocol

const int IP_ADDRESS = 0x40;

// These are the patterns to AND against to test
// for the tag class.
// Generic application type.
// 0100 0000
enum TagClass {
  PRIVATE_CLASS(0xC0),
  CONTEXT_SPECIFIC_CLASS(0x80),
  APPLICATION_CLASS(0x40),
  UNIVERSAL_CLASS(0x00);

  const TagClass(this.value);

  final int value;
}

// Utilities to test the tag

// primitive set or sequence
bool isSet(ASN1Tag tag) => tag.isConstructed && tag.typeBits == SET_TYPE;
bool isSequence(ASN1Tag tag) =>
    tag.isConstructed && tag.typeBits == SEQUENCE_TYPE;
