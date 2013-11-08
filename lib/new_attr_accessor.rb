class Object
  def new_attr_accessor( *symbols )
    symbols.each do | symbol |
      define_method(symbol) do
        instance_variable_get("@#{symbol}")

      end
      define_method("#{symbol}=") do |i|
        instance_variable_set("@#{symbol}", i)
      end
    end
  end
end
class Cat
  new_attr_accessor :name

  private
    attr_accessor :color


end