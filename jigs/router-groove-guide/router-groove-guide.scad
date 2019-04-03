/*
Use a copy-ring to guide the router
*/

$fn=200;

guideHeight = 22;   // 22mm multiplex board

ringDia = 30.5;       // diameter of router's copy ring

screwDia = 4;       // diameter of hole for fixing screws in the rail
screwHeadDia = 7;   // diameter of hexa screw head
screwHeadHeight = 4;

railWidth = 16;     // outer width of (curtain) rail
railHeight = 10;    //  ---  height ---------------
railThickness = 1;  // thickness of rail walls
railOpeningWidth = 8;
railVertRecess = screwHeadHeight+1; // vertical recess of curtain rail

echo("****************************************");
echo("VERTICAL RAIL RECESS: ",railVertRecess+railHeight);
echo("****************************************");

solidLength = 35;   // length of the piece that has to be printed full piece width


// --- internals ---

W = ringDia + 2*railWidth - 0.5; // 0.5mm recess to make sure the main body is clamped
H = guideHeight - 1; // 1mm recess to prevent the piece to protrude the guide
L = ringDia + solidLength;

gaugeRecess = 2;

// -- static recess for successive gauges;

translate([0,0,H]) 
    rotate([0,180,0])    
        union(){
            difference(){
                body();
                gaugeLine(dia=18, recess=1);
                gaugeLine(dia=15, recess=2);    
                gaugeLine(dia=12, recess=3);
            }
            centralLine(recess=3);
            translate([0,-L+ringDia/2+2*gaugeRecess,0]) centralLine(recess=3);
        }


tNutLength = 20;

translate([0,0,0.75*(railHeight-2*railThickness)])
    rotate([0,180,0])
        union(){
            tNut(length = tNutLength, t=[W/2+10,10-tNutLength/2,0]);
            tNut(length = tNutLength, t=[W/2+10,L-10-tNutLength/2,0]);
            tNut(length = tNutLength, t=[-W/2-10,10-tNutLength/2,0]);
            tNut(length = tNutLength, t=[-W/2-10,L-10-tNutLength/2,0]);
        }




module tNut(length=10, t = [0,0,0]) {
    width = 0.75*(railWidth-2*railThickness);
    height=0.75*(railHeight-2*railThickness);
    difference() {
        translate(t) translate([-width/2,0,0]) cube([width,length,height]);
        translate(t) translate([0,length/2,0]) __screwHole(headSides=6, rot=[0,180,90], headDia=8, headHeight=3);
    }
}


module gaugeLine(dia, recess = 1) {
    translate([-dia/2,L-ringDia/2-(recess-1)*gaugeRecess,-0.1])
        cube([dia,L+0.1,H-railVertRecess/2+0.1]);
}

module centralLine(recess = 1) {
    translate([0,L-ringDia/2-(recess-1)*gaugeRecess-gaugeRecess,-0.1])
        rotate([0,0,45])
        cube([sqrt(2)*gaugeRecess,sqrt(2)*gaugeRecess,H-railVertRecess/2+0.1]);
}


module body() {
    difference() {

        union() {
            difference() {
                translate([-W/2,0,0]) cube([W,L,H]);
                
                translate([W/2-railWidth,-0.1,-0.1]) cube([railWidth+0.1,L+0.2,H-railVertRecess+0.1]);
                translate([-W/2-0.1,-0.1,-0.1]) cube([railWidth+0.1,L+0.2,H-railVertRecess+0.1]);
            }
            
            translate([(W-railWidth-railOpeningWidth)/2,0,H-railVertRecess-0.75*railThickness])
                cube([railOpeningWidth-0.2,L,railThickness+0.1]);
            translate([-(W-railWidth+railOpeningWidth)/2,0,H-railVertRecess-0.75*railThickness])
                cube([railOpeningWidth-0.2,L,railThickness+0.1]);            
        }
        
        translate([0,L,-0.1]) cylinder (h=H+0.2, d=ringDia);
        
        __screwHole([(W-railWidth)/2,10,H]);
        __screwHole([(W-railWidth)/2,L-10,H]);
        __screwHole([(-W+railWidth)/2,10,H]);
        __screwHole([(-W+railWidth)/2,L-10,H]);
    }
}


module __screwHole(tran = [0,0,0], rot = [0,0,0], headSides = 100, headDia = screwHeadDia, headHeight = screwHeadHeight) {
    translate(tran) 
    rotate(rot) {
        union(){
            translate([0,0,-H-0.1]) cylinder(h=H+0.2, d=screwDia+0.2, $fn=100);
            translate([0,0,-headHeight-0.2]) cylinder(h=H+0.1, d=headDia+0.2, $fn = headSides);
        }
    }
}

