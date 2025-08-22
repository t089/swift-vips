#include "include/introspection.h"
#include <string.h>
#include <stdlib.h>

// Callback data for collecting arguments
typedef struct {
    CVipsArgumentInfo* args;
    int count;
    int capacity;
} ArgumentCollectorData;

// Callback for collecting arguments
static void* collect_arguments_cb(VipsObject* object,
                                  GParamSpec* pspec,
                                  VipsArgumentClass* argument_class,
                                  VipsArgumentInstance* argument_instance,
                                  void* a, void* b) {
    ArgumentCollectorData* data = (ArgumentCollectorData*)a;
    
    if (data->count >= data->capacity) {
        data->capacity = data->capacity ? data->capacity * 2 : 16;
        data->args = realloc(data->args, sizeof(CVipsArgumentInfo) * data->capacity);
    }
    
    CVipsArgumentInfo* arg = &data->args[data->count];
    arg->name = g_strdup(g_param_spec_get_name(pspec));
    arg->type = G_PARAM_SPEC_VALUE_TYPE(pspec);
    arg->flags = argument_class->flags;
    arg->priority = argument_class->priority;
    arg->description = g_strdup(g_param_spec_get_blurb(pspec));
    
    data->count++;
    
    return NULL;
}

char** cvips_get_operation_names(int* count) {
    if (!count) return NULL;
    
    *count = 0;
    int capacity = 256;
    char** names = malloc(sizeof(char*) * capacity);
    
    // Get all GType classes
    GType* types;
    guint n_types;
    types = g_type_children(G_TYPE_OBJECT, &n_types);
    
    for (guint i = 0; i < n_types; i++) {
        // Check if this is a VipsOperation subclass
        if (g_type_is_a(types[i], VIPS_TYPE_OPERATION)) {
            // Get the operation nickname
            VipsObjectClass* class = VIPS_OBJECT_CLASS(g_type_class_ref(types[i]));
            if (class && class->nickname) {
                if (*count >= capacity) {
                    capacity *= 2;
                    names = realloc(names, sizeof(char*) * capacity);
                }
                names[*count] = g_strdup(class->nickname);
                (*count)++;
            }
            g_type_class_unref(class);
        }
    }
    
    g_free(types);
    
    // Also get operations registered with vips_operation_class_install_argument
    char** vips_ops = vips_list_classes();
    if (vips_ops) {
        for (int i = 0; vips_ops[i]; i++) {
            GType type = g_type_from_name(vips_ops[i]);
            if (type && g_type_is_a(type, VIPS_TYPE_OPERATION)) {
                VipsObjectClass* class = VIPS_OBJECT_CLASS(g_type_class_peek(type));
                if (class && class->nickname) {
                    // Check if we already have this one
                    gboolean found = FALSE;
                    for (int j = 0; j < *count; j++) {
                        if (strcmp(names[j], class->nickname) == 0) {
                            found = TRUE;
                            break;
                        }
                    }
                    
                    if (!found) {
                        if (*count >= capacity) {
                            capacity *= 2;
                            names = realloc(names, sizeof(char*) * capacity);
                        }
                        names[*count] = g_strdup(class->nickname);
                        (*count)++;
                    }
                }
            }
        }
        g_strfreev(vips_ops);
    }
    
    return names;
}

CVipsOperationInfo* cvips_get_operation_info(const char* name) {
    if (!name) return NULL;
    
    VipsOperation* op = vips_operation_new(name);
    if (!op) return NULL;
    
    CVipsOperationInfo* info = malloc(sizeof(CVipsOperationInfo));
    
    VipsObjectClass* class = VIPS_OBJECT_GET_CLASS(op);
    info->name = g_strdup(name);
    info->nickname = g_strdup(class->nickname);
    info->description = g_strdup(class->description);
    
    VipsOperationFlags flags = 0;
    vips_operation_get_flags(op, &flags);
    info->flags = flags;
    
    g_object_unref(op);
    
    return info;
}

CVipsArgumentInfo* cvips_get_operation_arguments(const char* operation_name, int* count) {
    if (!operation_name || !count) return NULL;
    
    *count = 0;
    
    VipsOperation* op = vips_operation_new(operation_name);
    if (!op) return NULL;
    
    ArgumentCollectorData data = {0};
    
    vips_object_get_args(VIPS_OBJECT(op), NULL, collect_arguments_cb, &data, NULL);
    
    g_object_unref(op);
    
    *count = data.count;
    return data.args;
}

void cvips_free_operation_info(CVipsOperationInfo* info) {
    if (!info) return;
    
    g_free((char*)info->name);
    g_free((char*)info->nickname);
    g_free((char*)info->description);
    free(info);
}

void cvips_free_argument_info(CVipsArgumentInfo* args, int count) {
    if (!args) return;
    
    for (int i = 0; i < count; i++) {
        g_free((char*)args[i].name);
        g_free((char*)args[i].description);
    }
    
    free(args);
}

void cvips_free_string_array(char** array, int count) {
    if (!array) return;
    
    for (int i = 0; i < count; i++) {
        g_free(array[i]);
    }
    
    free(array);
}

gboolean cvips_type_is_image(GType type) {
    return g_type_is_a(type, VIPS_TYPE_IMAGE);
}

gboolean cvips_type_is_array_double(GType type) {
    return g_type_is_a(type, VIPS_TYPE_ARRAY_DOUBLE);
}

gboolean cvips_type_is_array_int(GType type) {
    return g_type_is_a(type, VIPS_TYPE_ARRAY_INT);
}

gboolean cvips_type_is_array_image(GType type) {
    return g_type_is_a(type, VIPS_TYPE_ARRAY_IMAGE);
}

gboolean cvips_type_is_blob(GType type) {
    return g_type_is_a(type, VIPS_TYPE_BLOB);
}

const char* cvips_get_type_name(GType type) {
    return g_type_name(type);
}

char** cvips_list_all_classes(int* count) {
    if (!count) return NULL;
    
    char** classes = vips_list_classes();
    *count = 0;
    
    if (classes) {
        while (classes[*count]) {
            (*count)++;
        }
    }
    
    return classes;
}

gboolean cvips_is_operation_class(const char* class_name) {
    if (!class_name) return FALSE;
    
    GType type = g_type_from_name(class_name);
    if (!type) return FALSE;
    
    return g_type_is_a(type, VIPS_TYPE_OPERATION);
}