require 'test_helper'

class LibraryCloudTest < ActiveSupport::TestCase

  def setup
    @api = LibraryCloud.new
  end

  test "build result" do
    library = 'MUS'
    coll = 'GEN'
    start_num = 'ML410.T173 A3 2013'
    end_num = 'ML410.V4 P58 2004'

  #  result = @api.pages_in_range(library, coll, start_num, end_num)
  #  puts result.inspect
  end

  test "call number to sort number" do
    call_num = 'QP501 .A7'
    sort_num = 9669356
    assert @api.call_num_to_sort_num(call_num) == sort_num

    call_num = 'ML410.T173 A3 2013'
    sort_num = 6278895
    assert @api.call_num_to_sort_num(call_num) == sort_num
  end

  test "total records" do
    start_num = 'ML410.T173 A3 2013'
    end_num = 'ML410.V4 P58 2004'
    assert @api.total_records('MUS', start_num, end_num) >= 670
  end

  test "has library records" do
    assert @api.has_library_records?('MUS')
    assert @api.has_library_records?('WID')
    assert !@api.has_library_records?('ASDF')
  end

  test "record call numbers" do
    start_num = 'ML410.A165 D5 2006'
    end_num = 'ML410.A2 M2 1982'

    # start and end nums are not included because they're in HD
    records = @api.records_in_range('MUS', 'HD', start_num, end_num)
    call_nums = ["ML410.A2 K49 1996", "ML410.A17 H87 2005"]
    output_call_nums = []
    records.each do |record|
      output_call_nums += @api.record_call_numbers(record)
    end
    assert call_nums.sort == output_call_nums.sort
  end

  test "normalize call num" do
    input = ['ML410.T173 A3 2013', 'ML410.T1768 P8 1960']
    expected_output = ['ML0410 T173 A3  02013','ML0410 T1768 P8  01960']
    assert @api.normalize_call_num(input) == expected_output
    assert @api.normalize_call_num('ML410.T173 A3 2013') == 'ML0410 T173 A3  02013'
  end

  test "filter records by range" do
    start_call_num= 'ML410.A165 D5 2006'
    end_call_num = 'ML410.A2 M2 1982'
    filter = @api.library_and_range_filter('MUS', start_call_num, end_call_num)
    records = @api.all_records(filter)
    @api.add_item_data!(records)
    @api.filter_records_by_range!(records, start_call_num, end_call_num)

    output_call_nums = []
    records.each do |record|
      output_call_nums += @api.record_call_numbers(record)
    end
    expected_output = [
      "ML410.A2 K49 1996", "ZHCL Mus1220.5.53", "ML410.A2 M2 1982",
      "ML410.A17 H87 2005", "ML410.A165 D5 2006"
    ]
    assert output_call_nums.sort == expected_output.sort
  end

  test "wildcardize" do
    call_nums = [
      'ML410.T173 A3 2013',
      'ML410 .T173 A3 2013',
      'ML410.T173 A3 2013',
      'ML410 . T173 A3 2013'
    ]
    call_nums.each do |call_num|
      wildcarded = @api.wildcardize(call_num)
      assert wildcarded == 'ML410*.*T173*A3*2013'
    end
  end
end
