#include "lib.h"

using namespace winrt;
using namespace Windows::Media::Control;
using namespace Windows::Storage::Streams;

#define LIB_TAG "[WinRT] "
#define LIB_DEBUG_
void log(const char* msg){
    #ifdef LIB_DEBUG
    std::cout << LIB_TAG << msg  << std::endl;
    #endif
}

char* alloc_wcstcs(winrt::hstring source){
    char* string_alloc = (char*) malloc((source.size()+1) * sizeof(char));
    wcstombs(string_alloc, source.c_str(), source.size()+1 );
    return string_alloc;
}

void readCurrentSession(CurrentSessionWrapped* cs){
    auto SessionManager = GlobalSystemMediaTransportControlsSessionManager::RequestAsync().get();
       
    auto session = SessionManager.GetCurrentSession();

    if(session != nullptr){
        log("Session found");
        cs->status = WrapperStatus::MUSIC_PLAYING;

        cs->SourceAppUserModeId = alloc_wcstcs(session.SourceAppUserModelId());

        auto info = session.TryGetMediaPropertiesAsync().get();
        
        cs->Title = alloc_wcstcs(info.Title());
        cs->Artist = alloc_wcstcs(info.Artist());
        cs->AlbumArtist = alloc_wcstcs(info.AlbumArtist());
        cs->AlbumTitle = alloc_wcstcs(info.AlbumTitle());
        cs->TrackNumber = info.TrackNumber();
        cs->AlbumTrackCount = info.AlbumTrackCount();
        
        if(info.Thumbnail()){
            auto thumbnail_stream = info.Thumbnail().OpenReadAsync().get();
        
            cs->Thumbnail_type = alloc_wcstcs(thumbnail_stream.ContentType());
            
            Buffer buffer = Buffer(thumbnail_stream.Size());
            thumbnail_stream.ReadAsync(buffer, buffer.Capacity(), InputStreamOptions::ReadAhead).get();
            
            cs->Thumbnail_buffer = malloc(buffer.Length());
            memcpy(cs->Thumbnail_buffer, buffer.data(), buffer.Length());
            cs->Thumbnail_size = buffer.Length();
    
        }else{
            log("No thumbnail");
            cs->Thumbnail_size = 0;
        }
    }else{
        log("No music playing");
        cs->status = WrapperStatus::NO_SESSION;
    }
}
