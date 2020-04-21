/* 
   ==================================================================
   Rail Hooks for Erika85 table saw from Mafell.
   ------------------------------------------------------------------
   Author: Stefan Eppe
   Created: January 2019
   ==================================================================
   
   The aim is to allow jigs to be easily clampled to the table saw's 
   rails (sides, front or rear). The top of the hook is flush to the 
   table and three holes with countersinks allow fixing a board used 
   as base for a jig.
   The hook is composed of two pieces, the smaller one sliding in the 
   groove of the second one. The pieces are hold together and the 
   hook is clamped to the table saw by means of a metric bolt (M6x60). 
   Use a wingnut to make tightening the clamp easy. 
   
   ------------------------------------------------------------------
   
   This work is licensed under the Creative Commons Attribution-
   ShareAlike 4.0 International License (CC BY-SA 4.0). 
   To view a copy of this license, visit
   http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to
   Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
   
   ------------------------------------------------------------------
   
   Updates of this thing are publicly available on github at:
   https://github.com/nafep/workshop/tree/master/erika85/rail-hook
   
   ------------------------------------------------------------------

   NOTE: This is a fixed-sized piece. None of the parameters below 
         should be changed, except the first four, that may be
         modified to accomodate another bolt.
   
   ==================================================================
*/

// --- Params -------------------------------------

td = 6.5;  // screw thread diameter
sl = 60;   // length of screw (without head)
sh = 6;    // height of screw head
shd = 12.5;   // screw head diameter

nt = 10;   // "travel length" for wingnut on thread

hw = 20;   // hook width (of lower part)
hd = 8;    // hook depth

bd = 20;   // depth of upper and lower blocks (without fixing plate)

po = 10;   // upper fixing plate overhang
pd = 4.2;  // upper fixing plate mounting holes diameter

g = 5;     // gap between upper and lower hook

pt = 6;    // thickness of fixing plate
wt = 3;    // thickness of "guiding walls"
wp = 0.25; // "play" for guiding wall
wi = 0.1;  // penetration of guiding walls into other elements

ha = 30;   // hook angle (in degrees)

uhd = 6;  // upper hook distance (distance from upper plate to hook's inner corner)

ch = 28;   // hook clamping height  

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
                [ bd-hd+wp, 0 ] ,
                [ bd-hd+wp, uh-uhd ],
                [ bd+wp, uh-uhd-hh ],
                [ bd+wp, uh ],
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
        translate([-wt-wp,-lh,-wt-wp]) cube([bd-hd+wt+wp,th-pt-g+wi,wt]);
        translate([-wt-wp,-lh, hw+wp]) cube([bd-hd+wt+wp,th-pt-g+wi,wt]);
        translate([-wt-wp,-lh, -wp-wi]) cube([wt,th-pt-g+wi,hw+2*wp+2*wi]);
        translate([wi,wi+uh-pt,hw-(bd-hd)/2])
            linear_extrude(height=wt) polygon([ [-wt-wp,0], [-wt-wp-po,0], [-wt-wp,-(th-pt-g)] ]);
        translate([wi,wi+uh-pt,(bd-hd)/2-wt-wp])
            linear_extrude(height=wt) polygon([ [-wt-wp,0], [-wt-wp-po,0], [-wt-wp,-(th-pt-g)] ]);            
        translate([(bd-hd)/2-wt,uh-pt+wi,hw-wi])
            rotate([0,90,0])
            linear_extrude(height=wt) polygon([ [-wt-wp,0], [-wt-wp-po,0], [-wt-wp,-(th-pt-g)] ]);
        translate([(bd-hd)/2,uh-pt+wi,wi])
            rotate([0,-90,0])
            linear_extrude(height=wt) polygon([ [-wt-wp,0], [-wt-wp-po,0], [-wt-wp,-(th-pt-g)] ]);
        }
}

module tightening_bolt() {
    translate([bd-hd-td/2-2,uh+1,hw/2])
    rotate([90,0,0])
    union() {
    cylinder (d=shd, h=sh+1, $fn=6);
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
    
        translate([-wp,0,-wp])
        linear_extrude (height=hw+2*wp)
        top_profile();

        fixing_plate();
        guiding_walls();
    }
    
    tightening_bolt();
}