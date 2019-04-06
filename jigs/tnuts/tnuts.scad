/*
Simple t-nuts for dirt-cheap curtain rails
*/

$fn=50;

width = 12;
height = 7;
length = 20;

edge = -3;  // edge radius (if >0, then only vertically rounded edges, if <0 then all edges are rounded)


screwDia = 4;
screwHeadDia = 7;
screwHeadHeight = 3;


// How many nuts to print?
n = 8; // if set different than 0, this is the number of pieces printed
rows = 0; // if set greater than 0, this is the number of rows to print
// By default (n=0 and rows=0), the full bed is covered with t-nuts...

bedWidth = 110;
bedDepth = 130;
minSep = 5;    // minimum separation between printed nuts


tNutArray();


module tNutArray(){
    nutsPerRow = floor( (bedWidth+minSep) / (width+minSep) );
    maxRows = floor( (bedDepth+minSep) / (length+minSep) );
    
    for( j = [0:maxRows-1] )
        for( i = [0:nutsPerRow-1] ) {
            if( (n > 0 && i + j*nutsPerRow < n) || (rows > 0 && j < rows) || (n == 0 && rows == 0) )
                translate( [i*(width+minSep)+width/2, j*(length+minSep), 0] )
                    tNut(length=length, r = edge);
        }
}

module tNut(length=10, t = [0,0,0], r = 0) {
    translate(t)
    translate([0,0,height])
    rotate([0,180,0])
    intersection() {
        /*
        translate([-width/2,0,height]) rotate([-90,0,0]) 
            linear_extrude(length+0.2) 
                translate([r,r,0])
                    offset(r) 
                        square([width-2*r,height-2*r]);
        */
        difference() {
            if( r == 0 ) {    
                translate(t) translate([-width/2,0,0]) cube([width,length,height]);
            } else 
            if( r < 0 ) {
                translate(t) translate([-width/2,0,0]) rcube([width,length,height],-r);
            } else {
                translate(t) translate([-width/2,0,0]) hrcube([width,length,height],r);
            }
            
            translate(t) translate([0,length/2,0]) __screwHole(headSides=6, rot=[0,180,90], headDia=8, headHeight=3);
        }
    }
}


module __screwHole(tran = [0,0,0], rot = [0,0,0], headSides = 100, headDia = screwHeadDia, headHeight = screwHeadHeight) {
    translate(tran) 
    rotate(rot) {
        union(){
            translate([0,0,-height-0.1]) cylinder(h=height+0.2, d=screwDia+0.4, $fn=100);
            translate([0,0,-headHeight-0.2]) cylinder(h=height+0.1, d=headDia+0.6, $fn = headSides);
        }
    }
}


module rcube(dim=[10,10,10], r=2) {
    X = dim[0];
    Y = dim[1];
    Z = dim[2];
    hull(){
        translate( [   r ,   r ,   r ]) sphere(r);
        translate( [ X-r ,   r ,   r ]) sphere(r);
        translate( [ X-r , Y-r ,   r ]) sphere(r);
        translate( [   r , Y-r ,   r ]) sphere(r);
        translate( [   r ,   r , Z-r ]) sphere(r);
        translate( [ X-r ,   r , Z-r ]) sphere(r);
        translate( [ X-r , Y-r , Z-r ]) sphere(r);
        translate( [   r , Y-r , Z-r ]) sphere(r);    
    }
}

module hrcube(dim=[10,10,10], r=2) {
    X = dim[0];
    Y = dim[1];
    Z = dim[2];
    linear_extrude(Z)
        offset(r) 
            translate([r,r]) 
                square([X-2*r,Y-2*r]);
}