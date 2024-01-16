part of '../asn1lib.dart';

// Represent an ASN1 APPLICATION type. An Application is a
// custom ASN1 object that delegates the interpretation to the
// consumer.
class ASN1Application extends ASN1Object {
  ASN1Application({ASN1Tag? tag})
      : super(tag: tag ?? ASN1Tag(TagClass.APPLICATION_CLASS.value));

  ASN1Application.fromBytes(
    super.bytes, {
    super.useX690,
  }) : super.fromBytes() {
    // check that this really is an application type
    if (!tag.isApplication) {
      throw ASN1Exception('tag $tag is not an ASN1 Application class');
    }
  }
}

// Represent an ASN1 PRIVATE type. This is a
// custom ASN1 object that delegates the interpretation to the
// consumer.
class ASN1Private extends ASN1Object {
  ASN1Private({ASN1Tag? tag})
      : super(tag: tag ?? ASN1Tag(TagClass.PRIVATE_CLASS.value));

  ASN1Private.fromBytes(
    super.bytes, {
    super.useX690,
  }) : super.fromBytes() {
    // check that this really is an Private type
    if (!tag.isPrivate) {
      throw ASN1Exception('tag $tag is not an ASN1 Private class');
    }
  }
}

// Represent an ASN1 PRIVATE type. This is a
// custom ASN1 object that delegates the interpretation to the
// consumer.
class ASN1ContextSpecific extends ASN1Object {
  ASN1ContextSpecific({ASN1Tag? tag})
      : super(tag: tag ?? ASN1Tag(TagClass.CONTEXT_SPECIFIC_CLASS.value));

  ASN1ContextSpecific.fromBytes(
    super.bytes, {
    super.useX690,
  }) : super.fromBytes() {
    // check that this really is an Private type
    if (!tag.isContextSpecific) {
      throw ASN1Exception('tag $tag is not an ASN1 Context specific class');
    }
  }
}
