

w = 11;  // Width of block

alpha = atan(1/4);   // Climbing angle 
d = 6;  // Final wheel elevation
c = 1;   // "Groove" deepness for wheel
rho = 5;   // Radius for rounded hill
r = 11;    // Wheel radius
b = 15;     // Border width

a = 1.3*r;   // Length of flat, low level area before the ramp
g = 2;    // Height ("Ground" elevation) of the low level area before the ramp

s = 10;    // Height of screw hole "plateau"

// --- INTERNALS ---

y2 = d + r;
y1 = d + c - rho;
x1 = (y1 + rho*cos(alpha))/tan(alpha) + rho*sin(alpha);

    cosBeta = (d+r-y1)/(r+rho);
    sinBeta = sqrt(1 - cosBeta*cosBeta);

x2 = x1 + (r+rho)*sinBeta;

l = x2 + r + b;


$fn=100;

module screw_hole(){
    translate([0,3*r-0.01,0])
    rotate([90,0,0]) 
        union() {
            cylinder(d=10,h=3*r);
            cylinder(d=5,h=6*r);
        };  
}

module ramp() {
    difference(){

        linear_extrude(w) {
            difference(){
                union() {
                    translate([0,0]) polygon([[0,0],[l,0],[l,y2],[x2,y2],[x1,y1],[x1-rho*sin(alpha),y1+rho*cos(alpha)]]);
                    translate([x1,y1]) circle(r=rho);
                };        
                
                translate([x2,y2]) circle(r=r, $fn=200);        
                translate([0,-2*rho]) square([l,2*rho]);
            };
        };

        translate([l-b/2,s,w/2]) screw_hole();
    };
}

module base() {
    difference(){
        union(){
            cube([a+b+l,g,w]);
            cube([b+r,g+r,w]);
        }
        translate([b+r,g+r,-0.1]) cylinder(r=r,h=w+0.2, $fn=200);
        translate([b/2,s,w/2]) screw_hole();
        translate([a+b+l-b/2,s,w/2]) screw_hole();

    }
}

rotate([90,0,0])  // better orient for 3D-printing
union(){
    translate([a+b,g,0]) ramp();
    base();
}