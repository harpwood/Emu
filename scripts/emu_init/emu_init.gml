scribble_init("emu", "fnt_emu_default", true);

global.__emu_dialogs = ds_list_create();
global.__emu_active_element = noone;

#region some macros which you may want to set
#macro EMU_COLOR_BACK 0xffffff
#macro EMU_COLOR_DEFAULT 0x000000
#macro EMU_COLOR_DISABLED c_ltgray
#macro EMU_COLOR_HOVER 0xffe5ce
#macro EMU_COLOR_INPUT_REJECT c_red
#macro EMU_COLOR_INPUT_WARN c_orange
#macro EMU_COLOR_PROGRESS_BAR 0xff9900
#macro EMU_COLOR_RADIO_ACTIVE 0x009900
#macro EMU_COLOR_SELECTED 0xffb8ac
#macro EMU_COLOR_WINDOWSKIN 0x339900

#macro EMU_DIALOG_SHADE_ALPHA 0.5
#macro EMU_DIALOG_SHADE_COLOR c_black

#macro EMU_FONT_DEFAULT fnt_emu_default

#macro EMU_TIME_DOUBLE_CLICK_THRESHOLD 250
#macro EMU_TIME_HOLD_THRESHOLD 500
#endregion