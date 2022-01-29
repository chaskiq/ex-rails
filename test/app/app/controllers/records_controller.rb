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

    new_attachment =
      case Record.attachment_reflections[params[:attachment_name]]
      when ActiveStorage::Reflection::HasOneAttachedReflection
        record.update({params[:attachment_name] => params[:file]})
      when ActiveStorage::Reflection::HasManyAttachedReflection
        record.send(params[:attachment_name]).attach(params[:file])
      end

    render json: new_attachment
  end
end
