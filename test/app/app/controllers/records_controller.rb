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

    record.update(attachment: params[:file])

    render json: record
  end
end
