---
v: 3

title: CBOR Common Deterministic Encoding (CDE)
abbrev: CBOR CDE
docname: draft-ietf-cbor-cde-latest
category: bcp
stream: IETF

date:
consensus: true
area: "Applications and Real-Time"
workgroup: CBOR
keyword:

venue:
  group: "Concise Binary Object Representation Maintenance and Extensions (CBOR)"
  mail: "cbor@ietf.org"
  github: cbor-wg/draft-ietf-cbor-cde

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
- name: Laurence Lundblade
  org: Security Theory LLC
  email: lgl@securitytheory.com
  contribution: Laurence provided the text that became {{impcheck}}.

normative:
  STD94: cbor
#    =: RFC8949
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
  I-D.bormann-cbor-det: det
  I-D.mcnally-deterministic-cbor: dcbor-orig
  I-D.bormann-cbor-numbers: numbers

--- abstract

[^abs1-]

[^abs1-]:
    CBOR (STD 94, RFC 8949) defines "Deterministically Encoded CBOR" in
    its Section 4.2, providing some flexibility for application specific
    decisions.
    To facilitate Deterministic Encoding to be offered as a selectable
    feature of generic encoders, the present document defines a
    CBOR Common Deterministic Encoding (CDE) Profile that can be shared by a
    large set of applications with potentially diverging detailed
    requirements.

--- middle

# Introduction

[^abs1-]

## Structure of This Document

After introductory material, {{dep}} defines the CBOR Common
Deterministic Encoding Profile (CDE).
{{cddl-support}} defines Concise Data Definition Language (CDDL) support for indicating the use of CDE.
This is followed by the conventional sections for
{{<<seccons}} ({{<seccons}}),
{{<<sec-iana}} ({{<sec-iana}}),
and {{<<sec-combined-references}} ({{<sec-combined-references}}).

The informative {{application-profiles}} introduces the concept of Application Profiles,
which are layered on top of the CBOR CDE Profile and can address
recurring requirements on deterministic representation
of application data where these requirements are specific to a set of
applications.
(Application Profiles themselves, if needed, are defined in separate
documents.)

The informative {{impcheck}} provides brief checklists that implementers
can use to check their CDE implementations.

## Conventions and Definitions

{::boilerplate bcp14-tagged-bcp14}

# CBOR Common Deterministic Encoding Profile (CDE) {#dep}

This specification defines the *CBOR Common Deterministic Encoding
Profile* (CDE) based on the _Core Deterministic Encoding
Requirements_ defined for CBOR in
{{Section 4.2.1 of RFC8949@-cbor}}.

In many cases, CBOR provides more than one way to encode a data item,
but also provides a recommendation for a *Preferred Serialization*.
The *CoRE Deterministic Encoding Requirements* generally pick the
preferred serializations as mandatory; they also pick additional choices
such as definite-length encoding.
Finally, they define a map ordering based on lexicographic ordering of
the (deterministically) encoded map keys.

Note that this specific set of requirements is elective — in
principle, other variants of deterministic encoding can be defined
(and have been, now being phased out slowly, as detailed in {{Section 4.2.3
of RFC8949@-cbor}}).
In many applications of CBOR today, deterministic encoding is not used
at all, as its restriction of choices can create some additional
performance cost and code complexity.

{{-cbor}}'s core requirements are designed to provide well-understood and
easy-to-implement rules while maximizing coverage, i.e., the subset of
CBOR data items that are fully specified by these rules, and also
placing minimal burden on implementations.

{{Section 4.2.2 of RFC8949@-cbor}} picks up on the interaction of extensibility
(CBOR tags) and deterministic encoding.
CBOR itself uses some tags to increase the range of its basic
generic data types, e.g., tags 2/3 extend the range of basic major
types 0/1 in a seamless way.
{{Section 4.2.2 of RFC8949@-cbor}} recommends handling this transition the same
way as with the transition between different integer representation
lengths in the basic generic data model, i.e., by mandating the
preferred serialization for all integers ({{Section 3.4.3 of RFC8949@-cbor}}).

{: group="1"}
1. The CBOR Common Deterministic Encoding Profile (CDE) turns this
   recommendation into a mandate: Integers that can be represented by
   basic major type 0 and 1 are encoded using the deterministic
   encoding defined for them, and integers outside this range are
   encoded using the preferred serialization ({{Section 3.4.3 of
   RFC8949@-cbor}}) of tag 2 and 3 (i.e., no leading zero bytes).

Most tags capture more specific application semantics and therefore
may be harder to define a deterministic encoding for.
While the deterministic encoding of their tag internals is often
covered by the _Core Deterministic Encoding Requirements_, the mapping
of diverging platform application data types onto the tag contents may
require additional attention to perform it in a deterministic way; see
{{Section 3.2 of -det}} for
more explanation as well as examples.
As the CDE would continually
need to address additional issues raised by the registration of new
tags, this specification recommends that new tag registrations address
deterministic encoding in the context of this Profile.

A particularly difficult field to obtain deterministic encoding for is
floating point numbers, partially because they themselves are often
obtained from processes that are not entirely deterministic between platforms.
See {{Section 3.2.2 of -det}} for more details.
{{Section 4.2.2 of RFC8949@-cbor}} presents a number of choices, which need to
be made to obtain a CBOR Common Deterministic Encoding Profile (CDE).
Specifically, CDE specifies (in the order of the bullet list at the end of {{Section
4.2.2 of RFC8949@-cbor}}):

{: group="1"}
2. Besides the mandated use of preferred serialization, there is no further
   specific action for the two different zero values, e.g., an encoder
   that is asked by an application to represent a negative floating
   point zero will generate 0xf98000.
3. There is no attempt to mix integers and floating point numbers,
   i.e., all floating point values are encoded as the preferred
   floating-point representation that accurately represents the value,
   independent of whether the floating point value is, mathematically,
   an integral value (choice 2 of the second bullet).
4. Apart from finite and infinite numbers, {{IEEE754}} floating point
   values include NaN (not a number) values {{-numbers}}.
   In CDE, there is no special handling of NaN values, except that the
   preferred serialization rules also apply to NaNs (with zero or
   non-zero payloads), using the canonical encoding of NaNs as defined
   in Section 6.2.1 of {{IEEE754}}.
   Specifically, this means that shorter forms of encodings for a NaN
   are used when that can be achieved by only removing trailing zeros
   in the NaN payload.
   Further clarifying a "should"-level statement in Section 6.2.1 of
   {{IEEE754}}, the CBOR encoding always uses a leading bit of 1 in the
   significand to encode a quiet NaN; encoding of signaling NaN is NOT
   RECOMMENDED but is achieved by using a leading bit of 0.

   Typically, most applications that employ NaNs in their storage and
   communication interfaces will only use a quiet NaN with payload 0,
   which therefore deterministically encodes as 0xf97e00.
5. There is no special handling of subnormal values.
6. The CBOR Common Deterministic Encoding Profile does not presume
   equivalence of basic floating point values with floating point
   values using other representations (e.g., tag 4/5).
   Such equivalences and related deterministic representation rules
   can be added at the application (profile) level if desired.

The main intent here is to preserve the basic generic data model, so
applications (or Application Profiles, see {{application-profiles}}) can
make their own decisions within that data model.
E.g., an application (profile) can decide that it only ever allows a
single NaN value that would be encoded as 0xf97e00, so a CDE
implementation focusing on this application (profile) would not need to
provide processing for other NaN values.
Basing the definition of both CDE and Application Profiles on the
generic data model of CBOR also means that there is no effect on the
Concise Data Definition Language (CDDL)
{{-cddl}}, except where the data description documents encoding decisions
for byte strings that carry embedded CBOR.

--- back

# Application Profiles

This appendix is informative.

While the CBOR Common Deterministic Encoding Profile (CDE) provides
for commonality between different applications of CBOR, it can be useful
to further constrain the set of data items handled in a group of
applications (_exclusions_) and to define further mappings
(_reductions_) that help the applications in such a group get by with
the exclusions.

For example, the dCBOR Application Profile specifies the use of
CDE together with some application-level rules {{-dcbor-orig}}.

In general, the application-level rules specified by an Application Profile are
based on the shared CBOR Common Deterministic Encoding Profile; they do
not "fork" CBOR in the sense of requiring distinct generic
encoder/decoder implementations.

An Application Profile implementation produces well-formed,
deterministically encoded CBOR according to {{STD94}}, and existing
generic CBOR decoders will therefore be able to decode it, including
those that check for Deterministic Encoding ("CDE decoders", see also
{{impcheck}}).
Similarly, generic CBOR encoders will be able to produce valid CBOR
that can be processed by Application Profile implementations, if
handed Application Profile conforming data model level information
from an application.

Please note that the separation between standard CBOR processing and
the processing required by the Application Profile is a conceptual
one: Instead of employing generic encoders/decoders, both Application
Profile processing and standard CBOR processing
can be combined into a encoder/decoder specifically designed for the
Application Profile.

An Application Profile is intended to be used in conjunction with an
application, which typically will use a subset of the CBOR generic
data model, which in turn
influences which subset of the application profile is used.
As a result, an Application Profile itself places no direct
requirement on what minimum subset of CBOR is implemented.
For instance, an application profile might define rules for the
processing of floating point values, but there is no requirement that
implementations of that Application Profile support floating point
numbers (or any other kind of number, such as arbitrary precision
integers or 64-bit negative integers) when they are used with
applications that do not use them.

--- middle

# CDDL support

{{-cddl}} defines control operators to indicate that the contents of a
byte string carries a CBOR-encoded data item (`.cbor`) or a sequence of
CBOR-encoded data items (`.cborseq`).

CDDL specifications may want to specify that the data items should be
encoded in Common CBOR Deterministic Encoding.
The present specification adds two CDDL control operators that can be used
for this.

The control operators `.cde` and `.cdeseq` are exactly like `.cbor` and
`.cborseq` except that they also require the encoded data item(s) to be
encoded according to CDE.

For example, a byte string of embedded CBOR that is to be encoded
according to CDE can be formalized as:

~~~
leaf = #6.24(bytes .cde any)
~~~

More importantly, if the encoded data item also needs to have a
specific structure, this can be expressed by the right-hand side
(instead of using the most general CDDL type `any` here).

(Note that the `.cborseq` control operator does not enable specifying
different deterministic encoding requirements for the elements of the
sequence.  If a use case for such a feature becomes known, it could be
added.)


Obviously, Application Profiles can define related control operators
that also embody the processing required by the Application Profile,
and are encouraged to do so.


# Security Considerations {#seccons}

The security considerations in {{Section 10 of RFC8949@-cbor}} apply.
The use of deterministic encoding can mitigate issues arising out of
the use of non-preferred serializations specially crafted by an attacker.
However, this effect only accrues if the decoder actually checks that
deterministic encoding was applied correctly.
More generally, additional security properties of deterministic
encoding can rely on this check being performed properly.

# IANA Considerations {#sec-iana}

[^to-be-removed]

[^to-be-removed]: RFC Editor: please replace RFCXXXX with the RFC
    number of this RFC and remove this note.

This document requests IANA to register the contents of
{{tbl-iana-reqs}} into the registry
"{{cddl-control-operators (CDDL Control Operators)<IANA.cddl}}" of the
{{IANA.cddl}} registry group:

| Name      | Reference |
| .cde      | \[RFCXXXX] |
| .cdeseq   | \[RFCXXXX] |
{: #tbl-iana-reqs title="New control operators to be registered"}


--- back

# Implementers' Checklists {#impcheck}

This appendix is informative.
It provides brief checklists that implementers can use to check their
implementations.
It uses {{RFC2119}} language, specifically the keyword MUST, to highlight
the specific items that implementers may want to check.
It does not contain any normative mandates.
This appendix is informative.

Notes:

* This is largely a restatement of parts of {{Section 4 of
  RFC8949@-cbor}}.
  The purpose of the restatement is to aid the work of implementers,
  not to redefine anything.

* Duplicate map keys are never valid in CBOR at all (see
  list item "Major type 5" in {{Section 3.1 of RFC8949@-cbor}})
  no matter what sort of serialization is used.
  Of the various strategies listed in {{Section 5.6 of RFC8949@-cbor}},
  detecting duplicates and handling them as an error instead of
  passing invalid data to the application is the most robust one;
  achieving this level of robustness is a mark of quality of
  implementation.

* Preferred serialization and CDE only affect serialization.
  They do not place any requirements, exclusions, mappings or such on
  the data model level.
  Application profiles such as dCBOR are different as they can affect
  the data model by restricting some values and ranges.

* CBOR decoders in general are not required to check for preferred
  serialization or CDE and reject inputs that do not fulfill
  their requirements.
  However, in an environment that employs deterministic encoding,
  employing non-checking CBOR decoders negates many of its benefits.
  Decoder implementations that advertise "support" for preferred
  serialization or CDE need to check the encoding and reject
  input that is not encoded to the encoding specification in use.
  Again, application profiles such as dCBOR may pose additional
  requirements, such as requiring rejection of non-conforming inputs.

  If a generic decoder needs to be used that does not "support" CDE, a
  simple (but somewhat clumsy) way to check for proper CDE encoding is
  to re-encode the decoded data and check for bit-to-bit equality with
  the original input.

## Preferred Serialization

In the following, the abbreviation "ai" will be used for the 5-bit
additional information field in the first byte of an encoded CBOR data
item, which follows the 3-bit field for the major type.

### Preferred Serialization Encoders {#pse}

1. Shortest-form encoding of the argument MUST be used for all major
   types.
   Major type 7 is used for floating-point and simple values; floating
   point values have its specific rules for how the shortest form is
   derived for the argument.
   The shortest form encoding for any argument that is not a floating
   point value is:

   * 0 to 23 and -1 to -24 MUST be encoded in the same byte as the
     major type.
   * 24 to 255 and -25 to -256 MUST be encoded only with an additional
     byte (ai = 0x18).
   * 256 to 65535 and -257 to -65536 MUST be encoded only with an
     additional two bytes (ai = 0x19).
   * 65536 to 4294967295 and -65537 to -4294967296 MUST be encoded
     only with an additional four bytes (ai = 0x1a).

1. If maps or arrays are emitted, they MUST use definite-length
   encoding (never indefinite-length).

1. If text or byte strings are emitted, they MUST use definite-length
   encoding (never indefinite-length).

1. If floating-point numbers are emitted, the following apply:

   * The length of the argument indicates half (binary16, ai = 0x19),
     single (binary32, ai = 0x1a) and double (binary64, ai = 0x1b)
     precision encoding.
     If multiple of these encodings preserve the precision of the
     value to be encoded, only the shortest form of these MUST be
     emitted.
     That is, encoders MUST support half-precision and
     single-precision floating point.
     Positive and negative infinity and zero MUST be represented in
     half-precision floating point.

   * NaNs, and thus NaN payloads MUST be supported.

     As with all floating point numbers, NaNs with payloads MUST be
     reduced to the shortest of double, single or half precision that
     preserves the NaN payload.
     The reduction is performed by removing the rightmost N bits of the
     payload, where N is the difference in the number of bits in the
     significand (mantissa) between the original format and the
     reduced format.
     The reduction is performed only (preserves the value only) if all the
     rightmost bits removed are zero.
     (This will always reduce a double or single quiet NaN with a zero
     NaN payload to a half-precision quiet NaN.)

### Preferred Serialization Decoders {#psd}

1. Decoders MUST accept shortest-form encoded arguments.

1. If arrays or maps are supported, definite-length arrays or maps MUST be accepted.

1. If text or byte strings are supported, definite-length text or byte
   strings MUST be accepted.

1. If floating-point numbers are supported, the following apply:

   * Half-precision values MUST be accepted.
   * Double- and single-precision values SHOULD be accepted; leaving these out
     is only foreseen for decoders that need to work in exceptionally
     constrained environments.
   * If double-precision values are accepted, single-precision values
     MUST be accepted.

   * NaNs, and thus NaN payloads, MUST be accepted.


## CDE

### CDE Encoders

1. CDE encoders MUST only emit CBOR fulfilling the preferred
   serialization rules ({{pse}}).

1. CDE encoders MUST sort maps by the CBOR representation of the map
   key.
   The sorting is byte-wise lexicographic order of the encoded map
   key data items.

1. CDE encoders MUST generate CBOR that fulfills basic validity
   ({{Section 5.3.1 of RFC8949@-cbor}}).  Note that this includes not
   emitting duplicate keys in a major type 5 map as well as emitting
   only valid UTF-8 in major type 3 text strings.

### CDE Decoders

The term "CDE Decoder" is a shorthand for a CBOR decoder that
advertises _supporting_ CDE (see the start of this appendix).

1. CDE decoders MUST follow the rules for preferred serialization
   decoders ({{psd}}).

1. CDE decoders MUST check for ordering map keys and for basic
   validity of the CBOR encoding (see {{Section 5.3.1 of
   RFC8949@-cbor}}, which includes a check against duplicate map keys
   and invalid UTF-8).

# Acknowledgments
{:numbered="false"}

An earlier version of this document was based on the work of Wolf
McNally and Christopher Allen as documented in {{-dcbor-orig}}; more
recent revisions of that document now make use of the present document
and the concept of Application Profile.
We would like to explicitly acknowledge that this work has
contributed greatly to shaping the concept of a CBOR Common
Deterministic Encoding and Application Profiles on top of that.
