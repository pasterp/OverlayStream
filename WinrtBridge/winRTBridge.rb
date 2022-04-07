require "fiddle"
require "fiddle/import"
require "base64"
require "observer"

LIB_PATH = Dir.pwd + "/WinrtBridge/WinRTBridge.dll"

module WinRT
  extend Fiddle::Importer

  dlload LIB_PATH
  NO_SESSION = 1
  MUSIC_PLAYING = 2
  ERROR = 3
  CurrentSessionWrapped = struct [
                                   "int status",
                                   "char* SourceAppUserModeId",
                                   "char* title",
                                   "char* artist",
                                   "char* albumArtist",
                                   "char* albumTitle",
                                   "int trackNumber",
                                   "int albumTrackCount",
                                   "char* thumbnail_type",
                                   "void* thumbnail_buffer",
                                   "int thumbnail_size",
                                 ]
  extern "void readCurrentSession(CurrentSessionWrapped* current_session)"

  class BridgeObserver
    def initialize(bridge)
      bridge.add_observer self, :bridge_update
    end

    def bridge_update(time, title, artist, image)
      puts "Now playing #{title} by #{artist}"
    end
  end

  class Bridge < BridgeObserver
    include Observable

    attr_reader :title, :artist, :image

    def initialize
      super(self)
      @session = WinRT::CurrentSessionWrapped.malloc
      @image = nil
    end

    def run
      last_title = nil
      last_artist = nil

      loop do
        # Fetch the session from WinRT
        WinRT.readCurrentSession(@session)
        if @session.status == WinRT::MUSIC_PLAYING
          @title = @session.title.to_s
          @artist = @session.artist.to_s
          # We are playing a song check if it is the last one
          if @session.title.to_s != last_title || @session.artist.to_s != last_artist
            last_title = @title
            last_artist = @artist

            #check for thumbnail
            if (@session.thumbnail_size > 0)
              @image = [@session.thumbnail_type, Base64.encode64(@session.thumbnail_buffer[0, @session.thumbnail_size])]
            else
              @image = nil
            end

            changed
            notify_observers(Time.now, @title, @artist, @image)
          end
        else
          if !last_artist.nil? && !last_title.nil?
            last_artist = nil
            last_title = nil
            notify_observers(Time.now, nil, nil, nil)
          end
        end
        sleep 1
      end
    end
  end
end
