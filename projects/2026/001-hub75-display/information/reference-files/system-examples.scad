/* [View Options] */
// Kies hoe je de samenstelling wilt bekijken:
view_mode = "System_B_Slide_Exploded"; // [System_A_Assembled, System_A_Exploded, System_B_Assembled, System_B_Slide_Exploded]

/* [Parameters] */
$fn = 50;

// 1. BASE: Vaste aluminium frame afmetingen (20-serie profiel)
frame_width = 840; 
frame_height = 360;  
frame_thickness = 20;    

// 2. DISPLAY UNITS: Fysieke afmetingen van een enkel horizontaal P5 paneel (320x160mm)
panel_width = 320; 
panel_height = 160; 
panel_thickness = 15;
panel_count = 5;

screen_width = 800; 
screen_height = 320;  
visual_gap = 3; 

// 3. ENCLOSURE: Houten plaat afmetingen (10mm dik, 100mm diep)
wood_thickness = 10;
case_depth = 100; 

// Totale buitenmaten box
box_outer_w = frame_width + (2 * wood_thickness);
box_outer_h = frame_height + (2 * wood_thickness);

// Parameter voor de overstekende luifel (System B) tegen de regen
overhang_front = 15; 

// Kleurdefinities
color_wood = [0.85, 0.65, 0.45]; 
color_top_cap = [0.75, 0.55, 0.35];   
color_frame = [0.7, 0.7, 0.7, 0.6];  
color_panel_bezel = [0.2, 0.2, 0.2]; 
color_panel_pcb = [0.05, 0.05, 0.05];  
color_leds = [0.0, 0.9, 0.2];
color_screw = [0.9, 0.9, 0.9];       

// --- MODULES VOOR ONDERDELEN ---

module aluminum_frame() {
    color(color_frame) {
        translate([0, frame_height/2 - 10, 0]) cube([frame_width, 20, frame_thickness], center=true);
        translate([0, -frame_height/2 + 10, 0]) cube([frame_width, 20, frame_thickness], center=true);
        translate([frame_width/2 - 10, 0, 0]) cube([20, frame_height, frame_thickness], center=true);
        translate([-frame_width/2 + 10, 0, 0]) cube([20, frame_height, frame_thickness], center=true);
    }
}

module single_p5_panel() {
    color(color_panel_bezel) cube([panel_width - visual_gap, panel_height - visual_gap, panel_thickness], center=true);
    color(color_panel_pcb) translate([0, 0, 0.5]) cube([panel_width - 10 - visual_gap, panel_height - 10 - visual_gap, panel_thickness], center=true);
    color(color_leds) translate([0, 0, (panel_thickness/2) + 0.2]) cube([panel_width - 20 - visual_gap, panel_height - 20 - visual_gap, 0.5], center=true);
}

module modular_led_matrix() {
    rotated_panel_w = 160; 
    start_x = -(screen_width / 2) + (rotated_panel_w / 2); 
    for (i = [0 : panel_count - 1]) {
        translate([start_x + (i * rotated_panel_w), 0, 0]) 
            rotate([0, 0, 90]) 
                single_p5_panel();
    }
}

module full_display_assembly_block() {
    panel_offset_z = (frame_thickness/2) - (panel_thickness/2); 
    aluminum_frame();
    translate([0, 0, panel_offset_z]) modular_led_matrix();
}

// --- HOUTEN BEHUIZING SYSTEMEN ---

module part_front_lip_U_chassis() {
    color(color_wood) translate([0, 0, case_depth/2 - wood_thickness/2]) difference() {
        cube([box_outer_w, box_outer_h, wood_thickness], center=true);
        cube([screen_width, screen_height, wood_thickness + 2], center=true);
        translate([0, box_outer_h/2 - wood_thickness/2, 0])
            cube([box_outer_w + 2, wood_thickness + 2, wood_thickness + 2], center=true);
    }
}

module part_front_lip_top_bar() {
    color(color_wood) translate([0, box_outer_h/2 - wood_thickness/2, case_depth/2 - wood_thickness/2])
        difference() {
            cube([box_outer_w, wood_thickness, wood_thickness], center=true);
            cube([screen_width, wood_thickness + 2, wood_thickness + 2], center=true);
        }
}

module part_side_left() {
    color(color_wood) translate([-frame_width/2 - wood_thickness/2, 0, -wood_thickness/2])
        cube([wood_thickness, frame_height, case_depth - wood_thickness], center=true);
}

module part_side_right() {
    color(color_wood) translate([frame_width/2 + wood_thickness/2, 0, -wood_thickness/2])
        cube([wood_thickness, frame_height, case_depth - wood_thickness], center=true);
}

module part_bottom_board() {
    color(color_wood) translate([0, -frame_height/2 - wood_thickness/2, -wood_thickness/2])
        cube([frame_width, wood_thickness, case_depth - wood_thickness], center=true);
}

module part_top_board_system_A() {
    color(color_wood) translate([0, frame_height/2 + wood_thickness/2, -wood_thickness/2])
        cube([frame_width, wood_thickness, case_depth - wood_thickness], center=true);
}

module part_top_cap_system_B() {
    actual_cap_depth = (case_depth - wood_thickness) + overhang_front;
    z_offset = overhang_front / 2;
    
    translate([0, frame_height/2 + wood_thickness/2, -wood_thickness/2]) {
        color(color_top_cap) translate([0, 0, z_offset])
            cube([box_outer_w, wood_thickness, actual_cap_depth], center=true);
        
        color(color_top_cap) translate([-box_outer_w/2 - wood_thickness/2 + 5, -20, 0])
            cube([wood_thickness, 40, case_depth - wood_thickness], center=true);
            
        color(color_top_cap) translate([box_outer_w/2 + wood_thickness/2 - 5, -20, 0])
            cube([wood_thickness, 40, case_depth - wood_thickness], center=true);
    }
    part_front_lip_top_bar();
}

module part_screw() {
    color(color_screw) rotate([0, -90, 0]) { 
        cylinder(r=5, h=3, center=true); 
        translate([0, 0, -6]) cylinder(r=2.5, h=12, center=true); 
    }
}

module left_side_screws() {
    translate([-box_outer_w/2 - wood_thickness/2, frame_height/2 - 10, 15]) part_screw();
    translate([-box_outer_w/2 - wood_thickness/2, frame_height/2 - 10, -45]) part_screw();
}

module right_side_screws() {
    translate([box_outer_w/2 + wood_thickness/2, frame_height/2 - 10, 15]) rotate([0, 0, 180]) part_screw();
    translate([box_outer_w/2 + wood_thickness/2, frame_height/2 - 10, -45]) rotate([0, 0, 180]) part_screw();
}

module assembly_arrow() {
    color("Crimson") {
        cylinder(r=4, h=60);
        translate([0, 0, 30]) cylinder(r1=10, r2=0, h=20);
    }
}

// --- HOOFD WEERGAVE LOGICA ---

display_z_pos = (case_depth/2) - wood_thickness - (frame_thickness/2);

if (view_mode == "System_A_Assembled") {
    translate([0, 0, display_z_pos]) full_display_assembly_block();
    color(color_wood) translate([0, 0, case_depth/2 - wood_thickness/2]) difference() {
        cube([box_outer_w, box_outer_h, wood_thickness], center=true);
        cube([screen_width, screen_height, wood_thickness + 2], center=true);
    }
    part_side_left();
    part_side_right();
    part_bottom_board();
    part_top_board_system_A();
} 
else if (view_mode == "System_A_Exploded") {
    translate([0, 0, -140]) full_display_assembly_block(); 
    color(color_wood) translate([0, 0, case_depth/2 - wood_thickness/2]) difference() {
        cube([box_outer_w, box_outer_h, wood_thickness], center=true);
        cube([screen_width, screen_height, wood_thickness + 2], center=true);
    }
    part_side_left();
    part_side_right();
    part_bottom_board();
    part_top_board_system_A();
    translate([0, 0, -220]) assembly_arrow();
} 
else if (view_mode == "System_B_Assembled") {
    translate([0, 0, display_z_pos]) full_display_assembly_block();
    part_front_lip_U_chassis(); 
    part_side_left();
    part_side_right();
    part_bottom_board();
    part_top_cap_system_B();    
    left_side_screws();
    right_side_screws();
} 
else if (view_mode == "System_B_Slide_Exploded") {
    part_front_lip_U_chassis();
    part_side_left();
    part_side_right();
    part_bottom_board();
    
    // Displayblok schuift omhoog (Y-as)
    translate([0, 150, display_z_pos]) full_display_assembly_block();
    
    // Luifel schuift nog verder omhoog (Y-as)
    translate([0, 260, 0]) part_top_cap_system_B();
    
    // Boutjes wijken zijwaarts én omhoog uit
    translate([-60, 260, 0]) left_side_screws();
    translate([60, 260, 0]) right_side_screws();
    
    // Richtingspijlen voor de schuifrichting
    translate([0, frame_height/2 + 40, 0]) rotate([-90, 0, 0]) assembly_arrow();
    translate([0, frame_height/2 + 180, 0]) rotate([-90, 0, 0]) assembly_arrow();
}

