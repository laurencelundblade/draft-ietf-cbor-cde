require 'cbor-deterministic'
require 'cbor-dcbor'
Range1 = [-2**63..2**64-1, "Speculative \"dCBOR-wide1\" application profile"]
Range2 = [-2**127..2**128-1, "Speculative \"dCBOR-wide2\" application profile"]

class String
  def hexi
    bytes.map{|x| "%02X" % x}.join
  end
end

def reduce(val, range)
  if Float === val
    intval = val.to_i
    if intval == val && range === intval
      intval
    end
  end
end

def yn(bool)
  bool ? "✓" : "👎"
end

values = [0, 0.0, -0.0, 4.0, -4.0,
          1e19, -1e19, 10**19, -10**19,
          1e38, -1e38, 10**38, -10**38,
         ]

ranges = [Range1, Range2]
range1 = Range1[0]

num = 0

ranges.each do |range, title|

  name = "tab-wide#{num = num.succ}"

  $stdout.reopen(name, "w")

  puts "| Application data   Numeric reduction (if any)   Encoding via CDE | dCBOR?"

  values.each do |val|
    redval = reduce(val, range)
    dval = redval || val
    deval = dval.to_deterministic_cbor
    dhex = deval.hexi
    dchex = val.to_dcbor.hexi
    dcbor_ok = Float === val || range1 === val
    puts "| `#{val}` <br/>  `#{redval || "—"}` <br/> `#{dhex}` | #{yn(dcbor_ok)} <br/> #{"💣" if dcbor_ok && val.to_dcbor != deval } "
  end
  puts "{: ##{name} title=#{title.inspect}}"
  puts

end

