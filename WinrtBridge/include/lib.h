#ifndef _LIB_H
#define _LIB_H

#define DLL_EXPORT __declspec(dllexport)

#include <iostream>
#include <stdlib.h>
// WinRT Stuff
#include <winrt/Windows.Media.Control.h>
#include <winrt/Windows.Storage.Streams.h>  

#pragma comment(lib, "windowsapp")


extern "C" {
    // Structures and types
    enum WrapperStatus {NO_SESSION=1, MUSIC_PLAYING, ERROR};

    typedef struct _CurrentSessionWrapped
    {
        enum WrapperStatus status;
        char* SourceAppUserModeId;
        char* Title;
        char* Artist;
        char* AlbumArtist;
        char* AlbumTitle;
        int TrackNumber;
        int AlbumTrackCount;
        char* Thumbnail_type; 
        void* Thumbnail_buffer;
        int Thumbnail_size;
    } CurrentSessionWrapped;

    // Functions
    DLL_EXPORT void readCurrentSession(CurrentSessionWrapped* current_session);
}

#endif