// Parameters 
// Note: all lengths in millimeters

motorBearingDistance = 40;

bearingOuterDia = 23;
bearingInnerDia = 8;
bearingThickness = 8;

fixingScrewDia = 3.5;


// Other params

wallThickness = 4;

motorWidth = 42;
motorLipDia = 23;
motorScrewDia = 3.2;
motorScrewDistance = 31;
motorScrewingDia = motorScrewDia*1.5;

// Derived params

totalLength = motorBearingDistance + 2*wallThickness + bearingThickness;

totalWidth = motorWidth + wallThickness;



//

$fn = 30;


module ScrewCountersink (screwDia) {
    translate([0,0,-0.5*screwDia]) {
    cylinder (h=screwDia/2,d2=2*screwDia,d=screwDia);
    translate([0,0,screwDia/2]) cylinder (h=0.3*screwDia,d=2*screwDia);
    translate([0,0,-(screwDia/2+wallThickness)]) cylinder (h=(screwDia/2+wallThickness),d=screwDia);    
    }
}

difference() {
    
union() {
cube([wallThickness,totalWidth,totalWidth]);    // Front (motor mount)
translate([totalLength-(wallThickness+bearingThickness),0,0]) cube([wallThickness+bearingThickness,totalWidth,totalWidth]);    // Rear (bearing mount)

cube([totalLength,totalWidth,wallThickness]);  // Base

cube([totalLength,wallThickness,totalWidth]);  // Lateral 1
translate([0,totalWidth-wallThickness,0]) cube([totalLength,wallThickness,totalWidth/2]);  // Lateral 2
}

union() {
translate ([-wallThickness*0.1,totalWidth/2,totalWidth/2]) rotate([0,90,0]) cylinder(wallThickness*1.2,d=motorLipDia);

translate ([0,totalWidth/2-motorScrewDistance/2,totalWidth/2-motorScrewDistance/2])
{
rotate([0,90,0]) cylinder(wallThickness*1.2,d=motorScrewDia);
translate ([0,motorScrewDistance,0]) rotate([0,90,0]) cylinder(wallThickness*1.2,d=motorScrewDia);
translate ([0,0,motorScrewDistance]) rotate([0,90,0]) cylinder(wallThickness*1.2,d=motorScrewDia);    
translate ([0,motorScrewDistance,motorScrewDistance]) rotate([0,90,0]) cylinder(wallThickness*1.2,d=motorScrewDia);    
}

translate ([totalLength-(2*wallThickness+bearingThickness),totalWidth/2-motorScrewDistance/2,totalWidth/2-motorScrewDistance/2])
{
rotate([0,90,0]) cylinder((2*wallThickness+bearingThickness)*1.2,d=motorScrewingDia);
translate ([0,motorScrewDistance,0]) rotate([0,90,0]) cylinder((2*wallThickness+bearingThickness)*1.2,d=motorScrewingDia);
translate ([0,0,motorScrewDistance]) rotate([0,90,0]) cylinder((2*wallThickness+bearingThickness)*1.2,d=motorScrewingDia);    
translate ([0,motorScrewDistance,motorScrewDistance]) rotate([0,90,0]) cylinder((2*wallThickness+bearingThickness)*1.2,d=motorScrewingDia);    
}
}

// Bearing hole
union() {
translate ([totalLength-1.1*(wallThickness+bearingThickness),totalWidth/2,totalWidth/2]) rotate([0,90,0]) union(){   
        cylinder(1*(bearingThickness+wallThickness),d=bearingOuterDia);
        cylinder(1.2*(bearingThickness+wallThickness),d=bearingOuterDia*0.75);}

}

// "Chassis" fixing holes
union() {
    translate([fixingScrewDia*2+wallThickness,wallThickness,0]) {
    translate([0,0,fixingScrewDia*2+wallThickness]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    translate([0,0,totalWidth-(fixingScrewDia*2+wallThickness)]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    }

    translate([totalLength-(fixingScrewDia*2+wallThickness+bearingThickness),wallThickness,0]) {
    translate([0,0,fixingScrewDia*2+wallThickness]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    translate([0,0,totalWidth-(fixingScrewDia*2+wallThickness)]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    }
}

translate([0,totalWidth,wallThickness]) 
rotate([90,0,0]) {
    translate([fixingScrewDia*2+wallThickness,0,0]) {
    translate([0,0,fixingScrewDia*2+wallThickness]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    translate([0,0,totalWidth-(fixingScrewDia*2+wallThickness)]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    }

    translate([totalLength-(fixingScrewDia*2+wallThickness+bearingThickness),0,0]) {
    translate([0,0,fixingScrewDia*2+wallThickness]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    translate([0,0,totalWidth-(fixingScrewDia*2+wallThickness)]) rotate ([-90,0,0]) ScrewCountersink(fixingScrewDia);
    }
}

}
