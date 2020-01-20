class TestTakersController < ApplicationController
  def index
    @per_page = 4
    $offset = params[:page]
    config_file_path = File.join(Rails.root, 'config', 'config.yml')
    raise 'config file not present' unless File.exist?(config_file_path)

    config = YAML.load_file(config_file_path)
    datasource_file_path = config[0]['data_file'][0]['name'].join
    datasource_complete_path = "Rails.public_path}/data_source/#{datasource_file_path}"

    unless File.exist?(datasource_complete_path)
      raise 'wrong file name present in config file'
    end

    file = File.open(datasource_complete_path, 'r')

    listener = Listen.to("#{Rails.public_path}/data_source") do |modified, added, removed|
      file = File.open(datasource_complete_path, 'r')
      fetch_data(file)
      ActionCable.server.broadcast "room_channel", content: @records.to_json
    end

    listener.start
    fetch_data(file)
  end

  def fetch_data(file)
    records = construct_data(file)
    @records = Kaminari.paginate_array(records).page($offset).per(@per_page)
  end

  def construct_data(file)
    file_type = File.extname(file)

    case file_type
    when '.csv'
      csv = CSV.open(file, headers: true)
      csv.to_a.map(&:to_hash)
    when '.json'
      JSON.load file
    else
      raise 'File type not correct or write code for file reading of provided file-type'
    end
  end
end
