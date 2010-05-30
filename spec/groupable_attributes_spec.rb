require File.dirname(__FILE__) + '/spec_helper'

class GroupableAttributesTestModel < ActiveRecord::Base
  attribute_collection :restricted, [:name, :email]
end

describe ActiveRecord::Base, "#attribute_collection" do
  it "should collect the given attributes and none else" do
    restricted = {:name => "Paul", :email => "paul@example.com"}
    params = restricted.merge(:content => "blub")
    assert GroupableAttributesTestModel.new(params).restricted == restricted
  end
end