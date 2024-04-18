/* This is a printable assembly holder for all the circuits

You will need:
* 3D Printer
* M3 or M2 Threaded Inserts (set size below)
* M3 or M2 screws

*/

holder_thickness_height = 3;

threaded_insert_length_height = 5.5; // M3 = 5.5, M2.5 = TBD, M2 = TBD
threaded_insert_diameter      = 4;   // M3 = 4,   M2.5 = TBD, M2 = TBD

// Define your circuits here. 
// Measure length,width from center to center of each screw hole.
circuit_dimensions = [
//  [length, width, x_position, y_position]
    [35.4, 50.8, 28.0, 21.8], // Low power cut off circuit
    [20.0, 38.0,  0.5, 23.0], // Lolin32 ESP32
    [30.1, 15.7, 31.0, -1.0], // 3.3V voltage regulator
  //[30.1, 15.7,  0.0, -1.0], // 3.3V voltage regulator
];

upright_spacing_y = 24;
upright_width_x   = 9;

/* **************
MATH 
***************** */
$fn = 25;
wall_thickness = 2;
loose_fit    = 2.0;
sliding_fit  = 0.2;
friction_fit = 0.02;

holder_lower_height = holder_thickness_height + 0.2;
screw_holder_height = threaded_insert_length_height + 2;
screw_holder_inner_diameter=threaded_insert_diameter+sliding_fit;
screw_holder_outer_diameter=threaded_insert_diameter+wall_thickness*2;

// Collect all x and y extents into lists
x_extents = [for (circuit = circuit_dimensions) circuit[2] + circuit[0]];
y_extents = [for (circuit = circuit_dimensions) circuit[3] + circuit[1]];

// Calculate maximum extents
max_x = max(x_extents) + screw_holder_outer_diameter + 0.5;
max_y = max(y_extents) + screw_holder_outer_diameter + 0.5;

/* **************
DRAWING 
***************** */

// Loop through each set of dimensions and place the circuit holder
for (circuit = circuit_dimensions) {
    translate([circuit[2], circuit[3], 0])  // x_position, y_position
        circuit_holder(circuit[0], circuit[1], screw_holder_height);  // length and width
}

draw_outer_box();

translate([0, 0,0]) draw_upright_mount(height=51, screw_z_pos1=8, screw_z_pos2=48);
translate([40,0,0]) draw_upright_mount(height=11, screw_z_pos1=8);

/* **************
MODULES 
***************** */

module draw_upright_mount(height, screw_z_pos1=0, screw_z_pos2=0)
{
    translate([0,max_y-screw_holder_outer_diameter/2,0])
    {
        difference()
        {
            union()
            {
                //horizontal
                cube([upright_width_x,upright_spacing_y,holder_thickness_height]);
                //vertical
                translate([0,upright_spacing_y,0])
                cube([upright_width_x,screw_holder_height,height]);
            }
            
            if(screw_z_pos1) upright_screw_hole(screw_z_pos1);
            if(screw_z_pos2) upright_screw_hole(screw_z_pos2);
        }
    }
}

module upright_screw_hole(screw_z_pos)
{
    translate([upright_width_x/2,upright_spacing_y+screw_holder_height+1,screw_z_pos]) rotate([90,0,0])
    cylinder(d=screw_holder_inner_diameter, h=screw_holder_height+2);
}

module draw_outer_box()
{
    translate([-screw_holder_outer_diameter/2, -screw_holder_outer_diameter/2, 0])
        circuit_holder(max_x, max_y, holder_lower_height);
}

module circuit_holder(length, width, height=2) {

    // Place cylinders at each corner
    translate([length, 0,     0]) screw_holder(height);
    translate([0,      width, 0]) screw_holder(height);
    translate([0,      0,     0]) screw_holder(height);
    translate([length, width, 0]) screw_holder(height);
               
    //Draw links
    screw_mount_links(length, width);
}

module screw_holder(height=2)
{
    translate([0,0,height/2])
    difference()
    {
        cylinder(h = height,   d = screw_holder_outer_diameter, center = true);
        cylinder(h = height+1, d = screw_holder_inner_diameter, center = true);
    }
}

module screw_mount_links(length, width) {
    diameter = screw_holder_outer_diameter;
    radius = screw_holder_outer_diameter / 2;
    height = holder_thickness_height;
    offset_position1 = radius - wall_thickness/2;
    offset_position2 = - wall_thickness/2;
    
    // Horizontal connections
    translate([offset_position1, -wall_thickness/2, 0]) 
       cube([length - diameter + wall_thickness, wall_thickness, height]);
    translate([offset_position1, width + offset_position2, 0]) 
       cube([length - diameter + wall_thickness, wall_thickness, height]);
    
    // Vertical connections
    translate([-wall_thickness/2, offset_position1, 0])
       cube([wall_thickness, width - diameter + wall_thickness, holder_thickness_height]);
    translate([length + offset_position2, offset_position1, 0])
       cube([wall_thickness, width - diameter + wall_thickness, holder_thickness_height]);
}
