require "spec_helper"

describe VIXAL::Price, "#from_f" do
  subject{ VIXAL::Price }
  let(:seed){ 225571644875421139403973254661022579608 } #generated using Random.new
  let(:random){ Random.new(seed) } 
  let(:iterations){ ENV["SMOKE_ITERATIONS"].present? ? ENV["SMOKE_ITERATIONS"].to_i : 2000}

  it "withstands a random smoke test" do
    iterations.times do |i|
      expected = random.rand
      actual_p = subject.from_f(expected)
      actual = actual_p.to_f

      expect(actual).to be_within(0.000000001).of(actual)
      expect(actual_p.n).to be <= VIXAL::Price::MAX_PRECISION
      expect(actual_p.d).to be <= VIXAL::Price::MAX_PRECISION
    end
  end

  it "works with bigdecimal" do
      whole      = random.rand(1_000_000)
      fractional = random.rand(10_000_000) # seven significant digits available for fractional
      
      expected = BigDecimal.new("#{whole}.#{fractional}")
      actual_p = subject.from_f(expected)
      actual = BigDecimal.new(actual_p.n) / BigDecimal.new(actual_p.d) 

      expect(actual).to be_within(BigDecimal.new("0.000000001")).of(actual)
      expect(actual_p.n).to be <= VIXAL::Price::MAX_PRECISION
      expect(actual_p.d).to be <= VIXAL::Price::MAX_PRECISION
  end

end
