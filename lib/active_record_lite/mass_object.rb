class MassObject
  @attributes = []
  # takes a list of attributes.
  # creates getters and setters.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
    instance_variable_set("@attributes", attributes)
  end

  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    objs = []
    results.each do |hash|
      objs << self.new(hash)
    end
    objs
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  # mass_object = MyMassObject.new("x" => :x_val, "y" => :y_val)
#   mass_object.x.should == :x_val
  def initialize(params = {})

    params.each do |k,v|
      raise 'cannot' unless self.class.attributes.include?(k.to_sym)

      self.class.send(:define_method,k.to_sym) do
        instance_variable_get("@#{k}")

      end
      self.class.send(:define_method,"#{k}=".to_sym) do |v|
        instance_variable_set("@#{k}", v)
      end

      self.send("#{k}=".to_sym, v)

    end

  end
end