// ============================================================
//  CYBERTHREAD — printed enclosure (v0, parametric)
//  The coupler drops in at the TOP; fibres exit the top wall
//  and run up to the hair. The ESP32 sits in the body. USB
//  power enters the bottom (battery lives on your belt).
//  Prints as a tray (open top) + a friction-fit lid.
// ============================================================

/* ---- coupler outer size (match your coupler .scad output) ---- */
cpl_l = 65;     // length / hole-row.  144/m = 65,  30/m = 212
cpl_w = 18.6;   // width.              144/m = 18.6, 30/m = 16.6
cpl_h = 12.3;   // height

/* ---- ESP32 board bay   ### CONFIRM your board's real size ### ---- */
esp_l = 52;     // board length (38-pin devkit ~ 52; 30-pin ~ 48)
esp_w = 28;     // board width  (~ 25.4–28)
esp_h = 13;     // height incl. header pins

/* ---- build params ---- */
wall    = 2.5;
floor_t = 2.0;
clr     = 0.8;   // clearance around parts
gap     = 5;     // gap between coupler and ESP bay
usb_d   = 9;     // USB cable pass-through (fits a grommet)
mic_d   = 4;     // mic port
lip     = 1.6;   // lid lip depth
lip_clr = 0.35;  // lid fit clearance
$fn = 48;

/* ---- derived ---- */
in_x  = max(cpl_l, esp_w) + 2*clr;
in_y  = cpl_h + gap + esp_l + 2*clr;
in_z  = max(cpl_w, esp_h) + 2*clr;
out_x = in_x + 2*wall;
out_y = in_y + 2*wall;
tray_h = floor_t + in_z;

// key interior anchors
cpl_y0 = wall + in_y - cpl_h;      // coupler pushed against +Y wall
cpl_x0 = wall + (in_x-cpl_l)/2;
slot_z = floor_t + cpl_w/2;        // fibre row height
esp_y0 = wall + clr;               // ESP at the bottom (low Y)
esp_x0 = wall + (in_x-esp_w)/2;

module tray() {
  difference() {
    cube([out_x, out_y, tray_h]);                 // shell
    translate([wall, wall, floor_t])
      cube([in_x, in_y, in_z + 2]);               // hollow, open top

    // fibre exit slot in +Y wall, aligned to the hole row
    slot_len = cpl_l - 12;
    translate([out_x/2 - slot_len/2, out_y - wall - 0.6, slot_z - 2.5])
      cube([slot_len, wall + 1.2, 5]);

    // USB power entry, -Y wall, at ESP height
    translate([out_x/2, -0.6, floor_t + esp_h/2])
      rotate([-90,0,0]) cylinder(d=usb_d, h=wall+1.2);

    // mic port, +X side wall, up near the coupler end
    translate([out_x-wall-0.6, out_y - 14, floor_t + in_z/2])
      rotate([0,90,0]) cylinder(d=mic_d, h=wall+1.2);
  }

  // coupler locating ribs (stop it sliding in X, hold against +Y wall)
  for (x=[cpl_x0-2.4, cpl_x0+cpl_l+0.4])
    translate([x, cpl_y0-3, floor_t]) cube([2, cpl_h+3, min(cpl_w,6)]);

  // ESP corner nubs (board drops between them; tape/glue to secure)
  for (dx=[0, esp_w], dy=[0, esp_l])
    translate([esp_x0+dx-1, esp_y0+dy-1, floor_t]) cube([2,2,3]);
}

module lid() {
  translate([0, out_y + 8, 0]) {
    cube([out_x, out_y, wall]);                    // plate
    // lip that drops into the interior
    translate([wall+lip_clr, wall+lip_clr, -lip])
      difference(){
        cube([in_x-2*lip_clr, in_y-2*lip_clr, lip]);
        translate([2,2,-1]) cube([in_x-2*lip_clr-4, in_y-2*lip_clr-4, lip+2]);
      }
  }
}

tray();
lid();
