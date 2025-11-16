//
//  CvipsShim.c
//  
//
//  Created by Tobias on 28.06.21.
//

#include "CvipsShim.h"
#include "glib.h"


gboolean shim_g_is_object(const void * p) {
    return G_IS_OBJECT(p);
}

gint shim_g_object_get_ref_count(GObject* object) {
    return g_atomic_int_get(&object->ref_count);
}

GObject* shim_g_object(const void * p) {
    return G_OBJECT(p);
}

GType shim_g_object_type(const void * p) {
    return G_OBJECT_TYPE(p);
}

VipsImage* shim_vips_image(const void * p) {
    return VIPS_IMAGE(p);
}

VipsObject* shim_vips_object(const void *p) {
    return VIPS_OBJECT(p);
}

VipsArea* shim_vips_area(const void *p) {
    return VIPS_AREA(p);
}
   
GType shim_g_type_boolean() {
    return G_TYPE_BOOLEAN;
}

GType shim_G_TYPE_STRING() {
    return G_TYPE_STRING;
}

GType shim_G_TYPE_DOUBLE() {
    return G_TYPE_DOUBLE;
}


GType shim_G_TYPE_INT() {
    return G_TYPE_INT;
}

GType shim_VIPS_TYPE_BLOB() {
    return VIPS_TYPE_BLOB;
}

GType shim_VIPS_TYPE_ARRAY_DOUBLE() {
    return VIPS_TYPE_ARRAY_DOUBLE;
}

double* shim_vips_array_double(void *p, int n) {
    return VIPS_ARRAY(p, n, double);
}

GType shim_VIPS_TYPE_ARRAY_INT() {
    return VIPS_TYPE_ARRAY_INT;
}

GCallback shim_G_CALLBACK(void *f) {
    return G_CALLBACK(f);
}

VipsSource* shim_VIPS_SOURCE(void *p) {
    return VIPS_SOURCE ( p );
}

VipsTarget* shim_VIPS_TARGET(void *p) {
    return VIPS_TARGET ( p );
}

gulong shim_g_signal_connect(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data) {
    return g_signal_connect(instance, detailed_signal, c_handler, data);
}

VipsImage* shim_vips_image_new_from_source(VipsSource *source, const char* options)
{
   return vips_image_new_from_source(source, options, NULL);
}


const char *
shim_vips_exif_tag(VipsImage *image, const char *tag) {
    const char *exif;
    if (
        vips_image_get_typeof(image, tag) != 0 &&
        !vips_image_get_string(image, tag, &exif)
    ) {
        return &exif[0];
    }
    return "";
}

int
shim_vips_exif_tag_to_int(VipsImage *image, const char *tag) {
    int value = 0;
    const char *exif = shim_vips_exif_tag(image, tag);
    if (strcmp(exif, "")) {
        value = atoi(&exif[0]);
    }
    return value;
}

int
shim_vips_exif_orientation(VipsImage *image) {
    return shim_vips_exif_tag_to_int(image, EXIF_IFD0_ORIENTATION);
}



int shim_vips_copy_interpretation(VipsImage *in, VipsImage **out, VipsInterpretation interpretation) {
    return vips_copy(in, out, "interpretation", interpretation, NULL);
}


VipsImage *
shim_vips_image_new_from_file( const char *name, VipsAccess access, gboolean in_memory ) {
    return vips_image_new_from_file(name, "access", access, "memory", in_memory, NULL);
}

int shim_vips_getpoint(void *image, double **values, int *n, int x, int y) {
    return vips_getpoint(image, values, n, x, y, NULL);
}

int shim_vips_major_version() {
    return VIPS_MAJOR_VERSION;
}


const char* shim_vips_version() {
    return VIPS_VERSION;
}

// VipsSource helper function implementations
const char* shim_vips_connection_filename(VipsSource *source) {
    return vips_connection_filename(VIPS_CONNECTION(source));
}

const char* shim_vips_connection_nick(VipsSource *source) {
    return vips_connection_nick(VIPS_CONNECTION(source));
}

gint64 shim_vips_source_read_position(VipsSource *source) {
    return source->read_position;
}

gint64 shim_vips_source_length_internal(VipsSource *source) {
    return source->length;
}

gboolean shim_vips_source_decode_status(VipsSource *source) {
    return source->decode;
}

gboolean shim_vips_source_is_pipe(VipsSource *source) {
    return source->is_pipe;
}