/* This example displays a picture on the screen, with support for
 * command-line parameters, multi-screen, screen-orientation and
 * zooming.
 */
#include <stdio.h>
#include <stdlib.h>
#include "allegro5/allegro.h"
#include "allegro5/allegro_image.h"

#ifdef ALLEGRO_ANDROID
   #include "allegro5/allegro_android.h"
#endif

void init_platform_specific(void)
{
#ifdef ALLEGRO_ANDROID
   al_install_touch_input();
   al_android_set_apk_file_interface();
#endif
}

void abort_example(char const *format, ...)
{
   va_list args;
   va_start(args, format);
   vfprintf(stderr, format, args);
   va_end(args);
   exit(1);
}

int main(int argc, char **argv)
{
    const char *filename;
    ALLEGRO_DISPLAY *display;
    ALLEGRO_BITMAP *bitmap;
    ALLEGRO_TIMER *timer;
    ALLEGRO_EVENT_QUEUE *queue;
    bool redraw = true;
    double zoom = 1;
    int w, h, dw, dh;

    /* The first commandline argument can optionally specify an 
     * image to display instead of the default. Allegro's image
     * addon supports BMP, DDS, PCX, TGA and can be compiled with
     * PNG and JPG support on all platforms. Additional formats
     * are supported by platform specific libraries and support for
     * image formats can also be added at runtime.
     */
    if (argc > 1) {
       filename = argv[1];
    }
    else {
       filename = "tinslogo06.png";
    }

    if (!al_init()) {
       abort_example("Could not init Allegro.\n");
    }

    /* The second parameter to the process can optionally specify what 
     * adapter to use.
     */
    if (argc > 2) {
       al_set_new_display_adapter(atoi(argv[2]));
    }

    /* Allegro requires installing drivers for all input devices before
     * they can be used.
     */
    al_install_mouse();
    al_install_keyboard();

    /* Initialize the image addon. Requires the allegro_image addon
     * library.
     */
    al_init_image_addon();

    // Helper functions from common.c.
    init_platform_specific();

    // Create a new display that we can render the image to.
    display = al_create_display(640, 480);
    if (!display) {
       abort_example("Error creating display\n");
    }
    dw = al_get_display_width(display);
    dh = al_get_display_height(display);
    
    al_set_window_title(display, filename);
    
    // Load the image and time how long it took for the log.
    bitmap = al_load_bitmap(filename);
    if (!bitmap) {
       abort_example("%s not found or failed to load\n", filename);
    }
    w = al_get_bitmap_width(bitmap);
    h = al_get_bitmap_height(bitmap);

    // Create a timer that fires 30 times a second.
    timer = al_create_timer(1.0 / 30); 
    queue = al_create_event_queue();
    al_register_event_source(queue, al_get_keyboard_event_source()); 
    al_register_event_source(queue, al_get_display_event_source(display));
    al_register_event_source(queue, al_get_timer_event_source(timer));
    al_start_timer(timer); // Start the timer

    // Primary 'game' loop.
    while (1) {
        ALLEGRO_EVENT event;
        al_wait_for_event(queue, &event); // Wait for and get an event.
        if (event.type == ALLEGRO_EVENT_DISPLAY_CLOSE)
            break;
        /* Use keyboard to zoom image in and out.
         * 1: Reset zoom.
         * +: Zoom in 10%
         * -: Zoom out 10%
         * f: Zoom to width of window
         */
        if (event.type == ALLEGRO_EVENT_KEY_CHAR) {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                break; // Break the loop and quite on escape key.
            if (event.keyboard.unichar == '1')
                zoom = 1;
            if (event.keyboard.unichar == '+' || event.keyboard.keycode == ALLEGRO_KEY_EQUALS)
                zoom *= 1.1;
            if (event.keyboard.unichar == '-')
                zoom /= 1.1;
            if (event.keyboard.unichar == 'f')
                zoom = (double)dw / w;
        }

        // Trigger a redraw on the timer event
        if (event.type == ALLEGRO_EVENT_TIMER)
            redraw = true;
            
        // Redraw, but only if the event queue is empty
        if (redraw && al_is_event_queue_empty(queue)) {
            redraw = false;
            // Clear so we don't get trippy artifacts left after zoom.
            al_clear_to_color(al_map_rgb_f(1, 1, 1));

            if (zoom == 1)
                al_draw_bitmap(bitmap, (dw - w) / 2, (dh - h) / 2, 0);
            else {
                double zw = (double)w * zoom;
                double zh = (double)h * zoom;
                al_draw_scaled_bitmap(
                    bitmap, 0, 0, w, h, (dw - zw) / 2, (dh - zh) / 2, zw, zh, 0);
            }
            al_flip_display();
        }
    }

    al_destroy_bitmap(bitmap);

    return 0;
}
