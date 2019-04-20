/*
Simple painting-cones to dry pannels under-faces
*/

$fn=50;

dia = 30;      // base diameter
height = 10;   // height of the cone


// How many nuts to print?
n = 0; // if set different than 0, this is the number of pieces printed
rows = 0; // if set greater than 0, this is the number of rows to print
// By default (n=0 and rows=0), the full bed is covered with t-nuts...

bedWidth = 110;
bedDepth = 130;
minSep = 5;    // minimum separation between printed nuts


elementArray(dia);


// --- Generic functions to print an array of pieces ------

// Place here a call to generate one single instance of the piece
module element() {
    cone(dia, height);
}



module elementArray( width, _length=0 ) {
    length = _length > 0 ? _length : width;
    elementsPerRow = floor( (bedWidth+minSep) / (width+minSep) );
    maxRows = floor( (bedDepth+minSep) / (length+minSep) );
    
    for( j = [0:maxRows-1] )
        for( i = [0:elementsPerRow-1] ) {
            if( (n > 0 && i + j*elementsPerRow < n) || (rows > 0 && j < rows) || (n == 0 && rows == 0) )
                translate( [i*(width+minSep)+width/2, j*(length+minSep)+length/2, 0] )
                    element();
        }
}



module cone(dia, height) {
    difference() {
        union() {
            cylinder(h=height/2, d = dia);
            cylinder(h=height, d2 = 0, d1 = dia);
        }
        translate([0,0,-height/2+1])
            cylinder(h=height, d2 = 0, d1 = dia);
    }
}