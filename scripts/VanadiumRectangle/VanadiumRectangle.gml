function VRectangle(_x, _y, _w, _h, _color, _outline, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    color = _color;
    outline = _outline;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        DrawNineslice(spr_vanadium_nineslice, outline ? 0 : 1, x1, y1, x2, y2, color);
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}