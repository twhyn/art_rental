class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :get_current_artist

  def authenticate_artist!
    render json: {message: "Unauthorize"} if current_artist.nil?
  end

  def get_current_artist
    return nil unless cookies[:authHeaders]
    auth_headers = JSON.parse cookies[:authHeaders]

    expiration_datetime = DateTime.strptime(auth_headers["expiry"], "%s")
    current_artist = Artist.find_by(uid: auth_headers["uid"])

    if current_artist &&
       current_artist.tokens.has_key?(auth_headers["client"]) &&
       expiration_datetime > DateTime.now

      @current_artist = current_artist
    end
    @current_artist ||= Rentee.find_by(uid: auth_headers["uid"])
  end
end