/*
Engraving Letter Punch Gage

For haxagonal punch stamps
*/

// Height of punch stamp
stampHeight = 6.5;

// Width of a letter on the stamp
letterWidth = 4;

// Letter stretch factor (distance between stamps)
letterStretch = 1.1;

// Stamp play (space around the stamp to ease punching)
stampPlay = 0.1;

// Golabel dimensions
baseWidth = 60;
baseDepth = 40;
baseThickness = 4;

nPunchHoles = 12;

punchHolesOffset = 3;
gageThickness = 10;

// === INTERNALS ======================================

// -- compute stamp hexagonal diameter
stampDia = 2.0/sqrt(3)*stampHeight;

// -- compute gage dimensions
gageWidth = baseWidth;
gageDepth = stampHeight + 2*punchHolesOffset;
gageXpos = 0;
gageYpos = baseDepth - gageDepth;

letterStep = letterWidth * letterStretch;

holesXpos = gageXpos + (gageWidth - (nPunchHoles-1)*letterStep)/2;
holesYpos = gageYpos + gageDepth/2;

// === MAIN ===========================================

difference(){

    union(){
        cube([ baseWidth, baseDepth, baseThickness ]);
        translate([ gageXpos, gageYpos, 0 ]) 
            cube([ gageWidth, gageDepth, gageThickness ]);
    };

    union(){
        for( p = [1:nPunchHoles] )
            translate( [ holesXpos+(p-1)*letterStep, holesYpos, -1 ] ) {
                cylinder( h=gageThickness+2, d=stampDia+stampPlay, $fn=6 );
                //translate([-1,3.5,10.5]) linear_extrude(height=2) scale(0.3) text(str(p));
            };
    };
}
