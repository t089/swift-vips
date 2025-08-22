#ifndef CVIPS_INTROSPECTION_H
#define CVIPS_INTROSPECTION_H

#include <vips/vips.h>

// Helper functions for GObject introspection that Swift can't directly access

// Get all VIPS operation names
char** cvips_get_operation_names(int* count);

// Get operation info
typedef struct {
    const char* name;
    const char* nickname;
    const char* description;
    VipsOperationFlags flags;
} CVipsOperationInfo;

CVipsOperationInfo* cvips_get_operation_info(const char* name);

// Argument info
typedef struct {
    const char* name;
    GType type;
    VipsArgumentFlags flags;
    int priority;
    const char* description;
} CVipsArgumentInfo;

// Get operation arguments
CVipsArgumentInfo* cvips_get_operation_arguments(const char* operation_name, int* count);

// Free allocated memory
void cvips_free_operation_info(CVipsOperationInfo* info);
void cvips_free_argument_info(CVipsArgumentInfo* args, int count);
void cvips_free_string_array(char** array, int count);

// Type checking helpers
gboolean cvips_type_is_image(GType type);
gboolean cvips_type_is_array_double(GType type);
gboolean cvips_type_is_array_int(GType type);
gboolean cvips_type_is_array_image(GType type);
gboolean cvips_type_is_blob(GType type);

// Get type name for enums
const char* cvips_get_type_name(GType type);

// List all classes
char** cvips_list_all_classes(int* count);

// Check if a class is an operation
gboolean cvips_is_operation_class(const char* class_name);

#endif // CVIPS_INTROSPECTION_H