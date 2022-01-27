class ApplicationController < ActionController::Base
  # Only using this app in the context of the Elixir library tests
  skip_before_action :verify_authenticity_token
end
