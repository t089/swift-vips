/*
 * VIPS Operations Code Generator for Swift
 * 
 * This tool uses GObject introspection to discover all libvips operations
 * and generates Swift wrapper code for them.
 * 
 * Compile with:
 * gcc -o generate-vips-wrappers generate-vips-wrappers.c `pkg-config --cflags --libs vips gobject-2.0`
 */

#include <vips/vips.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/types.h>

// Utility functions
char* snake_to_camel(const char* snake) {
    if (!snake) return NULL;
    
    char* result = malloc(strlen(snake) + 1);
    int i = 0, j = 0;
    int capitalize_next = 0;
    
    while (snake[i]) {
        if (snake[i] == '_') {
            capitalize_next = 1;
        } else {
            if (capitalize_next && j > 0) {
                result[j++] = toupper(snake[i]);
                capitalize_next = 0;
            } else {
                result[j++] = snake[i];
            }
        }
        i++;
    }
    result[j] = '\0';
    
    return result;
}

const char* get_swift_type(GType type) {
    if (g_type_is_a(type, VIPS_TYPE_IMAGE))
        return "VIPSImage";
    else if (g_type_is_a(type, VIPS_TYPE_ARRAY_DOUBLE))
        return "[Double]";
    else if (g_type_is_a(type, VIPS_TYPE_ARRAY_INT))
        return "[Int]";
    else if (g_type_is_a(type, VIPS_TYPE_ARRAY_IMAGE))
        return "[VIPSImage]";
    else if (g_type_is_a(type, VIPS_TYPE_BLOB))
        return "Data";
    else if (type == G_TYPE_DOUBLE)
        return "Double";
    else if (type == G_TYPE_INT || type == G_TYPE_UINT)
        return "Int";
    else if (type == G_TYPE_BOOLEAN)
        return "Bool";
    else if (type == G_TYPE_STRING)
        return "String";
    else if (g_type_is_a(type, G_TYPE_ENUM)) {
        const char* name = g_type_name(type);
        return name ? name : "Int";
    }
    return "Any";
}

const char* get_category(const char* nickname) {
    // Categorize operations based on their names
    if (strstr(nickname, "load") || strstr(nickname, "save")) {
        if (strstr(nickname, "jpeg") || strstr(nickname, "jpg"))
            return "Foreign_JPEG";
        else if (strstr(nickname, "png"))
            return "Foreign_PNG";
        else if (strstr(nickname, "webp"))
            return "Foreign_WebP";
        else if (strstr(nickname, "tiff") || strstr(nickname, "tif"))
            return "Foreign_TIFF";
        else if (strstr(nickname, "pdf"))
            return "Foreign_PDF";
        else if (strstr(nickname, "svg"))
            return "Foreign_SVG";
        else if (strstr(nickname, "heif") || strstr(nickname, "heic"))
            return "Foreign_HEIF";
        else
            return "Foreign";
    }
    
    if (strstr(nickname, "add") || strstr(nickname, "subtract") || 
        strstr(nickname, "multiply") || strstr(nickname, "divide") ||
        strstr(nickname, "abs") || strstr(nickname, "linear") ||
        strstr(nickname, "math") || strstr(nickname, "complex") ||
        strstr(nickname, "remainder") || strstr(nickname, "boolean") ||
        strstr(nickname, "relational"))
        return "Arithmetic";
    
    if (strstr(nickname, "conv") || strstr(nickname, "sharpen") ||
        strstr(nickname, "blur") || strstr(nickname, "sobel"))
        return "Convolution";
    
    if (strstr(nickname, "colour") || strstr(nickname, "color") ||
        strstr(nickname, "Lab") || strstr(nickname, "XYZ") ||
        strstr(nickname, "sRGB") || strstr(nickname, "RGB"))
        return "Colour";
    
    if (strstr(nickname, "resize") || strstr(nickname, "rotate") ||
        strstr(nickname, "flip") || strstr(nickname, "crop") ||
        strstr(nickname, "embed") || strstr(nickname, "extract") ||
        strstr(nickname, "shrink") || strstr(nickname, "reduce") ||
        strstr(nickname, "affine") || strstr(nickname, "scale"))
        return "Conversion";
    
    if (strstr(nickname, "black") || strstr(nickname, "xyz") ||
        strstr(nickname, "grey") || strstr(nickname, "mask") ||
        strstr(nickname, "gaussmat") || strstr(nickname, "text") ||
        strstr(nickname, "gaussnoise") || strstr(nickname, "eye"))
        return "Create";
    
    if (strstr(nickname, "draw"))
        return "Draw";
    
    if (strstr(nickname, "hist") || strstr(nickname, "heq"))
        return "Histogram";
    
    if (strstr(nickname, "morph") || strstr(nickname, "erode") ||
        strstr(nickname, "dilate") || strstr(nickname, "median"))
        return "Morphology";
    
    return "Misc";
}

typedef struct {
    FILE* file;
    const char* category;
    int count;
} GeneratorContext;

typedef struct {
    char* name;
    GType type;
    int flags;
    int priority;
    char* description;
} ArgumentInfo;

// Simple function to get operation arguments
ArgumentInfo* get_operation_arguments(VipsOperation* op, int* count) {
    const char** names;
    int* flags;
    int n_args;
    
    if (vips_object_get_args(VIPS_OBJECT(op), &names, &flags, &n_args) != 0) {
        *count = 0;
        return NULL;
    }
    
    ArgumentInfo* args = calloc(n_args, sizeof(ArgumentInfo));
    *count = n_args;
    
    for (int i = 0; i < n_args; i++) {
        GParamSpec* pspec = g_object_class_find_property(
            G_OBJECT_GET_CLASS(op), names[i]);
        
        if (pspec) {
            args[i].name = g_strdup(names[i]);
            args[i].type = G_PARAM_SPEC_VALUE_TYPE(pspec);
            args[i].flags = flags[i];
            args[i].priority = i; // Use index as priority
            args[i].description = g_strdup(g_param_spec_get_blurb(pspec));
        }
    }
    
    // names and flags are static, don't free them
    
    return args;
}

void generate_operation(GeneratorContext* ctx, const char* nickname) {
    VipsOperation* op = vips_operation_new(nickname);
    if (!op) return;
    
    VipsObjectClass* class = VIPS_OBJECT_GET_CLASS(op);
    
    // Check category
    const char* category = get_category(nickname);
    if (strcmp(category, ctx->category) != 0) {
        g_object_unref(op);
        return;
    }
    
    // Get arguments
    int arg_count;
    ArgumentInfo* args = get_operation_arguments(op, &arg_count);
    
    if (!args || arg_count == 0) {
        g_object_unref(op);
        return;
    }
    
    // Check if operation has outputs
    int has_output = 0;
    int image_output_count = 0;
    for (int i = 0; i < arg_count; i++) {
        if ((args[i].flags & VIPS_ARGUMENT_OUTPUT) &&
            !(args[i].flags & VIPS_ARGUMENT_INPUT)) {
            has_output = 1;
            if (g_type_is_a(args[i].type, VIPS_TYPE_IMAGE)) {
                image_output_count++;
            }
        }
    }
    
    if (!has_output && !strstr(nickname, "save")) {
        // Skip operations without outputs
        goto cleanup;
    }
    
    // Generate Swift code
    char* swift_name = snake_to_camel(nickname);
    
    // Write documentation
    fprintf(ctx->file, "    /// %s\n", class->description);
    
    // Determine if this is an instance method or static method
    int has_input_image = 0;
    for (int i = 0; i < arg_count; i++) {
        if (strcmp(args[i].name, "in") == 0 &&
            (args[i].flags & VIPS_ARGUMENT_INPUT)) {
            has_input_image = 1;
            break;
        }
    }
    
    // Write function signature
    if (strstr(nickname, "load")) {
        fprintf(ctx->file, "    public static func %s(", swift_name);
    } else if (has_input_image) {
        fprintf(ctx->file, "    public func %s(", swift_name);
    } else {
        fprintf(ctx->file, "    public static func %s(", swift_name);
    }
    
    // Add parameters
    int first_param = 1;
    for (int i = 0; i < arg_count; i++) {
        ArgumentInfo* arg = &args[i];
        
        // Skip deprecated, output-only, and 'in' parameters
        if ((arg->flags & VIPS_ARGUMENT_DEPRECATED) ||
            ((arg->flags & VIPS_ARGUMENT_OUTPUT) && !(arg->flags & VIPS_ARGUMENT_INPUT)) ||
            strcmp(arg->name, "in") == 0) {
            continue;
        }
        
        if (!first_param) fprintf(ctx->file, ", ");
        first_param = 0;
        
        char* param_name = snake_to_camel(arg->name);
        const char* swift_type = get_swift_type(arg->type);
        
        if (arg->flags & VIPS_ARGUMENT_REQUIRED) {
            fprintf(ctx->file, "%s: %s", param_name, swift_type);
        } else {
            fprintf(ctx->file, "%s: %s? = nil", param_name, swift_type);
        }
        
        free(param_name);
    }
    
    fprintf(ctx->file, ") throws");
    
    // Add return type
    if (image_output_count == 1) {
        fprintf(ctx->file, " -> VIPSImage");
    } else if (strstr(nickname, "save")) {
        // Save operations don't return anything
    } else if (image_output_count > 1) {
        fprintf(ctx->file, " -> (");
        int first = 1;
        for (int i = 0; i < arg_count; i++) {
            if ((args[i].flags & VIPS_ARGUMENT_OUTPUT) &&
                !(args[i].flags & VIPS_ARGUMENT_INPUT) &&
                g_type_is_a(args[i].type, VIPS_TYPE_IMAGE)) {
                if (!first) fprintf(ctx->file, ", ");
                first = 0;
                char* name = snake_to_camel(args[i].name);
                fprintf(ctx->file, "%s: VIPSImage", name);
                free(name);
            }
        }
        fprintf(ctx->file, ")");
    }
    
    fprintf(ctx->file, " {\n");
    
    // Write function body
    if (image_output_count == 1) {
        if (has_input_image) {
            fprintf(ctx->file, "        return try VIPSImage(self) { out in\n");
        } else {
            fprintf(ctx->file, "        return try VIPSImage(nil) { out in\n");
        }
    } else if (strstr(nickname, "save")) {
        // No return for save operations
    } else {
        fprintf(ctx->file, "        try VIPSImage.execute {\n");
    }
    
    fprintf(ctx->file, "            var opt = VIPSOption()\n\n");
    
    // Set input parameters
    if (has_input_image) {
        fprintf(ctx->file, "            opt.set(\"in\", value: self.image)\n");
    }
    
    for (int i = 0; i < arg_count; i++) {
        ArgumentInfo* arg = &args[i];
        
        if ((arg->flags & VIPS_ARGUMENT_DEPRECATED) ||
            ((arg->flags & VIPS_ARGUMENT_OUTPUT) && !(arg->flags & VIPS_ARGUMENT_INPUT)) ||
            strcmp(arg->name, "in") == 0) {
            continue;
        }
        
        char* param_name = snake_to_camel(arg->name);
        
        if (arg->flags & VIPS_ARGUMENT_REQUIRED) {
            fprintf(ctx->file, "            opt.set(\"%s\", value: %s)\n", arg->name, param_name);
        } else {
            fprintf(ctx->file, "            if let %s = %s {\n", param_name, param_name);
            fprintf(ctx->file, "                opt.set(\"%s\", value: %s)\n", arg->name, param_name);
            fprintf(ctx->file, "            }\n");
        }
        
        free(param_name);
    }
    
    // Set output parameters
    for (int i = 0; i < arg_count; i++) {
        ArgumentInfo* arg = &args[i];
        
        if ((arg->flags & VIPS_ARGUMENT_OUTPUT) && !(arg->flags & VIPS_ARGUMENT_INPUT)) {
            if (g_type_is_a(arg->type, VIPS_TYPE_IMAGE)) {
                fprintf(ctx->file, "            opt.set(\"%s\", value: &out)\n", arg->name);
                break; // For now, just handle first output
            }
        }
    }
    
    fprintf(ctx->file, "\n            try VIPSImage.call(\"%s\", options: &opt)\n", nickname);
    fprintf(ctx->file, "        }\n");
    fprintf(ctx->file, "    }\n\n");
    
    ctx->count++;
    free(swift_name);
    
cleanup:
    // Free collected arguments
    for (int i = 0; i < arg_count; i++) {
        g_free(args[i].name);
        g_free(args[i].description);
    }
    free(args);
    
    g_object_unref(op);
}

void generate_category_file(const char* category) {
    // Create directory structure
    char dir_path[256];
    snprintf(dir_path, sizeof(dir_path), "Sources/VIPS/Generated");
    mkdir(dir_path, 0755);
    
    // Create file path
    char file_path[256];
    char safe_category[128];
    strcpy(safe_category, category);
    for (int i = 0; safe_category[i]; i++) {
        if (safe_category[i] == '_') {
            safe_category[i] = '_';
        }
    }
    
    snprintf(file_path, sizeof(file_path), "%s/%s.generated.swift", dir_path, safe_category);
    
    FILE* file = fopen(file_path, "w");
    if (!file) {
        printf("Failed to create file: %s\n", file_path);
        return;
    }
    
    // Write file header
    fprintf(file, "//\n");
    fprintf(file, "//  %s.generated.swift\n", safe_category);
    fprintf(file, "//\n");
    fprintf(file, "//  Generated by VIPS Code Generator\n");
    fprintf(file, "//  DO NOT EDIT - This file is automatically generated\n");
    fprintf(file, "//\n\n");
    fprintf(file, "import Cvips\n\n");
    fprintf(file, "extension VIPSImage {\n\n");
    
    GeneratorContext ctx = {
        .file = file,
        .category = category,
        .count = 0
    };
    
    // Get all operation types
    GType* types;
    guint n_types;
    types = g_type_children(VIPS_TYPE_OPERATION, &n_types);
    
    // Process all operation types recursively
    for (guint i = 0; i < n_types; i++) {
        // Get the operation class
        VipsObjectClass* class = VIPS_OBJECT_CLASS(g_type_class_ref(types[i]));
        if (class && class->nickname) {
            generate_operation(&ctx, class->nickname);
        }
        g_type_class_unref(class);
        
        // Also check children of this type
        GType* subtypes;
        guint n_subtypes;
        subtypes = g_type_children(types[i], &n_subtypes);
        for (guint j = 0; j < n_subtypes; j++) {
            VipsObjectClass* subclass = VIPS_OBJECT_CLASS(g_type_class_ref(subtypes[j]));
            if (subclass && subclass->nickname) {
                generate_operation(&ctx, subclass->nickname);
            }
            g_type_class_unref(subclass);
        }
        g_free(subtypes);
    }
    
    g_free(types);
    
    fprintf(file, "}\n");
    fclose(file);
    
    if (ctx.count > 0) {
        printf("Generated %s: %d operations\n", file_path, ctx.count);
    }
}

int main(int argc, char** argv) {
    if (vips_init(argv[0]) != 0) {
        vips_error_exit("Failed to initialize VIPS");
    }
    
    printf("VIPS Swift Code Generator\n");
    printf("=========================\n\n");
    
    // Categories to generate
    const char* categories[] = {
        "Arithmetic",
        "Colour", 
        "Conversion",
        "Convolution",
        "Create",
        "Draw",
        "Foreign",
        "Foreign_JPEG",
        "Foreign_PNG",
        "Foreign_WebP",
        "Foreign_TIFF",
        "Foreign_PDF",
        "Foreign_SVG",
        "Foreign_HEIF",
        "Histogram",
        "Morphology",
        "Misc",
        NULL
    };
    
    // Generate files for each category
    for (int i = 0; categories[i]; i++) {
        generate_category_file(categories[i]);
    }
    
    // Generate summary file
    FILE* summary = fopen("Sources/VIPS/Generated/README.md", "w");
    if (summary) {
        fprintf(summary, "# Generated VIPS Operations\n\n");
        fprintf(summary, "This directory contains automatically generated Swift wrappers for libvips operations.\n\n");
        fprintf(summary, "## Regenerating\n\n");
        fprintf(summary, "To regenerate these files, run:\n");
        fprintf(summary, "```bash\n");
        fprintf(summary, "gcc -o generate-vips-wrappers tools/generate-vips-wrappers.c `pkg-config --cflags --libs vips gobject-2.0`\n");
        fprintf(summary, "./generate-vips-wrappers\n");
        fprintf(summary, "```\n\n");
        fprintf(summary, "## Implementation Notes\n\n");
        fprintf(summary, "- Operations are discovered using GObject introspection\n");
        fprintf(summary, "- Each operation is wrapped in a Swift-friendly API\n");
        fprintf(summary, "- Type conversions are handled automatically where possible\n");
        fprintf(summary, "- Complex types may require manual review\n");
        fclose(summary);
    }
    
    printf("\nGeneration complete!\n");
    
    vips_shutdown();
    return 0;
}