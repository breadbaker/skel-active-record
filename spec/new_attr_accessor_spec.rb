#require 'rspec'
require 'new_attr_accessor'

describe Cat do
  subject(:cat) do
    Cat.new
  end
  describe "can call accessors" do
    it "has methods name and color" do
      expect(cat.respond_to?(:name)).to eq(true)
      expect(cat.respond_to?(:color)).to eq(true)
    end
  end

  describe "does not" do
    it "can set color" do
      cat.color ="Brown"
      expect(cat.color).to eq("Brown")
    end
  end
  before do
    cat.name ="Salli"
    cat.color ="Brown"
  end



  describe "#name" do
    it "can set name" do
      expect(cat.name).to eq("Salli")
    end
  end
  describe "#color" do
    it "can set color" do
      expect(cat.color).to eq("Brown")
    end
  end

end
