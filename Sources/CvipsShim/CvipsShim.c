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

// Callback for collecting operation types recursively
static void* collect_operation_type(GType type, void* a, void* b) {
    GArray* types = (GArray*)a;
    const char* nickname = vips_nickname_find(type);

    if (nickname) {
        g_array_append_val(types, type);
    }

    // Recursively walk children to get all operations in the hierarchy
    vips_type_map(type, collect_operation_type, types, NULL);

    return NULL;
}

// Get all operation types
GType* shim_get_all_operation_types(int* count) {
    GArray* types = g_array_new(FALSE, FALSE, sizeof(GType));

    // Map over all VipsOperation subclasses recursively
    vips_type_map(vips_operation_get_type(), collect_operation_type, types, NULL);

    *count = types->len;

    // Convert GArray to C array - caller must free
    GType* result = g_malloc(sizeof(GType) * types->len);
    for (guint i = 0; i < types->len; i++) {
        result[i] = g_array_index(types, GType, i);
    }

    g_array_free(types, TRUE);
    return result;
}

// Get operation info by nickname
ShimOperationInfo* shim_get_operation_info(const char* nickname) {
    // Find the operation class by nickname
    const VipsObjectClass* object_class = vips_class_find("VipsOperation", nickname);
    if (!object_class) {
        return NULL;
    }

    GType operation_type = G_OBJECT_CLASS_TYPE(object_class);
    VipsOperationClass* operation_class = VIPS_OPERATION_CLASS(object_class);

    ShimOperationInfo* info = g_malloc(sizeof(ShimOperationInfo));
    info->nickname = g_strdup(object_class->nickname ? object_class->nickname : nickname);
    info->description = g_strdup(object_class->description ? object_class->description : "");
    info->operation_type = operation_type;
    info->flags = operation_class ? operation_class->flags : 0;

    return info;
}

// Callback for collecting parameter info
typedef struct {
    GArray* params;
} CollectParamsData;

static void* collect_parameter_info(VipsObjectClass* object_class,
                                   GParamSpec* pspec,
                                   VipsArgumentClass* argument_class,
                                   void* a, void* b) {
    CollectParamsData* data = (CollectParamsData*)a;

    ShimParameterInfo param_info;
    param_info.name = g_strdup(g_param_spec_get_name(pspec));
    param_info.description = g_strdup(g_param_spec_get_blurb(pspec));
    param_info.parameter_type = G_PARAM_SPEC_VALUE_TYPE(pspec);
    param_info.flags = argument_class->flags;
    param_info.priority = argument_class->priority;

    g_array_append_val(data->params, param_info);
    return NULL;
}

// Get parameters for an operation
ShimParameterInfo* shim_get_operation_parameters(const char* nickname, int* count) {
    // Find the operation class by nickname
    const VipsObjectClass* object_class = vips_class_find("VipsOperation", nickname);
    if (!object_class) {
        *count = 0;
        return NULL;
    }

    CollectParamsData data;
    data.params = g_array_new(FALSE, FALSE, sizeof(ShimParameterInfo));

    // Collect all arguments (cast away const - vips_argument_class_map doesn't modify the class)
    vips_argument_class_map((VipsObjectClass*)object_class, collect_parameter_info, &data, NULL);

    *count = data.params->len;

    // Convert to C array - caller must free
    ShimParameterInfo* result = g_malloc(sizeof(ShimParameterInfo) * data.params->len);
    for (guint i = 0; i < data.params->len; i++) {
        result[i] = g_array_index(data.params, ShimParameterInfo, i);
    }

    g_array_free(data.params, TRUE);
    return result;
}

// Free allocated arrays
void shim_free_operation_types(GType* types) {
    g_free(types);
}

void shim_free_operation_info(ShimOperationInfo* info) {
    if (info) {
        g_free((char*)info->nickname);
        g_free((char*)info->description);
        g_free(info);
    }
}

void shim_free_parameter_info(ShimParameterInfo* params) {
    // Note: We don't free individual strings here as they're owned by GLib
    g_free(params);
}

// Helper functions for type introspection
const char* shim_gtype_name(GType gtype) {
    return g_type_name(gtype);
}

GType shim_gtype_fundamental(GType gtype) {
    return g_type_fundamental(gtype);
}

gboolean shim_gtype_is_enum(GType gtype) {
    return G_TYPE_IS_ENUM(gtype);
}

gboolean shim_gtype_is_flags(GType gtype) {
    return G_TYPE_IS_FLAGS(gtype);
}

// Ensure an operation class and, transitively, every enum/flags GType
// referenced by its parameters is registered with the type system.
static void* force_register_op_types(GType type, void* a, void* b) {
    if (vips_nickname_find(type)) {
        gpointer klass = g_type_class_ref(type);
        if (klass) {
            g_type_class_unref(klass);
        }
    }
    vips_type_map(type, force_register_op_types, NULL, NULL);
    return NULL;
}

GType* shim_get_all_vips_enum_types(int* count) {
    // Step 1: force-ref every VipsOperation class so their GParamSpec
    // types (including every enum/flags used) get registered.
    vips_type_map(vips_operation_get_type(), force_register_op_types, NULL, NULL);

    // A few enums live on class metadata (VipsOperationClass.flags,
    // VipsArgumentClass.flags, VipsImage.type/demand) rather than on any
    // GParamSpec, so walking operation params doesn't reach them. Force
    // their GType registration explicitly. These *_get_type functions are
    // declared G_GNUC_CONST, so discarding the result lets the optimizer
    // elide the call — route through a volatile sink to prevent that.
    volatile GType extra_types[4];
    extra_types[0] = vips_argument_flags_get_type();
    extra_types[1] = vips_operation_flags_get_type();
    extra_types[2] = vips_demand_style_get_type();
    extra_types[3] = vips_image_type_get_type();
    (void)extra_types;

    GArray* result = g_array_new(FALSE, FALSE, sizeof(GType));

    // Step 2: enumerate all registered descendants of G_TYPE_ENUM and G_TYPE_FLAGS.
    GType fundamentals[2] = { G_TYPE_ENUM, G_TYPE_FLAGS };
    for (int f = 0; f < 2; f++) {
        guint n = 0;
        GType* children = g_type_children(fundamentals[f], &n);
        if (children) {
            for (guint i = 0; i < n; i++) {
                const char* name = g_type_name(children[i]);
                if (name && g_str_has_prefix(name, "Vips")) {
                    g_array_append_val(result, children[i]);
                }
            }
            g_free(children);
        }
    }

    *count = result->len;
    GType* out = g_malloc(sizeof(GType) * result->len);
    for (guint i = 0; i < result->len; i++) {
        out[i] = g_array_index(result, GType, i);
    }
    g_array_free(result, TRUE);
    return out;
}

ShimEnumValue* shim_get_enum_values(GType gtype, int* count) {
    *count = 0;

    if (G_TYPE_IS_ENUM(gtype)) {
        GEnumClass* klass = (GEnumClass*)g_type_class_ref(gtype);
        if (!klass) return NULL;

        guint n = klass->n_values;
        ShimEnumValue* out = g_malloc(sizeof(ShimEnumValue) * (n > 0 ? n : 1));
        for (guint i = 0; i < n; i++) {
            out[i].name = g_strdup(klass->values[i].value_name);
            out[i].nick = g_strdup(klass->values[i].value_nick);
            out[i].value = klass->values[i].value;
        }
        *count = (int)n;
        g_type_class_unref(klass);
        return out;
    }

    if (G_TYPE_IS_FLAGS(gtype)) {
        GFlagsClass* klass = (GFlagsClass*)g_type_class_ref(gtype);
        if (!klass) return NULL;

        guint n = klass->n_values;
        ShimEnumValue* out = g_malloc(sizeof(ShimEnumValue) * (n > 0 ? n : 1));
        for (guint i = 0; i < n; i++) {
            out[i].name = g_strdup(klass->values[i].value_name);
            out[i].nick = g_strdup(klass->values[i].value_nick);
            out[i].value = (int)klass->values[i].value;
        }
        *count = (int)n;
        g_type_class_unref(klass);
        return out;
    }

    return NULL;
}

void shim_free_gtypes(GType* types) {
    g_free(types);
}

void shim_free_enum_values(ShimEnumValue* values) {
    // Note: individual strings duplicated with g_strdup, but we keep the
    // API simple and leak them intentionally — they live for the lifetime
    // of code generation, which is a short-lived process.
    g_free(values);
}