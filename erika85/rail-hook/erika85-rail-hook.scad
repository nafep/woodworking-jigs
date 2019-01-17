

// --- Params -------------------------------------

td = 6.5;  // screw thread diameter
sl = 60;   // length of screw (without head)
sh = 5;    // height of screw head
shd = 12.5;   // screw head diameter

nt = 10;   // "travel length" for wingnut on thread

hw = 20;   // hook width (of lower part)
hd = 8;    // hook depth

bd = 20;   // depth of upper and lower blocks (without fixing plate)

po = 10;   // upper fixing plate overhang
pd = 4.2;  // upper fixing plate mounting holes diameter

g = 5;     // gap between upper and lower hook

pt = 5;    // thickness of fixing plate
wt = 2;    // thickness of "guiding walls"
wp = 0.25; // "play" for guiding wall

ha = 30;   // hook angle (in degrees)

uhd = 5.5;  // upper hook distance (distance from upper plate to hook's inner corner)

ch = 29;   // hook clamping height  

fsd = 4;   // fixing screws diameter

// --- Derived params -----------------------------

stl = sl + sh;    // screw total length

th = stl - nt;    // total height for lower and upper part + gap

lh = (th - g) / 2;  // height of lower part
uh = lh;          // height of upper part

lhd = th - g - ch - uhd;  // lower hook distance (height from block bottom to hook's inner corner)

hh = hd * sin(ha);  // height of hook

// ------------------------------------------------

$fn=40;

// ------------------------------------------------


module bottom_profile() {
    polygon ([  [ 0, 0 ] ,
                [ bd, 0 ] ,
                [ bd, lhd+hh ] ,
                [ bd-hd, lhd ] ,
                [ bd-hd, lh] ,
                [ 0, lh] 
            ]);
}

module top_profile() {
    polygon ([  [ 0, 0 ] ,
                [ bd-hd, 0 ] ,
                [ bd-hd, uh-uhd ],
                [ bd, uh-uhd-hh ],
                [ bd, uh ],
                [ 0, uh ] 
            ]);
}

module tapered_screw_hole (dia,headDia,depth) {
    union() {
    translate ([0,0,-depth])
        cylinder (d=dia, h=depth);
    translate ([0,0,-headDia/2])
        cylinder (d2=headDia, d1=0, h=headDia/2);
    cylinder(d=headDia, h=depth/2);
    }
}

module fixing_plate() {
    
    difference(){
    // plate
    translate([-po-pt,uh-pt,-po-pt])
    cube([bd+po+pt,pt,hw+2*pt+2*po]);
    
    // mounting screw holes
    translate ([-fsd-pt/2-wt,uh-pt,-fsd-pt/2-wt]) rotate([90,0,0]) tapered_screw_hole(fsd,fsd*2,2*pt);
    translate ([bd-po+fsd,uh-pt,-fsd-pt/2-wt]) rotate([90,0,0]) tapered_screw_hole(fsd,fsd*2,2*pt);        
    translate ([-fsd-pt/2-wt,uh-pt,hw+fsd+wt+pt/2]) rotate([90,0,0]) tapered_screw_hole(fsd,fsd*2,2*pt);        
    translate ([bd-po+fsd,uh-pt,hw+fsd+wt+pt/2]) rotate([90,0,0]) tapered_screw_hole(fsd,fsd*2,2*pt);    
    }
}

module guiding_walls() {
    union() {
    translate([-wt-wp,-lh,-wt-wp]) cube([bd-hd+wt+wp,th-g,wt]);
    translate([-wt-wp,-lh, hw+wp]) cube([bd-hd+wt+wp,th-g,wt]);
    translate([-wt-wp,-lh, -wp]) cube([wt,th-g,hw+2*wp]);
    }
}

module tightening_bolt() {
    translate([bd-hd-td/2-2,uh+1,hw/2])
    rotate([90,0,0])
    union() {
    cylinder (d=shd, h=sh+1, $fn=8);
    cylinder (d=td, h=stl+1);
    }
}

// ------------------------------------------------

difference() {

translate([0,-lh-g,0])
linear_extrude (height=hw)
bottom_profile();

tightening_bolt();
}    



translate([0,20,lh])
rotate([-90,0,0])

difference() {
    union(){
    translate([0,0,-wp])
    linear_extrude (height=hw+2*wp)
    top_profile();

    fixing_plate();
    guiding_walls();
    }
    
    tightening_bolt();
}