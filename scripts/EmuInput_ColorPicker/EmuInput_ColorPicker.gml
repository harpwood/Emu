// I wanted to make this inherit from EmuInput but that made GameMaker cranky
// for some reason
function EmuColorPicker(_x, _y, _w, _h, _text, _value, _vx1, _vy1, _vx2, _vy2, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    text = _text;
    value_x1 = _vx1;
    value_y1 = _vy1;
    value_x2 = _vx2;
    value_y2 = _vy2;
    
    allow_alpha = false;
    active_shade = true;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var c = color;
        
        var vx1 = x1 + value_x1;
        var vy1 = y1 + value_y1;
        var vx2 = x1 + value_x2;
        var vy2 = y1 + value_y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        scribble_set_box_align(fa_left, fa_middle);
        scribble_draw(tx, ty, text);
        
        DrawNineslice(1, vx1 + 1, vy1 + 1, vx2 - 1, vy2 - 1, EMU_COLOR_BACK, 1);
        DrawCheckerbox(vx1, vy1, (vx2 - vx1), (vy2 - vy1));
        DrawNineslice(1, vx1 + 2, vy1 + 2, vx2 - 2, vy2 - 2, value, allow_alpha ? (((value & 0xff000000) >> 24) / 0xff) : 1);
        DrawNineslice(0, vx1 + 1, vy1 + 1, vx2 - 1, vy2 - 1, color, 1);
        
        if (GetInteractive()) {
            if (GetMouseHover(vx1, vy1, vx2, vy2)) {
                if (GetMouseReleased(vx1, vy1, vx2, vy2)) {
                    Activate();
                    var dialog = new EmuDialog(480, 400, "Pick a color", emu_dialog_close_auto);
                    dialog.flags = (dialog.flags ^ EmuDialogFlags.ACTIVE_SHADE) | (allow_alpha * EmuDialogFlags.ACTIVE_SHADE);
                    dialog.base_color_element = self;
                    
                    var ew = 256;
                    var eh = 32;
                    var u = undefined;
                    
                    var vx1 = 120;
                    var vy1 = 0;
                    var vx2 = ew;
                    var vy2 = eh;
                    
                    var yy = 64;
                    var spacing = 16;
                    
                    var controls = function(_x, _y, _w, _h, _value, _allow_alpha, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
                        enum EmuColorChannels { R, G, B, A }
                        
                        allow_alpha = _allow_alpha;
                        
                        override_escape = true;
                        
                        alpha = 1;
                        color_x = 0;
                        color_y = 0;
                        main_size = 176;
                        selecting_color = false;
                        
                        axis_x = color_x + main_size + 16;
                        axis_y = color_y;
                        axis_width = 32;
                        // axis_height is main_size
                        selecting_axis = false;
                        
                        output_x = color_x + 48;
                        output_y = color_y + main_size + 8;
                        // output_width is main_size
                        output_height = 16;
                        
                        alpha_x = color_x + 48;
                        alpha_y = output_y + output_height + 8;
                        // alpha_width is main_size
                        alpha_height = 16;
                        selecting_alpha = false;
                        
                        axis_value = 0;
                        axis_w = 0;
                        axis_h = 0;
                        axis_channel = EmuColorChannels.R;
                        all_colors = true;
                        
                        SetValue = function(_value) {
                            value = _value;
                            
                            switch (axis_channel) {
                                case EmuColorChannels.R:
                                    axis_value = (value & 0x0000ff) / 0xff;
                                    axis_w = ((value & 0x00ff00) >> 8) / 0xff;
                                    axis_h = ((value & 0xff0000) >> 16) / 0xff;
                                    break;
                                case EmuColorChannels.G:
                                    axis_h = (value & 0x0000ff) / 0xff;
                                    axis_value = ((value & 0x00ff00) >> 8) / 0xff;
                                    axis_w = ((value & 0xff0000) >> 16) / 0xff;
                                    break;
                                case EmuColorChannels.B:
                                    axis_w = (value & 0x0000ff) / 0xff;
                                    axis_h = ((value & 0x00ff00) >> 8) / 0xff;
                                    axis_value = ((value & 0xff0000) >> 16) / 0xff;
                                    break;
                            }
                        }
                        
                        Render = function(base_x, base_y) {
                            var x1 = x + base_x;
                            var y1 = y + base_y;
                            var x2 = x1 + width;
                            var y2 = y1 + height;
                            var buckets = all_colors ? 255 : 8;
                            
                            var color_initial = value;
                            var alpha_initial = alpha;
                            
                            #region color picker
                            var vx1 = x1 + color_x;
                            var vy1 = y1 + color_y;
                            var vx2 = vx1 + main_size;
                            var vy2 = vy1 + main_size;
                            var w = vx2 - vx1;
                            var h = vy2 - vy1;
                            
                            var colour_replace_red = function(original, value) { return value | (original & 0xffff00); }
                            var colour_replace_green = function(original, value) { return (value << 8) | (original & 0xff00ff); }
                            var colour_replace_blue = function(original, value) { return (value << 16) | (original & 0x00ffff); }
                            
                            switch (axis_channel) {
                                case EmuColorChannels.R:
                                    var c2 = colour_replace_red(c_white, axis_value * 0xff);
                                    var c1 = colour_replace_green(c2, 0);
                                    var c3 = colour_replace_blue(c2, 0);
                                    var c4 = axis_value * 0xff;
                                    break;
                                case EmuColorChannels.G:
                                    var c2 = colour_replace_green(c_white, axis_value * 0xff);
                                    var c1 = colour_replace_blue(c2, 0);
                                    var c3 = colour_replace_red(c2, 0);
                                    var c4 = (axis_value * 0xff) << 8;
                                    break;
                                case EmuColorChannels.B:
                                    var c2 = colour_replace_blue(c_white, axis_value * 0xff);
                                    var c1 = colour_replace_red(c2, 0);
                                    var c3 = colour_replace_green(c2, 0);
                                    var c4 = (axis_value * 0xff) << 16;
                                    break;
                            }
                            
                            if (GetMouseHover(vx1, vy1, vx2, vy2)) {
                                if (GetMouseHold(vx1, vy1, vx2, vy2)) {
                                    selecting_color = true;
                                }
                            }
                            
                            if (selecting_color) {
                                axis_w = clamp((mouse_x - vx1) / w, 0, 1);
                                axis_h = 1 - clamp((mouse_y - vy1) / h, 0, 1);
                                selecting_color = GetMouseHold(0, 0, window_get_width(), window_get_height());
                            }
                            
                            var current_axis = floor(axis_value * buckets) * 0xff / buckets;
                            var ww = floor(axis_w * buckets) * 0xff / buckets;
                            var hh = floor(axis_h * buckets) * 0xff / buckets;
                            
                            switch (axis_channel) {
                                case EmuColorChannels.R: value = (hh << 16) | (ww << 8) | current_axis; break;
                                case EmuColorChannels.G: value = (ww << 16) | (current_axis << 8) | hh; break;
                                case EmuColorChannels.B: value = (current_axis << 16) | (hh << 8) | ww; break;
                            }
                            
                            shader_set(shd_emu_color_buckets);
                            shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "buckets"), buckets);
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, c1, c2, c3, c4, false);
                            shader_reset();
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, color, color, color, color, true);

                            gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                            var chx = vx1 + axis_w * w;
                            var chy = vy1 + (1 - axis_h) * h;
                            draw_sprite(spr_emu_mask_crosshair, 0, chx, chy);
                            gpu_set_blendmode(bm_normal);
                            #endregion
                            
                            #region color axis
                            vx1 = x1 + axis_x;
                            vy1 = y1 + axis_y;
                            vx2 = vx1 + axis_width;
                            vy2 = vy1 + main_size;
                            var w = vx2 - vx1;
                            var h = vy2 - vy1;
                            
                            if (GetMouseHover(vx1, vy1, vx2, vy2)) {
                                if (GetMousePressed(vx1, vy1, vx2, vy2)) {
                                    selecting_axis = true;
                                }
                            }
                            
                            if (selecting_axis) {
                                axis_value = clamp((mouse_y - vy1) / h, 0, 1);
                                selecting_axis = GetMouseHold(0, 0, window_get_width(), window_get_height());
                            }
                            
                            shader_set(shd_emu_color_buckets);
                            shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "buckets"), buckets);
                            var channels = [0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000];
                            var c = channels[axis_channel];
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c, c, false);
                            shader_reset();
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
                            
                            var f = min(vy1 + h * axis_value, vy2 - 1);
                            gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                            draw_sprite_ext(spr_emu_mask_bar_h, 0, vx1, f, (vx2 - vx1) / sprite_get_width(spr_emu_mask_bar_h), 1, 0, c_white, 1);
                            gpu_set_blendmode(bm_normal);
                            #endregion
                            
                            #region output color
                            vx1 = x1 + output_x;
                            vy1 = y1 + output_y;
                            vx2 = vx1 + main_size;
                            vy2 = vy1 + output_height;
                            var w = vx2 - vx1;
                            var h = vy2 - vy1;
                            
                            DrawCheckerbox(vx1, vy1, vx2 - vx1, vy2 - vy1, 0.4, 0.4);
                            draw_set_alpha(alpha);
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, value, value, value, value, false);
                            draw_set_alpha(1);
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, color, color, color, color, true);
                            #endregion
                            
                            #region alpha
                            if (allow_alpha) {
                                vx1 = x1 + alpha_x;
                                vy1 = y1 + alpha_y;
                                vx2 = vx1 + main_size;
                                vy2 = vy1 + alpha_height;
                                var w = vx2 - vx1;
                                var h = vy2 - vy1;
                                
                                if (GetMouseHover(vx1, vy1, vx2, vy2)) {
                                    if (GetMousePressed(vx1, vy1, vx2, vy2)) {
                                        selecting_alpha = true;
                                    }
                                }
                                
                                if (selecting_alpha) {
                                    alpha = clamp((mouse_x - vx1) / w, 0, 1);
                                    selecting_alpha = GetMouseHold(0, 0, window_get_width(), window_get_height());
                                }
                                
                                scribble_draw(GetTextX(x + base_x), floor(mean(vy1, vy2)), "A:");
                                DrawCheckerbox(vx1, vy1, vx2 - vx1, vy2 - vy1, 0.4, 0.4);
                                draw_primitive_begin(pr_trianglelist);
                                draw_vertex_colour(vx1, vy1, value, 0);
                                draw_vertex_colour(vx2 + 1, vy1, value, 1);
                                draw_vertex_colour(vx2 + 1, vy2 + 1, value, 1);
                                draw_vertex_colour(vx2 + 1, vy2 + 1, value, 1);
                                draw_vertex_colour(vx1, vy2 + 1, value, 0);
                                draw_vertex_colour(vx1, vy1, value, 0);
                                draw_primitive_end();
                                draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
                                
                                var f = min(vx1 + w * alpha, vx2 - 1);
                                gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                                draw_sprite_ext(spr_emu_mask_bar_v, 0, f, vy1, 1, (vy2 - vy1) / sprite_get_height(spr_emu_mask_bar_v), 0, c_white, 1);
                                gpu_set_blendmode(bm_normal);
                            }
                            #endregion
                            
                            if (color_initial != value || alpha_initial != alpha) {
                                callback();
                            }
                        }
                    }
                    
                    dialog.el_picker_code = new EmuInput(32, 32, ew, eh, "Color:", emu_string_hex(((value & 0xff0000) >> 16) | (value & 0x00ff00) | (value & 0x0000ff) << 16, 6), "RRGGBB", 6, EmuInputTypes.HEX, vx1, vy1, vx2, vy2, function() {
                        if (string_length(value) == 6) {
                            var value_as_real = emu_hex(value);
                            root.el_picker.SetValue(((value_as_real & 0xff0000) >> 16) | (value_as_real & 0x00ff00) | (value_as_real & 0x0000ff) << 16);
                        root.base_color_element.value = value_as_real | (floor(alpha * 0xff) << 24);
                        }
                    });
                    dialog.el_picker_code.SetRealNumberBounds(0, 0xffffff);
                    
                    dialog.el_picker = new controls(32, u, ew, eh, value, allow_alpha, function() {
                        root.base_color_element.value = value | (floor(alpha * 0xff) << 24);
                        root.el_picker_code.SetValue(emu_string_hex(((value & 0xff0000) >> 16) | (value & 0x00ff00) | ((value & 0x0000ff) << 16), 6));
                        root.base_color_element.callback();
                    });
                    
                    dialog.el_picker.alpha = ((value & 0xff000000) >> 24) / 0xff;
                    dialog.el_picker.axis_value = (value & 0x0000ff) / 0xff;
                    dialog.el_picker.axis_w = ((value & 0x00ff00) >> 8) / 0xff;
                    dialog.el_picker.axis_h = ((value & 0xff0000) >> 16) / 0xff;
                    
                    dialog.el_channels = new EmuRadioArray(320, 32, ew / 2, eh, "Axis Channel", 0, function() {
                        root.el_picker.axis_channel = value;
                    });
                    dialog.el_channels.AddOptions(["Red", "Green", "Blue"]);
                    dialog.el_all = new EmuCheckbox(320, u, ew / 2, eh, "All colors?", true, function() {
                        root.el_picker.all_colors = value;
                    });
                    
                    var b_width = 128;
                    var b_height = 32;
                    var el_confirm = new EmuButton(dialog.width / 2 - b_width / 2, dialog.height - 32 - b_height / 2, b_width, b_height, "Done", emu_dialog_close_auto);
                    
                    dialog.AddContent([dialog.el_picker_code, dialog.el_picker, dialog.el_channels, dialog.el_all, el_confirm]);
                }
                SetTooltip();
            }
        }
    }
    
    Destroy = function() {
        DestroyContent();
        if (surface_exists(surface)) surface_free(surface);
    }
    
    ValidateInput = function(_text) {
        switch (value_type) {
            case EmuInputTypes.STRING:
                return true;
            case EmuInputTypes.INT:
                var success = true;
                try {
                    var cast = real(_text);
                    if (floor(cast) != cast) success = false;
                } catch (e) {
                    success = false;
                }
                return success;
            case EmuInputTypes.REAL:
                var success = true;
                try {
                    var cast = real(_text);
                } catch (e) {
                    success = false;
                }
                return success;
        }
    }
    
    CastInput = function(_text) {
        switch (value_type) {
            case EmuInputTypes.STRING: return _text;
            case EmuInputTypes.INT: return real(_text);
            case EmuInputTypes.REAL: return real(_text);
        }
    }
}