---
v: 3

title: The CDE-based Application Profile dCBOR
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
 -  name: Wolf McNally
    organization: Blockchain Commons
    email: wolf@wolfmcnally.com
 -  name: Christopher Allen
    organization: Blockchain Commons
    email: christophera@lifewithalacrity.com

normative:
  STD94:
    -: cbor
    =: RFC8949
  RFC8610: cddl
  IANA.cddl:


informative:
  I-D.bormann-cbor-det:
    -: det
  I-D.bormann-cbor-cde:
    -: cde
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
  I-D.draft-mcnally-envelope-03: envelope-old
  i128:
    title: Primitive Type i128
    target: https://doc.rust-lang.org/std/primitive.i128.html
  u128:
    title: Primitive Type u128
    target: https://doc.rust-lang.org/std/primitive.u128.html

--- abstract

[^abs1-]

[^abs1-]:
    CBOR (STD 94, RFC 8949) defines "Deterministically Encoded CBOR" in
    its Section 4.2, providing some flexibility for application specific
    decisions.
    The CBOR Common Deterministic Encoding (CDE) Profile provides a more
    detail common base for Deterministic Encoding, facilitating it be
    offered as a selectable feature of generic encoders, as well as
    the concept of Application Profiles that are layered on top of CDE.
    This document defines the application profile "dCBOR" as an
    example of such an application profile.

--- middle

# Introduction

[^abs1-]

## Conventions and Definitions

The definitions of {{-cbor}} and the Common Deterministic Encoding (CDE)
Profile {{-cde}} apply.

{::boilerplate bcp14-tagged}

# Gordian dCBOR {#dcbor}

Gordian dCBOR {{-dcbor-orig}} provides an application profile that
requires encoders to produce valid CBOR in deterministic encoding as
defined in CDE).
Gordian dCBOR also requires dCBOR decoders to reject CBOR data items
that were not deterministically encoded.

Beyond CDE, dCBOR imposes
certain limitations on the CBOR basic generic data model.
Some items that can be represented in the CBOR basic generic data
model are entirely outlawed by this application profile.
Other items are represented by what are considered equivalent data
items by the dCBOR equivalence model, so a recipient application might
receive data that may not be the same data in the CBOR equivalence
model as the ones the generating application produced.

These restrictions mainly are about numeric values, which are therefore
the subject of the main subsection of this section.

## Removing Simple Values

Only the three simple values `false` (0xf4), `true` (0xf5), and `null`
(0xf6) are allowed at the application level; the remaining 253 values
must be rejected.

## Removing Integer Values

Only the integer values in range \[`-2`<sup>`63`</sup>,
`2`<sup>`64`</sup>`-1`] can be expressed in dCBOR ("basic dCBOR integers").
Note that the range is asymmetric, with only 2<sup>63</sup> negative
values, but 2<sup>64</sup> unsigned (non-negative) values, creating an
(approximately) 64.6 bit integer.

This maps to a choice between a platform 64-bit two's complement
signed integer (often called int64) and a 64-bit unsigned integer (uint64).
(Specific applications will, of course, further restrict ranges of
integers that are considered valid for the application, based on their
position and semantics in the CBOR data item.)

## Numeric Reduction of Floating-Point Values {#dcbor-num}

dCBOR implementations that do support floating point numbers MUST
perform the following two reductions of numeric values when
constructing CBOR data items:

1. When representing integral floating point values (floating point
   values with a zero fractional part), check whether the
   mathematically identical value can be represented as a dCBOR
   integer value, i.e., is in the range \[`-2`<sup>`63`</sup>,
   `2`<sup>`64`</sup>`-1`] given above.
   If that is the case, convert the integral floating point
   to that mathematically identical integer value before encoding it.
   (Deterministic Encoding will then ensure the shortest length encoding
   is used.)
   This means that if a floating point value has a non-zero fractional part, or an
   exponent that takes it out of the given range of basic dCBOR integers, the
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

2. In addition, before encoding, represent all `NaN` values by using
   the quiet `NaN` value having the half-width CBOR representation
   `0xf97e00`.

dCBOR-based applications MUST accept these "reduced" numbers in place
of the original value, e.g., a dCBOR-based application that expects a
floating point value needs to accept a basic dCBOR integer in its
place (and, if needed, convert it to a floating point value for its
own further processing).

dCBOR-based applications MUST NOT accept numbers that have not been
reduced as specified in this section, except maybe by making the
unreduced numbers available for their diagnostic value when there has
been an explicit request to do so.
This is similar to a checking flag mentioned in Section 5.1 (API
Considerations) of {{-det}} being set by default.

# Extensibility

{{-dcbor-orig}} does not discuss extensibility.
A meaningful way to handle extensibility in this application profile
would be to lift value range restrictions, keeping the
profile-specific equivalence rules shown here intact and possibly
adding equivalences as needed for newly allowed values.

This subsection presents two speculative extensions of dCBOR, called
dCBOR-wide1 and dCBOR-wide2, to point out different objectives that
can lead the development of an extension.

## dCBOR-wide1 {#wide1}

This speculative extension of dCBOR attempts to meet two objectives:

{:group="w1"}
1. All instances that meet dCBOR are also instances of dCBOR-wide1;
   due to the nature of deterministic serialization this also means
   that dCBOR-wide1 instances that only use application data model
   values that are allowed by dCBOR are also dCBOR instances.
2. The range of integers that can be provided by an application and
   can be interchanged as exact numbers is
   expanded to \[`-2`<sup>`127`</sup>, `2`<sup>`128`</sup>`-1`],
   now also covering the types i128 and u128 in Rust {{i128}}{{u128}}.

This extension is achieved by simply removing the integers in the
extended range from the exclusion range of dCBOR.
The numeric reduction rule is not changed, so it still applies only to
integral-valued floating-point numbers in the range
\[`-2`<sup>`63`</sup>, `2`<sup>`64`</sup>`-1`].

Examples for the application-to-CDE mapping of dCBOR-wide1 are shown
in {{tab-wide1}}.
In the dCBOR column, items that are not excluded in dCBOR are marked
✓, items that are excluded in dCBOR and therefore are new in
dCBOR-wide1 are marked 👎.

{::include tab-wide1}

This speculative extended profile does not meet a potential objective
number 3 that unextended dCBOR does meet:

{:group="w1"}
3. All integral-valued floating point numbers coming from an
   application that fit into an integer representation allowed
   by the application profile are represented as such.

Objective 1 prevents numeric reduction from being applied to values
that are not excluded in dCBOR but do to receive numeric reduction
there.

## dCBOR-wide2 {#wide2}

The speculative dCBOR-wide2 extension of dCBOR attempts to meet
objectives 2 and 3 mentioned in {{wide1}}.  It cannot meet objective 1:
items in {{tab-wide2}} marked with a 💣 character are allows in dCBOR
but have different serializations.

{::include tab-wide2}

This extension is achieved by removing the integers in the
extended range from the exclusion range of dCBOR, and by adding the
extended range to the target range of numeric reduction.

# CDDL support

Similar to the CDDL {{-cddl}} support in {{-cde}},
this specification adds two CDDL control operators that can be used
to specify that the data items should be
encoded in CBOR Common Deterministic Encoding (CDE), with the dCBOR
application profile applied as well.

The control operators `.dcbor` and `.dcborseq` are exactly like `.cde` and
`.cdeseq` except that they also require the encoded data item(s) to
conform to the dCBOR application profile.

For example, the normative comment in {{Section 3 of -envelope-old}}:

~~~
leaf = #6.24(bytes)  ; MUST be dCBOR
~~~

...can now be formalized as:

~~~
leaf = #6.24(bytes .dcbor any)
~~~


# Implementation Status
{:removeinrfc}

{::boilerplate rfc7942info}

## Gordian dCBOR Application Profile

### TypeScript

* Implementation Location: {{bc-dcbor-ts}}

* Primary Maintainer:

* Languages: TypeScript (transpiles to JavaScript)

* Coverage:

* Testing:

* Licensing:

### Swift


* Implementation Location: {{BCSwiftDCBOR}}

* Primary Maintainer:

* Languages: Swift

* Coverage:

* Testing:

* Licensing: BSD-2-Clause-Patent

### Rust

* Implementation Location: {{bc-dcbor-rust}}

* Primary Maintainer:

* Languages: Rust

* Coverage:

* Testing:

* Licensing: Custom

### Ruby

* Implementation Location: {{cbor-dcbor}}

* Primary Maintainer: Carsten Bormann

* Languages: Ruby

* Coverage: Complete specification; complemented by CBOR
  encoder/decoder and command line interface from {{cbor-diag}} and
  deterministic encoding from {{cbor-deterministic}}.
  Checking of dCBOR exclusions not yet implemented.

* Testing:
  Also available at <https://cbor.me>

* Licensing: Apache-2.0


# Security Considerations

TODO Security


# IANA Considerations

[^to-be-removed]

[^to-be-removed]: RFC Editor: please replace RFCXXXX with the RFC
    number of this RFC and remove this note.

This document requests IANA to register the contents of
{{tbl-iana-reqs}} into the registry
"{{cddl-control-operators (CDDL Control Operators)<IANA.cddl}}" of {{IANA.cddl}}:

| Name      | Reference |
| .dcbor    | \[RFCXXXX] |
| .dcborseq | \[RFCXXXX] |
{: #tbl-iana-reqs title="New control operators to be registered"}


--- back

# Acknowledgments
{:numbered="false"}

This document is based on the work of Wolf McNally and Christopher
Allen as documented in {{-dcbor-orig}} and discussed in 2023 in the CBOR
working group.
