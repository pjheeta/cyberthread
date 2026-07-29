// ============================================================
//  NORDLJUS — SK9822 -> fibre coupler block   (parametric)
//  Holds 8 fibres, one over each LED. The strip drops into a
//  channel on the underside so the holes self-align to the LEDs.
//
//  MEASURED VALUES (from BTF spec sheet):
//    30 LED/m  : pitch 28.0 mm, strip width 10 mm
//    144 LED/m : pitch 6.94 mm, strip width 12 mm
// ============================================================

pitch      = 28.0;      // 30/m = 28.0  |  144/m = 6.944   ### confirm ###
strip_w    = 10.0;      // 30/m = 10    |  144/m = 12
fiber_d    = 2.0;       // fibre OUTER diameter (mm)        ### measure ###
num_holes  = 8;

hole_comp  = 0.20;      // FDM hole-shrink compensation (tune on a test print)
strip_clr  = 0.6;
pcb_t      = 1.0;
led_h      = 1.8;
roof       = 9.0;
wall       = 3.0;
end_margin = 8.0;
chamfer    = 0.9;

segment    = 0;         // 0 full | 1 LEFT half | 2 RIGHT half

$fn = 64;

hole_d    = fiber_d + hole_comp;
channel_w = strip_w + strip_clr;
channel_d = pcb_t + led_h + 0.5;
height    = channel_d + roof;
width     = channel_w + 2*wall;
length    = 2*end_margin + (num_holes-1)*pitch;
x_split   = end_margin + (num_holes/2 - 0.5)*pitch;
function hx(i) = end_margin + i*pitch;

module block_full() {
  difference() {
    cube([length, width, height]);
    translate([-1, (width-channel_w)/2, -0.1])
      cube([length+2, channel_w, channel_d+0.1]);
    for (i=[0:num_holes-1])
      translate([hx(i), width/2, channel_d-0.1])
        cylinder(d=hole_d, h=height-channel_d+0.2);
    for (i=[0:num_holes-1])
      translate([hx(i), width/2, height-chamfer])
        cylinder(d1=hole_d, d2=hole_d+2*chamfer, h=chamfer+0.05);
  }
}

if (segment==0) block_full();
else if (segment==1)
  intersection(){ block_full(); translate([-1,-1,-1]) cube([x_split+1, width+2, height+2]); }
else
  intersection(){ block_full(); translate([x_split,-1,-1]) cube([length-x_split+1, width+2, height+2]); }
