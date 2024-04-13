#include <shlobj.h>
#include <stdio.h>

void all_startup(void)
{
    char path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_ALTSTARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_ALTSTARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_STARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_STARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
}

void all_programs(void)
{
    char path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAMS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_PROGRAMS, NULL, 0, path))) {
        printf("%s\n", path);
    }
}

void all(void)
{
    char path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_DESKTOP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROFILE, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROFILE, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_ADMINTOOLS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_ALTSTARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_APPDATA, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_BITBUCKET, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_CDBURN_AREA, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_ADMINTOOLS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_ALTSTARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_DESKTOPDIRECTORY, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_DOCUMENTS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_FAVORITES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_MUSIC, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_OEM_LINKS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_PICTURES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_PROGRAMS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_STARTMENU, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_STARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_TEMPLATES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_VIDEO, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMPUTERSNEARME, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_CONNECTIONS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_CONTROLS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COOKIES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_DESKTOPDIRECTORY, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_DRIVES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_FAVORITES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_FONTS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_HISTORY, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_INTERNET, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_INTERNET_CACHE, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_LOCAL_APPDATA, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYDOCUMENTS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYMUSIC, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYPICTURES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYVIDEO, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_NETHOOD, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_NETWORK, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PERSONAL, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PRINTERS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PRINTHOOD, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAMS, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILESX86, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES_COMMON, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES_COMMONX86, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_RECENT, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_RESOURCES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_RESOURCES_LOCALIZED, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SENDTO, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_STARTMENU, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_STARTUP, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SYSTEM, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SYSTEMX86, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_TEMPLATES, NULL, 0, path))) {
        printf("%s\n", path);
    }
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_WINDOWS, NULL, 0, path))) {
        printf("%s\n", path);
    }
}

int main(int argc, char *argv[])
{
    if (argc == 1) {
        all();
        return 0;
    }
    char path[MAX_PATH];
    if (strcmp(argv[1], "desktop") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_DESKTOP, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "home") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROFILE, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "profile") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROFILE, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "admintools") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_ADMINTOOLS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "altstartup") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_ALTSTARTUP, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "appdata") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_APPDATA, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "bitbucket") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_BITBUCKET, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "cdburn_area") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_CDBURN_AREA, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_admintools") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_ADMINTOOLS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_altstartup") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_ALTSTARTUP, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_appdata") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_desktopdirectory") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_DESKTOPDIRECTORY, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_documents") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_DOCUMENTS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_favorites") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_FAVORITES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_music") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_MUSIC, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_oem_links") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_OEM_LINKS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_pictures") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_PICTURES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_programs") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_PROGRAMS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_startmenu") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_STARTMENU, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_startup") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_STARTUP, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_templates") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_TEMPLATES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "common_video") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_VIDEO, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "computersnearme") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMPUTERSNEARME, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "connections") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_CONNECTIONS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "controls") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_CONTROLS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "cookies") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COOKIES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "desktopdirectory") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_DESKTOPDIRECTORY, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "drives") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_DRIVES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "favorites") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_FAVORITES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "fonts") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_FONTS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "history") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_HISTORY, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "internet") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_INTERNET, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "internet_cache") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_INTERNET_CACHE, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "local_appdata") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_LOCAL_APPDATA, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "mydocuments") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYDOCUMENTS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "mymusic") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYMUSIC, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "mypictures") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYPICTURES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "myvideo") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYVIDEO, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "nethood") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_NETHOOD, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "network") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_NETWORK, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "personal") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PERSONAL, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "printers") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PRINTERS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "printhood") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PRINTHOOD, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "programs") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAMS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "program_files") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "program_filesx86") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILESX86, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "program_files_common") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES_COMMON, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "program_files_commonx86") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES_COMMONX86, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "recent") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_RECENT, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "resources") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_RESOURCES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "resources_localized") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_RESOURCES_LOCALIZED, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "sendto") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SENDTO, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "startmenu") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_STARTMENU, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "startup") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_STARTUP, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "system") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SYSTEM, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "systemx86") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SYSTEMX86, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "templates") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_TEMPLATES, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "windows") == 0) {
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_WINDOWS, NULL, 0, path))) {
            printf("%s\n", path);
        }
    } else if (strcmp(argv[1], "all_startup") == 0) {
        all_startup();
    } else if (strcmp(argv[1], "all_programs") == 0) {
        all_programs();
    } else if (strcmp(argv[1], "all") == 0) {
        all();
    } else {
    }
    return 0;
}
