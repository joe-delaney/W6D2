class AttrAccessorObject
  def self.my_attr_accessor(*names)
    #Create a getter and setter for each variable name passed in
    names.each do |name|
      define_method(name) { instance_variable_get("@#{name}")}
      define_method("#{name}=") do |set_value|
        instance_variable_set("@#{name}", set_value)
      end
    end
  end
end
