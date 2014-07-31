require 'test_helper'

class LibraryCloudItemsTest < ActiveSupport::TestCase

  def setup
    @library_cloud_item_api = LibraryCloudItems.new
    @piketty = '013881128'
    @rolling_stone = '000136277'
  end

  test "all items for single hollis id" do
    items = @library_cloud_item_api.everything_for(@piketty)
    assert items.count == 10

    items = @library_cloud_item_api.everything_for(@rolling_stone)
    assert items.count >= 252
  end

  test "counts items" do
    filter = @library_cloud_item_api.hollis_id_filter(@rolling_stone)
    count = @library_cloud_item_api.item_count(filter)
    assert count >= 252

    count = @library_cloud_item_api.count('LAW', 'GEN', @rolling_stone)
    assert count >= 239

    assert @library_cloud_item_api.count('LAM', 'GEN', @piketty) == 4
  end

  test "all items for multiple hollis ids" do
    items = @library_cloud_item_api.everything_for([@piketty, @rolling_stone])
    assert items.count >= 10 + 252
  end

  test "filters items by library code" do
    items = @library_cloud_item_api.items_by_library_code('LAW', @piketty)
    assert items.count == 2

    items = @library_cloud_item_api.items_by_library_code('WID', @piketty)
    assert items.count == 2

    items = @library_cloud_item_api.items_by_library_code('LAW', [@piketty, @rolling_stone])
    assert items.count >= 2 + 240
  end

  test "filters items by library code and collection code" do
    items = @library_cloud_item_api.items_by_library_code_and_collection_code('WID', 'HD', @piketty)
    assert items.count == 1
  end

  test "part of library collection?" do
    items = @library_cloud_item_api.items_by_library_code_and_collection_code('WID', 'HD', @piketty)
    assert @library_cloud_item_api.part_of_library_collection?(items.first, 'WID', 'HD')
    items = @library_cloud_item_api.items_by_library_code_and_collection_code('WID', 'WIDLC', @piketty)
    assert @library_cloud_item_api.part_of_library_collection?(items.first, 'WID', 'WIDLC')
    assert !@library_cloud_item_api.part_of_library_collection?(items.first, 'WID', 'GEN')
    assert !@library_cloud_item_api.part_of_library_collection?(items.first, 'BAK', 'GEN')
  end
end
