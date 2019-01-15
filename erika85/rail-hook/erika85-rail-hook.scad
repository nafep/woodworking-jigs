$fn=40;

%   translate ([0,0,0])
    linear_extrude (height=30)
    polygon ([ [0,0],[20,0],[20,17.5],[15,15],[15,30],[0,30] ]);
    
translate ([8.5,-1,15])
rotate ([-90,0,0]) 	
cylinder (h=42, d=8.5);