shared_examples_for "gridified models" do
    before(:all) do  
      @subjects = []
      5.times do 
        @subjects << Factory.create(subject.to_s.downcase.intern)
      end
    end

    it "should respond to the custom named scopes" do
      subject.class.should respond_to(:find_for_grid)
      subject.class.should respond_to(:gridified)
    end

    it "should gridify params properly" do
      subject.class.gridified(:grid, {}).count.should == @subjects.count
    end
end

shared_examples_for "gridified controllers" do
  # it "should respond with xml to grid queries" do 
  #   get :index, {:grid => "grid"}
  #   response.should be_success
  #   response.should have_tag('contacts', nil, :xml => true, :strict => true)
  # end
  it "should return page totals and number with grid queries"
  it "should allow paging through the pages of a grid query"
  it "should allow searching of a grid query"
end

shared_examples_for "tested object" do
  before(:each) do
    puts subject.class
  end
  it "shouldn't error" do
    puts subject.class
  end
end