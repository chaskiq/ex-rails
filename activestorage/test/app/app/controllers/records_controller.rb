class RecordsController < ApplicationController
  def index
    render json: {}
  end

  def create
    record = Record.create

    render json: record
  end

  def add_attachment
    record = Record.find(params[:id])

    new_attachment = record.send(params[:attachment_name]).attach(params[:file])

    new_attachment = [record.send(params[:attachment_name])].flatten.last

    # puts "attachment: #{attachment.to_json.inspect}"

    render json: {
      attachment: new_attachment,
      url: (new_attachment.url rescue nil),
    }
  end
end
