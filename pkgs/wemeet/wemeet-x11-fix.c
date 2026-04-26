/*
 * wemeet-x11-fix.c
 *
 * This library intercepts X11 functions that cause crashes in Wayland mode.
 * Specifically, it prevents XSetInputFocus from crashing when called in
 * pure Wayland environment.
 *
 * Compile: gcc -shared -fPIC -o libwemeet-x11-fix.so wemeet-x11-fix.c -ldl
 * Usage: LD_PRELOAD=./libwemeet-x11-fix.so wemeet
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int (*orig_XSetInputFocus)(Display*, Window, int, Time) = NULL;

int XSetInputFocus(Display *display, Window focus, int revert_to, Time time) {
    const char *session_type = getenv("XDG_SESSION_TYPE");
    const char *wayland_display = getenv("WAYLAND_DISPLAY");

    if ((session_type && strcmp(session_type, "wayland") == 0) || wayland_display) {
        fprintf(stderr, "wemeet-x11-fix: Blocking XSetInputFocus in Wayland mode\n");
        return Success;
    }

    if (!orig_XSetInputFocus) {
        orig_XSetInputFocus = dlsym(RTLD_NEXT, "XSetInputFocus");
        if (!orig_XSetInputFocus) {
            fprintf(stderr, "wemeet-x11-fix: Failed to load XSetInputFocus\n");
            return BadWindow;
        }
    }

    return orig_XSetInputFocus(display, focus, revert_to, time);
}

__attribute__((constructor))
static void init_x11_fix(void) {
    fprintf(stderr, "wemeet-x11-fix: Loaded X11 compatibility fix for Wayland\n");
}
