

w = 18;  // Width of block

alpha = atan(1/4);   // Climbing angle 
d = 5;  // Final wheel elevation
c = 1;   // "Groove" deepness for wheel
rho = 10;   // Radius for rounded hill
r = 12.5;    // Wheel radius
b = 15;     // Final border width



y2 = d + r;
y1 = d + c - rho;
x1 = (y1 + rho*cos(alpha))/tan(alpha) + rho*sin(alpha);

    cosBeta = (d+r-y1)/(r+rho);
    sinBeta = sqrt(1 - cosBeta*cosBeta);

x2 = x1 + (r+rho)*sinBeta;

// translate([0,d,0]) cube([l+2,c,1]);   // test

l = x2 + r + b;


$fn=100;

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

    translate([l-b/2,y2+10,w/2]) rotate([90,0,0]) union() {
        cylinder(d=10,h=y2);
        cylinder(d=5,h=y2*2);
    };  
};