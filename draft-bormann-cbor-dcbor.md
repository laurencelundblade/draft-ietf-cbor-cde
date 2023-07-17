---
v: 3

title: dCBOR – an Application Profile for Use with CBOR Deterministic Encoding
abbrev: dCBOR
docname: draft-bormann-cbor-dcbor-latest
category: exp
stream: IETF

date:
consensus: true
area: "Applications and Real-Time"
workgroup: "Concise Binary Object Representation Maintenance and Extensions"
keyword:

venue:
  group: "Concise Binary Object Representation Maintenance and Extensions"
  mail: "cbor@ietf.org"
  github: "cabo/det"

author:
  -
    ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org

contributor:
 -
    ins: W. McNally
    name: Wolf McNally
    organization: Blockchain Commons
    email: wolf@wolfmcnally.com
 -
    ins: C. Allen
    name: Christopher Allen
    organization: Blockchain Commons
    email: christophera@lifewithalacrity.com


normative:
  STD94:
    -: cbor
    =: RFC8949

informative:
  I-D.bormann-cbor-det:
    -: det
    title: "CBOR: On Deterministic Encoding"
    author:
      name: Carsten Bormann
  I-D.mcnally-deterministic-cbor: dcbor-orig
  SwiftDCBOR:
    title: "Deterministic CBOR (\"dCBOR\") for Swift."
    target: https://github.com/BlockchainCommons/BCSwiftDCBOR
  RustDCBOR:
    title: "Deterministic CBOR (\"dCBOR\") for Rust."
    target: https://github.com/BlockchainCommons/bc-dcbor-rust
  cbor-dcbor:
    author:
      name: Carsten Bormann
    title: PoC of the McNally/Allen "dCBOR" application-level CBOR representation rules
    target: https://github.com/cabo/cbor-dcbor


--- abstract

CBOR (STD 94, RFC 8949) defines "Deterministically Encoded CBOR" in
its Section 4.2.  The present document provides the application
profile "dCBOR" that can be used with Deterministic Encoding.

--- middle

# Introduction

CBOR ({{STD94}}, also RFC 8949) defines "Deterministically Encoded CBOR" in
its Section 4.2.  The present document provides the application
profile "dCBOR" that can be used with Deterministic Encoding.


## Conventions and Definitions

{::boilerplate bcp14-tagged}

# Application Profile

The dCBOR Application Profile specifies the use of Deterministic
Encoding as defined in {{Section 4.2 of STD94}} (see also {{-det}} for more
information) together with some application-level rules specified in
this section.

The application-level rules specified here do not "fork" CBOR.
A dCBOR implementation produces well-formed, deterministically encoded
CBOR according to {{STD94}}, and existing generic CBOR decoders will
therefore be able to decode it, including those that check for
Deterministic Encoding.
Similarly, generic CBOR encoders will be able to produce valid dCBOR
if handed dCBOR conforming data model level information from an
application.

Please note that the separation between standard CBOR processing and the
processing required by the dCBOR application profile is a conceptual
one:
Both dCBOR processing and standard CBOR processing can be combined
into a special dCBOR/CBOR encoder/decoder.

## Numeric reduction

Note that this application profile places no requirement that dCBOR
implementations support floating point numbers.

dCBOR implementations that do support floating point numbers MUST
perform the following two reductions of numeric values when
construction CBOR data items:

1. When representing integral floating point values (floating point
   values with a zero fractional part), check whether the
   mathematically identical value can be represented as a basic (major
   type 0/1) integer value.
   If that is the case, convert the integral floating point
   to that mathematically identical integer value before encoding it.
   (Deterministic Encoding will then ensure the shortest length encoding
   is used.)
   This means that if a floating point value has a non-zero fractional part, or an
   exponent that takes it out of the range of basic integers, the
   original floating point value is used for encoding.
   (Specifically, conversion to a bignum is never considered.)

   Note that this reduction can turn valid maps into invalid ones, as it
   can create duplicate keys, e.g., for:

   ~~~ cbor-diag
   {
      10: "integer ten",
      10.0: "floating ten"
   }
   ~~~

   This means that, at the application level, the application MUST
   prevent the creation of maps that would turn invalid in dCBOR
   processing.

2. In addition, represent all `NaN` values by using the quiet `NaN`
   value having the half-width CBOR representation `0xf97e00` before
   encoding.

dCBOR-based applications MUST accept these "reduced" numbers in place
of the original value, e.g., a dCBOR-based application that expects a
floating point value needs to accept a basic integer value in its
place (and, if needed, convert it to a floating point value for
further processing).

# Implementation Status
{:removeinrfc}

{::boilerplate rfc7942info}

## Swift


* Implementation Location: {{SwiftDCBOR}}

* Primary Maintainer:

* Languages: Swift

* Coverage:

* Testing:

* Licensing:

## Rust

* Implementation Location: {{RustDCBOR}}

* Primary Maintainer:

* Languages: Rust

* Coverage:

* Testing:

* Licensing:

## Ruby

* Implementation Location: {{cbor-dcbor}}

* Primary Maintainer: Carsten Bormann

* Languages: Ruby

* Coverage:

* Testing:

* Licensing: Apache-2.0


# Security Considerations

TODO Security


# IANA Considerations

This document has no IANA actions.


--- back

# Acknowledgments
{:numbered="false"}

This document is based on the work of Wolf McNally and Christopher
Allen as documented in {{-dcbor-orig}} and discussed in 2023 in the CBOR
working group.
