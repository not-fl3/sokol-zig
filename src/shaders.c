#include <sokol_app.h>
#include <sokol_gfx.h>
#include <triangle-sapp.glsl.h>

const sg_shader_desc* triangle_shader_desc2(void) {
    return &triangle_shader_desc_glsl330;
}
