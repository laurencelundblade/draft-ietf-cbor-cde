---
v: 3

title: Common CBOR Deterministic Encoding and Application Profiles
abbrev: CBOR Profiles
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
 -  name: Anders Rundgren
    organization: Independent
    city: Montpellier
    country: France
    email: anders.rundgren.net@gmail.com
    uri: https://www.linkedin.com/in/andersrundgren/

normative:
  STD94:
    -: cbor
    =: RFC8949
  IEEE754:
    target: https://ieeexplore.ieee.org/document/8766229
    title: IEEE Standard for Floating-Point Arithmetic
    author:
    - org: IEEE
    date: false
    seriesinfo:
      IEEE Std: 754-2019
      DOI: 10.1109/IEEESTD.2019.8766229
  RFC8610: cddl
  IANA.cddl:


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
  I-D.rundgren-deterministic-cbor: anders
  I-D.draft-mcnally-envelope-03: envelope-old

--- abstract

[^abs1-]

[^abs1-]:
    CBOR (STD 94, RFC 8949) defines "Deterministically Encoded CBOR" in
    its Section 4.2, providing some flexibility for application specific
    decisions.
    To facilitate Deterministic Encoding to be offered as a selectable
    feature of generic encoders, the present document discusses a
    Common CBOR Deterministic Encoding Profile that can be shared by a
    large set of applications with potentially diverging detailed
    requirements.
    The concept of Application Profiles is layered on top of the
    Common CBOR Deterministic Encoding Profile and can address those
    more application specific requirements.
    The document defines the application profile "Gordian dCBOR" as an
    example of an application profile built on the Common CBOR
    Deterministic Encoding Profile.

--- middle

# Introduction

[^abs1-]


## Conventions and Definitions

{::boilerplate bcp14-tagged}

# Common CBOR Deterministic Encoding Profile {#dep}

{{Section 4.2.1 of -cbor}} defines _Core Deterministic Encoding
Requirements_ for CBOR.
It mandates to keep with what are only recommendations for Preferred
Encoding for regular CBOR encoders.
It adds mandates for definite-length encoding and for a
map ordering based on lexicographic ordering of the
(deterministically) encoded map keys.

Note that this specific set of requirements is elective — in
principle, other variants of deterministic encoding can be defined
(and have been, now being phased out slowly, as detailed in {{Section 4.2.3
of -cbor}}), or (as many applications of CBOR do today) deterministic
encoding is not used at all.

The core requirements are designed, however, to provide
well-understood and easy to implement rules while maximizing coverage,
i.e., the subset of CBOR data items that are fully specified by these
rules, and also placing minimal burden on implementations.

{{Section 4.2.2 of -cbor}} picks up on the interaction of extensibility
(CBOR tags) and deterministic encoding.
CBOR itself uses some tags to increase the range of its basic
generic data types, e.g., tag 2/3 extend the range of basic major
types 0/1 in a seamless way.
{{Section 4.2.2 of -cbor}} recommends handling this transition the same
way as with the transition between different integer representation
lengths in the basic generic data model, i.e., by mandating the
Preferred Encoding ({{Section 3.4.3 of -cbor}}).

{: group="1"}
1. The Common CBOR Deterministic Encoding Profile turns this
   recommendation into a mandate: Integers that can be represented by
   basic major type 0 and 1 are encoded using the deterministic
   encoding defined for them, and integers outside this range are
   encoded using the preferred serialization ({{Section 3.4.3 of
   -cbor}}) of tag 2 and 3 (i.e., no leading zeros).

Most tags capture more specific application semantics and therefore
may be harder to define a deterministic encoding for.
While the deterministic encoding of their tag internals is often
covered by the _Core Deterministic Encoding Requirements_, the mapping
of diverging platform application data types on the tag contents may
be hard to do in a deterministic way; see {{Section 3.2 of -det}} for
more explanation as well as examples.
As the Common CBOR Deterministic Encoding Profile would continually
need to address additional issues raised by the registration of new
tags, this specification RECOMMENDS that new tag registrations address
deterministic encoding in the context of this Profile.

A particularly difficult field to obtain deterministic encoding for is
floating point numbers, partially because they themselves are often
obtained from processes that are not entirely deterministic between platforms.
See {{Section 3.2.2 of -det}} for more details.
{{Section 4.2.2 of -cbor}} presents a number of choices, which need to
be made to obtain a Common CBOR Deterministic Encoding Profile.
Specifically (in the order of the bullet list at the end of {{Section
4.2.2 of -cbor}}):

{: group="1"}
2. Besides the mandated use of preferred encoding, there is no further
   specific action for the two different zero values, e.g., an encoder
   that is asked by an application to represent a negative floating
   point zero will generate 0xf98000.
3. There is no attempt to mix integers and floating point numbers,
   i.e., all floating point values are encoded as the preferred
   floating-point representation that accurately represents the value,
   independent of whether the floating point value is, mathematically,
   an integral value (choice 2 of the second bullet).
4. There is no special handling of NaN values, except that the
   preferred encoding rules also apply to NaNs with payloads, using
   the canonical encoding of NaNs as defined in {{IEEE754}}.
   Typically, most applications that employ NaNs in their storage and
   communication interfaces will only use the NaN with payload 0,
   which encodes as 0xf97e00.
5. There is no special handling of subnormal values.
6. The Common CBOR Deterministic Encoding Profile does not presume
   equivalence of floating point values with other representation
   (e.g., tag 4/5) with basic floating point values.

The main intent here is to preserve the basic generic data model, so
application profiles can make their own decisions.  For an example of
that, see {{dcbor-num}}.

While {{-anders}} is a relatively terse document that is not always easy
to interpret, to this author its intent appears to be aligned with
that of the Common CBOR Deterministic Encoding Profile defined here.

# Application Profiles

The dCBOR Application Profile specifies the use of Deterministic
Encoding as defined in {{Section 4.2 of STD94}} (see also {{-det}} for more
information) together with some application-level rules.
As an example, the rules for Gordian dCBOR {{-dcbor-orig}} are specified
in this section.

The application-level rules specified by an Application Profile are
based on the same Common CBOR Deterministic Encoding Profile; they do
not "fork" CBOR.

An Application Profile implementation produces well-formed,
deterministically encoded CBOR according to {{STD94}}, and existing
generic CBOR decoders will therefore be able to decode it, including
those that check for Deterministic Encoding.
Similarly, generic CBOR encoders will be able to produce valid CBOR
that can be processed by Application Profile implementations, if
handed Application Profile conforming data model level information
from an application.

Please note that the separation between standard CBOR processing and
the processing required by the Application Profile is a conceptual
one: Both Application Profile processing and standard CBOR processing
can be combined into a special dCBOR/CBOR encoder/decoder.

An Application Profile is intended to be used in conjunction with an
application, which typically will use a subset of the CBOR generic
data model, which in turn
influences which subset of the application profile is used.
As a result, an Application Profile places no direct requirement on what
subset of CBOR is implemented.
For instance, while the dCBOR application profile defines rules for
the processing of floating point values, there is no requirement that
dCBOR implementations support floating point numbers (or any other
kind of number, such as arbitrary precision integers or 64-bit
negative integers) when they are used with applications that do not
use them.

## Gordian dCBOR {#dcbor}

Gordian dCBOR {{-dcbor-orig}} provides an application profile that
requires encoders to produce valid CBOR in deterministic encoding as
defined in the Common CBOR Deterministic Encoding Profile.
Gordian dCBOR also requires dCBOR decoders to reject CBOR data items
that were not deterministically encoded.

Beyond the Common CBOR Deterministic Encoding Profile, dCBOR imposes
certain limitations on the CBOR basic generic data model.
Some items that can be represented in the CBOR basic generic data
model are entirely outlawed by this application profile.
Other items are represented by what are considered equivalent data
items by the dCBOR equivalence model, so a recipient application might
receive data that may not be the same data in the CBOR equivalence
model as the ones the generating application produced.

These restrictions mainly are about numeric values, which are therefore
the subject of the main subsection of this section.

### Removing Simple Values

Only the three simple values `false` (0xf4), `true` (0xf5), and `null`
(0xf6) are allowed at the application level; the remaining 253 values
must be rejected.

### Removing Integer Values

Only the integer values in range \[`-2`<sup>`63`</sup>,
`2`<sup>`64`</sup>`-1`] can be expressed in dCBOR ("basic dCBOR integers").
Note that the range is asymmetric, with only 2<sup>63</sup> negative
values, but 2<sup>64</sup> unsigned (non-negative) values, creating an
(approximately) 64.6 bit integer.

This maps to a choice between a platform 64-bit two's complement
signed integer (often called int64) and a 64-bit unsigned integer (uint64).
(Specific applications will, of course, further restrict valid ranges of
integers, based on their position and semantics in the CBOR data item.)

### Numeric Reduction of Floating-Point Values {#dcbor-num}

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

## Extensibility

{{-dcbor-orig}} does not discuss extensibility.
A meaningful way to handle extensibility in this application profile
would be to lift value range restrictions, keeping the
profile-specific equivalence rules show here intact and possibly
adding equivalences as needed for newly allowed values.
This requires further discussion.

# CDDL support

{{-cddl}} defines control operators to indicate that the contents of a
byte string carries a CBOR-encoded data item (`.cbor`) or a sequence of
CBOR-encoded data items (`.cborseq`).

CDDL specifications may want to specify that the data items should be
encoded in Common CBOR Deterministic Encoding, or with the dCBOR
application profile applied as well.
This specification adds four CDDL control operators that can be used
for this.

The control operators `.cde` and `.cdeseq` are exactly like `.cbor` and
`.cborseq` except that they also require the encoded data item(s) to be
in Common CBOR Deterministic Encoding.

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

More importantly, if the encoded data item also needs to have a
specific structure, this can be expressed by the right hand side
(instead of using the most general CDDL type `any` here).

(Note that the ...`seq` control operators do not enable specifying
different deterministic encoding requirements for the elements of the
sequence.  If a use case for such a feature becomes known, it could be
added.)


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
| .cde      | [RFCXXXX] |
| .cdeseq   | [RFCXXXX] |
| .dcbor    | [RFCXXXX] |
| .dcborseq | [RFCXXXX] |
{: #tbl-iana-reqs title="New control operators to be registered"}


--- back

# Acknowledgments
{:numbered="false"}

{{dcbor}} of this document is based on the work of Wolf McNally and Christopher
Allen as documented in {{-dcbor-orig}} and discussed in 2023 in the CBOR
working group.
