require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follwer_id" do
    @relationship.follower_id  = nil
    assert_not @relationship.valid?
  end

  test "should require a followd_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
end
