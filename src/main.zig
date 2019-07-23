const std = @import("std");
const warn = std.debug.warn;

const c = @cImport({
    @cDefine("SOKOL_GLCORE33", "");
    @cInclude("sokol_app.h");
    @cInclude("sokol_gfx.h");
    @cInclude("triangle-sapp.glsl.h");
});

extern fn triangle_shader_desc2() [*c]const c.sg_shader_desc;

const pass_action: c.sg_pass_action = c.sg_pass_action{
    .colors = [_]c.sg_color_attachment_action{c.sg_color_attachment_action{
        .action = c.SG_ACTION_CLEAR,
        .val = [_]f32{ 0.0, 0.0, 0.0, 1.0 },
    }},
};

var pip: c.sg_pipeline = undefined;
var bind: c.sg_bindings = undefined;

extern fn init_cb() void {
    c.sg_setup(&c.sg_desc{
        .mtl_device = c.sapp_metal_get_device(),
        .mtl_renderpass_descriptor_cb = c.sapp_metal_get_renderpass_descriptor,
        .mtl_drawable_cb = c.sapp_metal_get_drawable,
    });

    // a vertex buffer
    const vertices = [_]f32{
        // positions     colors
        0.0,  0.5,  0.5, 1.0, 0.0, 0.0, 1.0,
        0.5,  -0.5, 0.5, 0.0, 1.0, 0.0, 1.0,
        -0.5, -0.5, 0.5, 0.0, 0.0, 1.0, 1.0,
    };

    bind.vertex_buffers[0] = c.sg_make_buffer(&c.sg_buffer_desc{
        .type = c.sg_buffer_type._SG_BUFFERTYPE_DEFAULT,
        .size = vertices.len * @sizeOf(f32),
        .content = &vertices,
        .label = c"quad-vertices",
    });

    // create shader from code-generated sg_shader_desc
    const shd: c.sg_shader = c.sg_make_shader(triangle_shader_desc2());

    // create a pipeline object (default render states are fine for triangle)
    pip = c.sg_make_pipeline(&c.sg_pipeline_desc{
        .shader = shd,
        // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
        .layout = c.sg_layout_desc{
            .attrs = mkattrs: {
                var attrs = std.mem.zeroInit([16]c.sg_vertex_attr_desc);
                attrs[c.ATTR_vs_position].format = c.SG_VERTEXFORMAT_FLOAT3;
                attrs[c.ATTR_vs_color0].format = c.SG_VERTEXFORMAT_FLOAT4;
                break :mkattrs attrs;
            },
        },
        .label = c"triangle-pipeline",
    });
}

extern fn frame() void {
    c.sg_begin_default_pass(&pass_action, c.sapp_width(), c.sapp_height());
    c.sg_apply_pipeline(pip);
    c.sg_apply_bindings(&bind);
    c.sg_draw(0, 3, 1);
    //__dbgui_draw();
    c.sg_end_pass();
    c.sg_commit();
}

extern fn cleanup_cb() void {
    c.sg_shutdown();
}

pub fn main() anyerror!void {
    const sapp_desc = c.sapp_desc{
        .init_cb = init_cb,
        .frame_cb = frame,
        .cleanup_cb = cleanup_cb,
        .width = 640,
        .height = 480,
        .window_title = c"Hello sokol-zig!",
    };
    _ = c.sapp_run(&sapp_desc);
}
