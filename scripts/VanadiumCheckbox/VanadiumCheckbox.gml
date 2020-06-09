function VCheckbox(_x, _y, _w, _h, _text, _value, _callback, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    SetCallback = function(_callback) {
        callback = method(self, _callback);
    }
    
    text = _text;
    SetCallback(_callback);
    value = _value;
    
    box_size = 20;
    check = spr_vanadium_checkbox;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (GetMouseReleased(x1, y1, x2, y2)) {
            value = !value;
            callback();
        }
        
        var bx = x1 + offset + box_size / 2;
        var by = mean(y1, y2);
        var bx1 = bx - box_size / 2;
        var by1 = by - box_size / 2;
        var bx2 = bx + box_size / 2;
        var by2 = by + box_size / 2;
        var back_color = GetMouseHover(x1, y1, x2, y2) ? VANADIUM_COLOR_HOVER : (interactive ? VANADIUM_COLOR_BACK : VANADIUM_COLOR_DISABLED);
        DrawNineslice(nineslice, 1, bx1, by1, bx2, by2, back_color, 1);
        draw_sprite(check, value, bx, by);
        DrawNineslice(nineslice, 0, bx1, by1, bx2, by2, color, 1);
        
        scribble_set_box_align(alignment, valignment);
        scribble_draw(x1 + box_size + offset * 2, floor(mean(y1, y2)), text);
    }
}