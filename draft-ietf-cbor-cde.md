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
  I-D.bormann-cbor-dcbor:
    -: dcbor
  I-D.mcnally-deterministic-cbor: dcbor-orig

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

    This document also introduces the concept of Application Profiles,
    which are layered on top of the CBOR CDE Profile and can address
    more application specific requirements.
    To demonstrate how Application Profiles can be built on the CDE,
    a companion document defines the application profile "dCBOR".

--- middle

# Introduction

[^abs1-]


## Conventions and Definitions

{::boilerplate bcp14-tagged}

# CBOR Common Deterministic Encoding Profile (CDE) {#dep}

This specification defines the *CBOR Common Deterministic Encoding
Profile* (CDE) based on the _Core Deterministic Encoding
Requirements_ defined for CBOR in
{{Section 4.2.1 of -cbor}}.

In many cases, CBOR provides more than one way to encode a data item,
but also provides a recommendation for a *Preferred Encoding*.
The *CoRE Deterministic Encoding Requirements* generally pick the
preferred encodings as mandatory; they also pick additional choices
such as definite-length encoding.
Finally, it defines a map ordering based on lexicographic ordering of
the (deterministically) encoded map keys.

Note that this specific set of requirements is elective — in
principle, other variants of deterministic encoding can be defined
(and have been, now being phased out slowly, as detailed in {{Section 4.2.3
of -cbor}}).
In many applications of CBOR today, deterministic encoding is not used
at all, as its restriction of choices can create some additional
performance cost and code complexity.

{{-cbor}}'s core requirements are designed to provide well-understood and
easy-to-implement rules while maximizing coverage, i.e., the subset of
CBOR data items that are fully specified by these rules, and also
placing minimal burden on implementations.

{{Section 4.2.2 of -cbor}} picks up on the interaction of extensibility
(CBOR tags) and deterministic encoding.
CBOR itself uses some tags to increase the range of its basic
generic data types, e.g., tags 2/3 extend the range of basic major
types 0/1 in a seamless way.
{{Section 4.2.2 of -cbor}} recommends handling this transition the same
way as with the transition between different integer representation
lengths in the basic generic data model, i.e., by mandating the
Preferred Encoding ({{Section 3.4.3 of -cbor}}).

{: group="1"}
1. The CBOR Common Deterministic Encoding Profile (CDE) turns this
   recommendation into a mandate: Integers that can be represented by
   basic major type 0 and 1 are encoded using the deterministic
   encoding defined for them, and integers outside this range are
   encoded using the preferred serialization ({{Section 3.4.3 of
   -cbor}}) of tag 2 and 3 (i.e., no leading zero bytes).

Most tags capture more specific application semantics and therefore
may be harder to define a deterministic encoding for.
While the deterministic encoding of their tag internals is often
covered by the _Core Deterministic Encoding Requirements_, the mapping
of diverging platform application data types on the tag contents may
be hard to do in a deterministic way; see {{Section 3.2 of -det}} for
more explanation as well as examples.
As the CDE would continually
need to address additional issues raised by the registration of new
tags, this specification RECOMMENDS that new tag registrations address
deterministic encoding in the context of this Profile.

A particularly difficult field to obtain deterministic encoding for is
floating point numbers, partially because they themselves are often
obtained from processes that are not entirely deterministic between platforms.
See {{Section 3.2.2 of -det}} for more details.
{{Section 4.2.2 of -cbor}} presents a number of choices, which need to
be made to obtain a CBOR Common Deterministic Encoding Profile (CDE).
Specifically, CDE specifies (in the order of the bullet list at the end of {{Section
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
6. The CBOR Common Deterministic Encoding Profile does not presume
   equivalence of floating point values with other representation
   (e.g., tag 4/5) with basic floating point values.

The main intent here is to preserve the basic generic data model, so
Application Profiles can make their own decisions within that data model.
E.g., an application profile can decide that it only ever allows a
single NaN value that would encoded as 0xf97e00, so a CDE
implementation focusing on this application profile would not need to
provide processing for other NaN values.
Basing the definition of both CDE and Application Profiles on the
generic data model of CBOR also means that there is no effect on CDDL
{{-cddl}}, except where the data description documents encoding decision
for byte strings carrying embedded CBOR.

# Application Profiles

While the CBOR Common Deterministic Encoding Profile (CDE) provides
for commonality between different applications of CBOR, it is useful
to further constrain the set of data items handled in a group of
applications (_exclusions_) and to define further mappings
(_reductions_) that help the applications in such a group get by with
the exclusions.

For example, the dCBOR Application Profile specifies the use of
Deterministic Encoding as defined in {{Section 4.2 of STD94}} (see also
{{-det}} for more information) together with some application-level rules.
See {{-dcbor}} for a definition of the dCBOR Application Profile that
makes use of CDE.

In general, the application-level rules specified by an Application Profile are
based on the same CBOR Common Deterministic Encoding Profile; they do
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


# CDDL support

{{-cddl}} defines control operators to indicate that the contents of a
byte string carries a CBOR-encoded data item (`.cbor`) or a sequence of
CBOR-encoded data items (`.cborseq`).

CDDL specifications may want to specify that the data items should be
encoded in Common CBOR Deterministic Encoding.
This specification adds two CDDL control operators that can be used
for this.

The control operators `.cde` and `.cdeseq` are exactly like `.cbor` and
`.cborseq` except that they also require the encoded data item(s) to be
in Common CBOR Deterministic Encoding.

For example, a byte string of embedded CBOR that is to be encoded
according to CDE can be formalized as:

~~~
leaf = #6.24(bytes .cde any)
~~~

More importantly, if the encoded data item also needs to have a
specific structure, this can be expressed by the right hand side
(instead of using the most general CDDL type `any` here).

(Note that the ...`seq` control operator does not enable specifying
different deterministic encoding requirements for the elements of the
sequence.  If a use case for such a feature becomes known, it could be
added.)


Obviously, Application Profiles can define similar control operators
that also embody the processing required by the Application Profile,
and are encouraged to do so.


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
| .cde      | \[RFCXXXX] |
| .cdeseq   | \[RFCXXXX] |
{: #tbl-iana-reqs title="New control operators to be registered"}


--- back

# Acknowledgments
{:numbered="false"}

An earlier version of this document was based on the work of Wolf
McNally and Christopher Allen as documented in {{-dcbor-orig}}; the
parts directly based on this are
now separated out as the dCBOR Application Profile {{-dcbor}}.
Nonetheless, we acknowledge that this work has contributed greatly to
shaping the concept of a CBOR Common Deterministic Encoding and
Application Profiles on top of that.
