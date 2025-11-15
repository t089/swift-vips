//
//  Header.h
//  
//
//  Created by Tobias on 28.06.21.
//

#ifndef C_vips_shim_h
#define C_vips_shim_h

#include "glib.h"
#include <termios.h>
#include <vips/vips.h>

VipsImage* shim_vips_image_new_from_source(VipsSource *source, const char* options);

gint shim_g_object_get_ref_count(GObject* object);

gboolean shim_g_is_object(const void * p);

GObject* shim_g_object(const void * p);

GType shim_g_object_type(const void * p);

VipsImage* shim_vips_image(const void * p);

VipsObject* shim_vips_object(const void *p);

VipsArea* shim_vips_area(const void *p);

int shim_vips_getpoint(void *image, double **values, int *n, int x, int y);

GType shim_g_type_boolean();

GType shim_G_TYPE_STRING();

GType shim_G_TYPE_DOUBLE();

GType shim_VIPS_TYPE_ARRAY_DOUBLE();

GType shim_VIPS_TYPE_ARRAY_INT();

double* shim_vips_array_double(void *p, int n);

GType shim_G_TYPE_INT();

GType shim_VIPS_TYPE_BLOB();

GCallback shim_G_CALLBACK(void *f);

VipsSource* shim_VIPS_SOURCE(void *p);

VipsTarget* shim_VIPS_TARGET(void *p);

gulong shim_g_signal_connect(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data);

int
shim_vips_exif_tag_to_int(VipsImage *image, const char *tag);

const char *
shim_vips_exif_tag(VipsImage *image, const char *tag);

int
shim_vips_exif_orientation(VipsImage *image);

static const char *SHIM_VIPS_META_ICC_NAME = VIPS_META_ICC_NAME;

static const char *EXIF_IFD0_ORIENTATION = "exif-ifd0-Orientation";

int shim_vips_copy_interpretation(VipsImage *in, VipsImage **out, VipsInterpretation interpretation);

VipsImage *
shim_vips_image_new_from_file( const char *name, VipsAccess access, gboolean inMemory);


int shim_vips_major_version();

const char* shim_vips_version();

#if VIPS_MAJOR_VERSION >= 8
#if VIPS_MINOR_VERSION >= 18
#define SHIM_VIPS_VERSION_8_18
#endif
#if VIPS_MINOR_VERSION >= 17
#define SHIM_VIPS_VERSION_8_17
#endif
#if VIPS_MINOR_VERSION >= 16
#define SHIM_VIPS_VERSION_8_16
#endif
#if VIPS_MINOR_VERSION >= 15
#define SHIM_VIPS_VERSION_8_15
#endif
#if VIPS_MINOR_VERSION >= 14
#define SHIM_VIPS_VERSION_8_14
#endif
#if VIPS_MINOR_VERSION >= 13
#define SHIM_VIPS_VERSION_8_13
// VipsSource helper functions
const char* shim_vips_connection_filename(VipsSource *source);
const char* shim_vips_connection_nick(VipsSource *source);
gint64 shim_vips_source_read_position(VipsSource *source);
gint64 shim_vips_source_length_internal(VipsSource *source);
gboolean shim_vips_source_decode_status(VipsSource *source);
gboolean shim_vips_source_is_pipe(VipsSource *source);

#endif
#endif

// VipsSaveable backwards compatibility shim
// In libvips 8.17.0, VipsSaveable was removed and replaced with VipsForeignSaveable.
// In 8.17.3+, they added macros for backwards compatibility, but Swift can't import
// macros that use bitwise OR operations. We provide simple constant getters that work
// across all versions: pre-8.17 (native enum), 8.17.0-8.17.2 (VipsForeignSaveable),
// and 8.17.3+ (backwards compat macros).

// Getter functions that Swift can import
static inline int shim_VIPS_SAVEABLE_MONO(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    // For 8.17+, use the macro if available, otherwise VipsForeignSaveable
    #ifdef VIPS_SAVEABLE_MONO
        return VIPS_SAVEABLE_MONO;
    #else
        return VIPS_FOREIGN_SAVEABLE_MONO;
    #endif
#else
    // For pre-8.17, use the native enum
    return VIPS_SAVEABLE_MONO;
#endif
}

static inline int shim_VIPS_SAVEABLE_RGB(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    #ifdef VIPS_SAVEABLE_RGB
        return VIPS_SAVEABLE_RGB;
    #else
        return VIPS_FOREIGN_SAVEABLE_MONO | VIPS_FOREIGN_SAVEABLE_RGB;
    #endif
#else
    return VIPS_SAVEABLE_RGB;
#endif
}

static inline int shim_VIPS_SAVEABLE_RGBA(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    #ifdef VIPS_SAVEABLE_RGBA
        return VIPS_SAVEABLE_RGBA;
    #else
        return VIPS_FOREIGN_SAVEABLE_MONO | VIPS_FOREIGN_SAVEABLE_RGB | VIPS_FOREIGN_SAVEABLE_ALPHA;
    #endif
#else
    return VIPS_SAVEABLE_RGBA;
#endif
}

static inline int shim_VIPS_SAVEABLE_RGBA_ONLY(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    #ifdef VIPS_SAVEABLE_RGBA_ONLY
        return VIPS_SAVEABLE_RGBA_ONLY;
    #else
        return VIPS_FOREIGN_SAVEABLE_RGB | VIPS_FOREIGN_SAVEABLE_ALPHA;
    #endif
#else
    return VIPS_SAVEABLE_RGBA_ONLY;
#endif
}

static inline int shim_VIPS_SAVEABLE_RGB_CMYK(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    #ifdef VIPS_SAVEABLE_RGB_CMYK
        return VIPS_SAVEABLE_RGB_CMYK;
    #else
        return VIPS_FOREIGN_SAVEABLE_MONO | VIPS_FOREIGN_SAVEABLE_RGB | VIPS_FOREIGN_SAVEABLE_CMYK;
    #endif
#else
    return VIPS_SAVEABLE_RGB_CMYK;
#endif
}

static inline int shim_VIPS_SAVEABLE_ANY(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    #ifdef VIPS_SAVEABLE_ANY
        return VIPS_SAVEABLE_ANY;
    #else
        return VIPS_FOREIGN_SAVEABLE_ALL;
    #endif
#else
    return VIPS_SAVEABLE_ANY;
#endif
}

static inline int shim_VIPS_SAVEABLE_LAST(void) {
#if defined(SHIM_VIPS_VERSION_8_17)
    #ifdef VIPS_SAVEABLE_LAST
        return VIPS_SAVEABLE_LAST;
    #else
        return 99;
    #endif
#else
    return VIPS_SAVEABLE_LAST;
#endif
}

#endif /* C_vips_shim_h */
