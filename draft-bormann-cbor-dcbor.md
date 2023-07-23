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
workgroup: CBOR
keyword:

venue:
  group: "Concise Binary Object Representation Maintenance and Extensions (CBOR)"
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
  I-D.mcnally-deterministic-cbor: dcbor-orig
  bc-dcbor-ts:
    title: "Blockchain Commons Deterministic CBOR (\"dCBOR\") for TypeScript"
    target: https://github.com/BlockchainCommons/bc-dcbor-ts
  BCSwiftDCBOR:
    title: "Blockchain Commons Deterministic CBOR (\"dCBOR\") for Swift"
    target: https://github.com/BlockchainCommons/BCSwiftDCBOR
  bc-dcbor-rust:
    title: "Blockchain Commons Deterministic CBOR (\"dCBOR\") for Rust"
    target: https://github.com/BlockchainCommons/bc-dcbor-rust
  cbor-dcbor:
    author:
      name: Carsten Bormann
    title: PoC of the McNally/Allen "dCBOR" application-level CBOR representation rules
    target: https://github.com/cabo/cbor-dcbor
  cbor-diag:
    author:
      name: Carsten Bormann
    title: CBOR diagnostic utilities
    target: https://github.com/cabo/cbor-diag
  cbor-deterministic:
    author:
      name: Carsten Bormann
    title: cbor-deterministic gem
    target: https://github.com/cabo/cbor-deterministic


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

This application profile is intended to be used in conjunction with an
application, which typically will use a subset of CBOR, which in turn
influences which subset of the application profile is used.
As a result, this application profile places no direct requirement on what
subset of CBOR is implemented.
For instance, there is no requirement that dCBOR implementations
support floating point numbers (or any other kind of number, such as
arbitrary precision integers or 64-bit negative integers) when they
are used with applications that do not use them.

## Numeric reduction

dCBOR implementations that do support floating point numbers MUST
perform the following two reductions of numeric values when
constructing CBOR data items:

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

   This also means that the three representations of a zero number in CBOR
   (0, 0.0, -0.0 in diagnostic notation) are all reduced to the basic
   integer 0 (with preferred encoding 0x00).

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

dCBOR-based applications MUST NOT accept numbers that have not been
reduced as specified in this section, except maybe by making the
unreduced numbers available for their diagnostic value when there has
been an explicit request to do so.
This is similar to a checking flag mentioned in Section 5.1 (API
Considerations) of {{-det}} being set by default.

# Implementation Status
{:removeinrfc}

{::boilerplate rfc7942info}

## TypeScript

* Implementation Location: {{bc-dcbor-ts}}

* Primary Maintainer:

* Languages: TypeScript (transpiles to JavaScript)

* Coverage:

* Testing:

* Licensing:

## Swift


* Implementation Location: {{BCSwiftDCBOR}}

* Primary Maintainer:

* Languages: Swift

* Coverage:

* Testing:

* Licensing: BSD-2-Clause-Patent

## Rust

* Implementation Location: {{bc-dcbor-rust}}

* Primary Maintainer:

* Languages: Rust

* Coverage:

* Testing:

* Licensing: Custom

## Ruby

* Implementation Location: {{cbor-dcbor}}

* Primary Maintainer: Carsten Bormann

* Languages: Ruby

* Coverage: Complete specification; complemented by CBOR
  encoder/decoder and command line interface from {{cbor-diag}} and
  deterministic encoding from {{cbor-deterministic}}

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
