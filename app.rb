# Steps:
# Read state of the media manager (artist - title - platform ?) TODO: platform (process exe ?)
# Recover the image to display it
# Render a html page with the title and the image
# Cache the result if no change (+ scrolling ?)

require "sinatra/base"
require "json"
require_relative "WinrtBridge/winRTBridge"

$bridge = WinRT::Bridge.new
Thread.new {
  $bridge.run
}

class ApplicationController < Sinatra::Base
  configure do
    set server: "thin", connections: []
    set :raise_errors, true

    set :public_folder, "public"
    set :views, "app/views"
  end

  def initialize
    super
    @music_title = $bridge.title
    @music_artist = $bridge.artist
    @music_image = $bridge.image

    $bridge.add_observer self, :bridge_update
  end

  def bridge_update(time, title, artist, image)
    @music_title = title
    @music_artist = artist
    @music_image = image

    update = {
      :title => title,
      :artist => artist,
      :image_type => image.first,
      :image => image.last,
    }

    settings.connections.each { |out| out << "data: #{update.to_json}\n\n" }
  end

  get "/" do
    @title = @music_title || "Hello world"
    haml :index
  end

  get "/stream", provides: "text/event-stream" do
    stream :keep_open do |out|
      settings.connections << out
      out.callback { settings.connections.delete(out) }
    end
  end

  get "/sass/*.css" do
    content_type "text/css", :charset => "utf-8"
    filename = params[:splat].first
    sass filename.to_sym, :views => "app/assets/sass"
  end
end

ApplicationController.run!
