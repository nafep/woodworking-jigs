w = 18;   // block width
d = 90;   // block depth

uh = 20;   // upper block height
lh = 40;   // lower block height

rd = 6;  // rod diameter 

// ---------------------------------------------------------------

s = 5;    // spacing between upper and lower blocks

bw = w-4;  // button width
bh = bw;   // button height
bwt = 5;     // button wall thickness

bsl = 5;   // button spring length
bsd = 8;    // button spring diameter
bpd = 7.5;   // button pushing depth
bfp = 2;    // button front protrusion

ufh = 10;   // upperblock horizontal fixing extension height
uft = bwt-2;    // upperblock horizontal fixing extension thickness

ciw = rd+4;    // clamping iron width
cif = 4;       // clamping iron front depth
cib = 10;      // clamping iron back depth
cimp = 5;   // clamping spring minimal vertical protrusion
cixp = 10;  // clamping spring max vertical protrusion

// Internal/computed params (do not change unless you understand what you are doing!)

$fn = 100;

ss = 0.2;   // sliding space around parts (for easy sliding where required)
by = lh - bh*1.5;  // button y-position

rdf = bpd+cif+rd/2+2*ss;  // rod distance from front border
rdb = 40;  // rod distance from back border
rwt = 5;  // rod wall thickness (top of upper block)

lrr = 5;  // lower block rod recess depth

csd = 12;  // clamping spring diameter
csr = 2;  // clamping spring recess hole depth


bssd = 12;  // block spacing spring diameter
bssr = 2;  // block spacing spring recess hole depth


fpf = 12;   // foot pin distance from front
fpr = 10;   // foot pin recess depth
fpd = 8;    // foot pin diameter
fpsd = 32;  // foot pin spacing distance


//#tmpRod();

// All three pieces aligned for 3d-printing
rotate ([0,180,0]) upperBlock([-w,0,-uh]);
lowerBlock([w+s,0,0]);
translate([2*(w+s)+bw,0,0]) rotate ([0,180,0]) button([0,bfp,-bh]);


// Debug
/*
upperBlock([0,0,lh+s]);
lowerBlock();
button([(w-bw)/2,0,by]);
*/


module tmpRod(t = [0,0,0]) {
    translate(t) {
        translate([w/2,rdf,by-lrr-s-0.1]) cylinder(h=lrr+(lh-by)+s+(uh-rwt)+0.2,d=rd);
        translate([w/2,d-rdb,by-lrr-s-0.1]) cylinder(h=lrr+(lh-by)+s+(uh-rwt)+0.2,d=rd);
    };
}


module buttonRodHole(t = [0,0,0]) {
    translate(t) {
        hull(){
        translate([0,-bpd,-0.1]) cylinder(h=bh+0.2,d=rd+ss);
        translate([0,,-0.1]) cylinder(h=bh+0.2,d=rd+ss);
        };
    };
}

module buttonClampingIronHole(t = [0,0,0]) {
    translate(t) {
        union(){
            translate([-ciw/2-ss,-rd/2-bpd-cif,-0.1]) cube([ciw+2*ss,rd+bpd+cif,cimp+0.1]);
            translate([-ciw/2-ss,0,-0.1]) cube([ciw+2*ss,rd/2+cib+ss,cixp+0.1]);
        };
    };
}


module upperBlock(t = [0,0,0]) {
    translate(t) {
        difference() {
            union() {
                cube([w,d,uh]);
                translate([0,d-uft,-ufh]) cube([w,uft,ufh+0.1]);  // horizontal fixing extension
            };
            
            // rod hole
            translate([w/2,rdf,-0.1]) cylinder(h=uh-rwt+0.1,d=rd);  // front
            translate([w/2,d-rdb,-0.1]) cylinder(h=uh-rwt+0.1,d=rd);   // back
            
            // block spacing spring recess
            translate([w/2,rdf,-0.1]) cylinder(h=bssr+0.1,d=bssd+ss);  // front
            translate([w/2,d-rdb,-0.1]) cylinder(h=bssr+0.1,d=bssd+ss); // back
        };
    };
}


module lowerBlock(t = [0,0,0]) {
    translate(t) {
        difference() {
            cube([w,d,lh]);
            translate([(w-bw)/2-ss,-1,by-ss]) cube([bw+2*ss,d-bwt+ss+1,bh+2*ss]);  // button sliding hole
            translate([-0.1,d-uft-ss,lh-ufh]) cube([w+2,uft+ss+0.2,ufh+0.1]); // horizontal fixing extension
            
            // rod hole
            translate([w/2,rdf,by-lrr]) cylinder(h=lh-by+lrr+0.1,d=rd+2*ss);
            translate([w/2,d-rdb,by-lrr]) cylinder(h=lh-by+lrr+0.1,d=rd+2*ss);
            
            // block spacing spring recess
            translate([w/2,rdf,lh-bssr]) cylinder(h=bssr+0.1,d=bssd+ss); // front
            translate([w/2,d-rdb,lh-bssr]) cylinder(h=bssr+0.1,d=bssd+ss); // back
            
            // clamping spring recess
            translate([w/2,rdf,by-csr]) cylinder(h=csr+0.1,d=csd+ss);   // front
            translate([w/2,d-rdb,by-csr]) cylinder(h=csr+0.1,d=csd+ss);   // back
            
            // holes for "Ikea sys32 foot"
            translate([w/2,fpf,-0.1]) cylinder(h=fpr,d=fpd);
            translate([w/2,fpf+fpsd,-0.1]) cylinder(h=fpr,d=fpd);
        };
    };
}


module button(t = [0,0,0]) {
    translate(t) {
        difference() {
            translate([0,-bfp,0]) cube([bw,d-bwt-bpd+bfp,bh]);
            translate([bw/2,d-bwt-bpd+1,bh/2]) rotate([90,0,0]) cylinder(h=bsl+1,d=bsd);  // back spring
            buttonRodHole([bw/2,rdf,0]);  // hole for front rod
            buttonRodHole([bw/2,d-rdb,0]);  // hole for back rod
            buttonClampingIronHole([bw/2,rdf,0]);  // hole for front clamping iron
            buttonClampingIronHole([bw/2,d-rdb,0]);  // hole for front clamping iron
        };
    };
}