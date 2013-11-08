#require 'rspec'
require 'new_attr_accessor'

describe Cat do
  subject(:cat) do
    Cat.new
  end

  describe "#name" do
    it "can set name by new_attr_accessor" do
      cat.name ="Salli"
      expect(cat.name).to eq("Salli")
    end
  end
  describe "#color" do
    it "can set color by new_attr_accessor" do
      cat.color ="Brown"
      expect(cat.color).to eq("Brown")
    end
  end
end
