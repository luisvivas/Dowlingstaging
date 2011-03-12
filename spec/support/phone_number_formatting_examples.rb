shared_examples_for "formatted phone number models" do
  before(:all) do
    @attributes = [:telephone, :cell_phone, :home_phone, :mobile, :fax].delete_if {|key| !subject.respond_to?(key) }
    @attributes.should_not == []
    @numbers = [{ :unformatted => "(123) 456 7890"  , :stripped => "1234567890", :formatted => "(123) 456-7890"},
                { :unformatted => "(123) 456-7891"  , :stripped => "1234567891", :formatted => "(123) 456-7891"},
                { :unformatted => "(111) 222 - 3333", :stripped => "1112223333", :formatted => "(111) 222-3333"},
                { :unformatted => "1112224444"      , :stripped => "1112224444", :formatted => "(111) 222-4444"},
                { :unformatted => "(123) 321 4567 ext 4222", :stripped => "12332145674222", :formatted => "(123) 321-4567 x 4222"}]
  end
  
  it "should respond to each one of the keys" do
    subject.should respond_to(:strip_phonenumbers)
    subject.should respond_to(:format_phonenumbers)
  end
  
  it "should properly strip phone numbers" do
    @model = Factory.build(subject.class.name.downcase.to_sym)
    @attributes.each do |a|
      @numbers.each do |f|
        @model.send(a.to_s+"=", f[:unformatted])
        @model.strip_phonenumbers
        @model.send(a).should == f[:stripped]
      end
    end
  end
  
  it "should properly format phone numbers from the database" do
    @model = Factory.build(subject.class.name.downcase.to_sym)
    @attributes.each do |a|
      @numbers.each do |f|
        @model.send(a.to_s+"=", f[:stripped])
        @model.format_phonenumbers
        @model.send(a).should == f[:formatted]
      end
    end
  end
  
  it "should strip each one of the keys upon saving and properly format after" do
    @attributes.each do |a|
      @model = Factory.build(subject.class.name.downcase.to_sym)
      @numbers.each do |f|
        @model.send(a.to_s+'=', f[:unformatted])
        @model.should_receive(:format_phonenumbers).once
        @model.should_receive(:strip_phonenumbers).once
        @model.save!
      end
    end
  end
  
  it "should format each one of the keys after finding" do
    @attributes.each do |a|
      [["(123) 456-7890", "1234567890"], ["(122) 446-7890", "1224467890"], ["(111) 222-3333", "1112223333"], ["(111) 222-4444", "1112224444"]].each do |f|
        @model = Factory.build(subject.class.name.downcase.to_sym, a => f[1])
        @model.save!
        @model.send(a).should == f[0]
      end
    end
  end
end