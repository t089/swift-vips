//
//  Header.h
//  
//
//  Created by Tobias on 28.06.21.
//

#ifndef C_vips_shim_h
#define C_vips_shim_h

#include <termios.h>
#include <vips/vips.h>

VipsImage* shim_vips_image_new_from_source(VipsSource *source, const char* options);

GObject* shim_g_object(const void * p);

VipsImage* shim_vips_image(const void * p);

VipsObject* shim_vips_object(const void *p);

VipsArea* shim_vips_area(const void *p);
   
GType shim_g_type_boolean();

GType shim_G_TYPE_STRING();

GType shim_G_TYPE_DOUBLE();

GType shim_VIPS_TYPE_ARRAY_DOUBLE();

GType shim_VIPS_TYPE_ARRAY_INT();


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

#endif /* C_vips_shim_h */
