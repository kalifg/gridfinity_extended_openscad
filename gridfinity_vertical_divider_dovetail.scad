// Dovetail variant of 'gridfinity_vertical_divider.scad'.
// The cup is printed with vertical dovetail pillars on its inside left/right walls.
// Dividers are printed as separate flat pieces with matching dovetail tabs and
// slide down into the pillars. This is much faster to print than the integrated
// version and lets dividers be added/removed/rearranged after printing.

include <modules/module_item_holder.scad>
include <modules/gridfinity_constants.scad>
include <modules/functions_general.scad>
use <modules/module_gridfinity_cup.scad>
include <modules/module_gridfinity_cup_base.scad>
use <modules/module_gridfinity_block.scad>
include <modules/module_patterns.scad>

/* [Render] */
// Which part(s) to render. "all" = cup + installed dividers (preview), "cup" = printable cup with empty slots, "dividers" = all dividers laid flat for printing, "single_divider" = one divider laid flat.
render_mode = "all"; // [all, cup, dividers, single_divider]

/* [Divider] */
divider_count = 4;
divider_height = 50;
divider_width = 3;
divider_base_height = 10;
divider_radius = 5;
divider_front_top_inset=20;
divider_front_top_angle=45;
divider_back_top_inset=20;
divider_back_top_angle=45;
// Tilt angle of each divider in degrees. 0 = upright. Non-zero tilts the slots in the cup pillars (and the preview-installed dividers) at the matching angle. The printed divider itself is still printed flat; the pillars carry the tilt.
divider_angle = 0;

/* [Dovetail] */
// Depth the tab pokes into the slot (mm)
dovetail_depth = 3;
// Wide (interior) width of the dovetail trapezoid (mm). Must be > dovetail_narrow.
dovetail_wide = 5;
// Narrow (opening) width of the dovetail trapezoid (mm). Typically ~= divider_width.
dovetail_narrow = 3;
// Print clearance between tab and slot (mm). Larger = looser fit.
dovetail_tolerance = 0.2;
// Pillar protrusion into the cup cavity in X (mm). Must be > dovetail_depth.
dovetail_pillar_thickness = 4.5;
// Pillar width along Y (mm). A couple mm wider than dovetail_wide is recommended.
dovetail_pillar_width = 9;
// Stop block height at the bottom of each slot (mm). 0 = slot runs all the way through. Recommended 0, especially with tilt; the divider's body acts as a natural stop against the cup floor.
dovetail_stop_height = 0;
// Gap left between separately-rendered dividers when render_mode = "dividers" (mm)
divider_layout_gap = 3;

/* [Wall Pattern] */
// Grid wall patter
wallpattern_enabled=false;
// Style of the pattern
wallpattern_style = "hexgrid"; //[hexgrid, grid, voronoi, voronoigrid, voronoihexgrid, brick, brickoffset]
// Spacing between pattern
wallpattern_strength = 2; //0.1
// wall to enable on, front, back, left, right.
wallpattern_walls=[1,1,1,1];  //[0:1:1]
// rotate the grid
wallpattern_rotate_grid=false;
//Size of the hole
wallpattern_cell_size = [10,10]; //0.1
// Add the pattern to the dividers
wallpattern_dividers_enabled="disabled"; //[disabled, horizontal, vertical, both]
//Number of sides of the hole op
wallpattern_hole_sides = 6; //[4:square, 6:hex, 8:octo, 64:circle]
//Radius of corners
wallpattern_hole_radius = 0.5;
// pattern fill mode
wallpattern_fill = "none"; //[none, space, crop, crophorizontal, cropvertical, crophorizontal_spacevertical, cropvertical_spacehorizontal, spacevertical, spacehorizontal]
// border around the wall pattern, default is wall thickness
wallpattern_border = 0;
// depth of imprint in mm, 0 = is wall width.
wallpattern_depth = 0; // 0.1
//grid pattern hole taper
wallpattern_pattern_grid_chamfer = 0; //0.1
//voronoi pattern noise,
wallpattern_pattern_voronoi_noise = 0.75; //0.01
//brick pattern center weight
wallpattern_pattern_brick_weight = 5;
//$fs for floor pattern, min size face.
wallpattern_pattern_quality = 0.4;//0.1:0.1:2

/* [General Cup] */
// X dimension. grid units (multiples of 42mm) or mm.
width = [3, 0]; //0.5
// Y dimension. grid units (multiples of 42mm) or mm.
depth = [2, 0]; //0.5
// Z dimension excluding. grid units (multiples of 7mm) or mm.
height = [1, 0]; //0.1
// Fill in solid block (overrides all following options)
filled_in = false;
// Wall thickness of outer walls. default, height < 8 0.95, height < 16 1.2, height > 16 1.6 (Zack's design is 0.95 mm)
wall_thickness = 0;  // .01
position = "center"; //[default,center,zero]

/* [Cup Lip] */
// Style of the cup lip
lip_style = "normal";  // [ normal, reduced, minimum, none:not stackable ]
// Below this the inside of the lip will be reduced for easier access.
lip_side_relief_trigger = [1,1]; //0.1
// Create a relie
lip_top_relief_height = -1; // 0.1
// add a notch to the lip to prevent sliding.
lip_top_notches  = false;

/* [Base] */
//size of magnet, diameter and height. Zack's original used 6.5 and 2.4
magnet_size = [6.5, 2.4];  // .1
//create relief for magnet removal
magnet_easy_release = "auto";//["off","auto","inner","outer"]
//size of screw, diameter and height. Zack's original used 3 and 6
screw_size = [3, 6]; // .1
//size of center magnet, diameter and height.
center_magnet_size = [0,0];
// Sequential Bridging hole overhang remedy is active only when both screws and magnets are nonzero (and this option is selected)
hole_overhang_remedy = 2;
//Only add attachments (magnets and screw) to box corners (prints faster).
box_corner_attachments_only = "enabled"; //["disabled","enabled","aligned"]
// Minimum thickness above cutouts in base (Zack's design is effectively 1.2)
floor_thickness = 0.7;
cavity_floor_radius = -1;// .1
// Efficient floor option saves material and time, but the internal floor is not flat
efficient_floor = "off";//[off,on,rounded,smooth]
// AKA half pitch. Enable to subdivide bottom pads to allow sub-cell offsets
sub_pitch = 1; //[1:"disabled",2:"half pitch",3:"third pitch",4:"quarter pitch"]
// Removes the internal grid from base the shape
flat_base = "off";

/* [debug] */
//Slice along the x axis
cutx = 0; //0.1
//Slice along the y axis
cuty = 0; //0.1
// enable loging of help messages during render.
enable_help = "disabled"; //[info,debug,trace]

/* [Model detail] */
//assign colours to the bin, will may
set_colour = "enable"; //[disabled, enable, preview, lip]
//where to render the model
render_position = "center"; //[default,center,zero]
// minimum angle for a fragment (fragments = 360/fa).  Low is more fragments
fa = 6;
// minimum size of a fragment.  Low is more fragments
fs = 0.1;
// number of fragments, overrides $fa and $fs
fn = 0;
// set random seed for
random_seed = 0; //0.0001

/* [Hidden] */
module end_of_customizer_opts() {}

//Some online generators do not like direct setting of fa,fs,fn
$fa = fa;
$fs = fs;
$fn = fn;

set_environment(
  width = width,
  depth = depth,
  height = height,
  render_position = render_position,
  help = enable_help,
  cut = [cutx, cuty, height])
Gridfinity_Divider_Dovetail();

module Divider(
  height = 50,
  length = 100,
  baseHeight = 10,
  radius = 5,
  frontTopInset=20,
  frontTopAngle=65,
  backTopInset=20,
  backTopAngle=65
){
  _baseHeight = radius > baseHeight ? radius : baseHeight;

  _backBottomHeight = max(_baseHeight,height-radius-abs(backTopInset*tan(backTopAngle)));
  _frontBottomHeight = max(_baseHeight,height-radius-abs(frontTopInset*tan(frontTopAngle)));
  if(env_help_enabled("debug")) echo("Gridfinity_Divider", height,radius, abs(backTopInset*tan(backTopAngle)),_backBottomHeight);
  if(env_help_enabled("debug")) echo("Gridfinity_Divider", _baseHeight=_baseHeight, height=height, _backBottomHeight=_backBottomHeight, _frontBottomHeight=_frontBottomHeight);

  positions = [
    [radius,_frontBottomHeight],      //front bottom
    [radius+frontTopInset,height-radius],        //front top
    [length-radius-backTopInset,height-radius],  //back top
    [length-radius,_backBottomHeight] //back bottom
  ];

  //
  hull(){
    square([length,_baseHeight]);
    for(index =[0:1:len(positions)-1])
    {
      translate(positions[index])
        circle(r=radius);
    }
  }
}

module PatternedDivider(
  height = 50,
  length = 100,
  baseHeight = 10,
  width = 5,
  radius = 5,
  frontTopInset=20,
  frontTopAngle=65,
  backTopInset=20,
  backTopAngle=65,
  wallpatternEnabled = wallpattern_enabled,
  wallpatternBorder = wallpattern_border) {

  rotate([90,0,0])
  difference(){
  linear_extrude(height = width)
  Divider(
    height = height,
    length = length,
    baseHeight = baseHeight,
    radius = radius,
    frontTopInset=frontTopInset,
    frontTopAngle=frontTopAngle,
    backTopInset=backTopInset,
    backTopAngle=backTopAngle);

  if(wallpatternEnabled){
  translate([0,0,-fudgeFactor])
  intersection(){
    linear_extrude(height = width+fudgeFactor*2)
    offset(delta = -wallpatternBorder)
    Divider(
      height = height,
      length = length,
      baseHeight = baseHeight,
      radius = radius,
      frontTopInset=frontTopInset,
      frontTopAngle=frontTopAngle,
      backTopInset=backTopInset,
      backTopAngle=backTopAngle);

      children();
      }
    }
  }
}

module Gridfinity_Divider_Dovetail(
  renderMode = render_mode,
  width=width, depth=depth, height=height,
  position=position,
  filled_in=filled_in,
  cupBase_settings = CupBaseSettings(
    magnetSize = magnet_size,
    magnetEasyRelease = magnet_easy_release,
    centerMagnetSize = center_magnet_size,
    screwSize = screw_size,
    holeOverhangRemedy = hole_overhang_remedy,
    cornerAttachmentsOnly = box_corner_attachments_only,
    floorThickness = floor_thickness,
    cavityFloorRadius = cavity_floor_radius,
    efficientFloor=efficient_floor,
    subPitch=sub_pitch,
    flatBase=flat_base),
  wall_thickness=wall_thickness,
  lip_settings = LipSettings(
    lipStyle=lip_style,
    lipSideReliefTrigger=lip_side_relief_trigger,
    lipTopReliefHeight=lip_top_relief_height,
    lipNotch=lip_top_notches),
  dividerCount=divider_count,
  dividerHeight=divider_height,
  baseHeight=divider_base_height,
  dividerWidth=divider_width,
  radius=divider_radius,
  frontTopInset=divider_front_top_inset,
  frontTopAngle=divider_front_top_angle,
  backTopInset=divider_back_top_inset,
  backTopAngle=divider_back_top_angle,
  dividerAngle=divider_angle,
  dtDepth=dovetail_depth,
  dtNarrow=dovetail_narrow,
  dtWide=dovetail_wide,
  dtTolerance=dovetail_tolerance,
  pillarThickness=dovetail_pillar_thickness,
  pillarWidth=dovetail_pillar_width,
  stopHeight=dovetail_stop_height,
  layoutGap=divider_layout_gap,
  wallpatternEnabled=wallpattern_enabled,
  pattern_settings = PatternSettings(
    patternEnabled = wallpattern_enabled,
    patternStyle = wallpattern_style,
    patternRotate = wallpattern_rotate_grid,
    patternFill = wallpattern_fill,
    patternBorder = wallpattern_border,
    patternDepth = wallpattern_depth,
    patternCellSize = wallpattern_cell_size,
    patternHoleSides = wallpattern_hole_sides,
    patternStrength = wallpattern_strength,
    patternHoleRadius = wallpattern_hole_radius,
    patternGridChamfer = wallpattern_pattern_grid_chamfer,
    patternVoronoiNoise = wallpattern_pattern_voronoi_noise,
    patternBrickWeight = wallpattern_pattern_brick_weight,
    patternFs = wallpattern_pattern_quality)
    ) {

  num_x = calcDimensionWidth(width);
  num_y = calcDimensionDepth(depth);
  num_z = calcDimensionHeight(height);
  floorHeight = calculateFloorHeight(magnet_depth=magnet_size[1], screw_depth=screw_size[1], floor_thickness=floor_thickness,num_z=num_z, efficient_floor=cupBase_settings[iCupBase_EfficientFloor], flat_base=flat_base);

  // Cup cavity geometry (matches the placement math used by Gridfinity_Divider).
  cavityWidth = num_x*env_pitch().x - env_clearance().x;     // X span between inner walls
  cavityLeftX  = env_clearance().x/2;                        // X of inner left wall
  cavityRightX = num_x*env_pitch().x - env_clearance().x/2;  // X of inner right wall

  // The dovetail tab rides on the divider's rectangular base region.
  effBaseHeight = max(radius, baseHeight);
  pillarHeight  = effBaseHeight;
  tabHeight     = effBaseHeight - stopHeight;

  // Divider body length = cavity span minus the two pillar protrusions.
  // (The tabs themselves are extra and slide into the slots beyond the body.)
  dividerBodyLength = cavityWidth - 2*pillarThickness;

  // Y position (centerline) of each divider's pillar pair.
  //
  // Each pillar is a block centered on the divider's Y centerline, ± pillarWidth/2
  // at its base. When dividerAngle != 0 the pillar top tips in Y; for the convention
  // used here (rotate([angle,0,0])) positive angle tips +Z toward -Y. We add extra
  // clearance on whichever side the dividers lean toward so the tilted pillar top
  // doesn't push past the cup's rounded inner corner radius.
  tiltYTopOffset = pillarHeight * sin(dividerAngle);
  frontExtra     = max(0,  tiltYTopOffset);   // top tilts toward -Y => more front clearance
  backExtra      = max(0, -tiltYTopOffset);   // top tilts toward +Y => more back clearance
  frontClearance = env_corner_radius() + pillarWidth/2 + frontExtra;
  backClearance  = env_corner_radius() + pillarWidth/2 + backExtra;
  ySpan          = num_y*env_pitch().y - frontClearance - backClearance;
  function dividerYCenter(i) =
    frontClearance + (dividerCount <= 1 ? ySpan/2 : ySpan/(dividerCount-1) * i);

  // Used to clip anything that would dip below the cup floor when tilted.
  bigClip = max(num_x, num_y) * env_pitch().x * 3;

  // ============ CUP + PILLARS ============
  if(renderMode == "all" || renderMode == "cup"){
    // Assemble the cup body + pillar solids first, then subtract the slot cuts
    // globally. Cutting the slot against the cup+pillar assembly means the cup's
    // stacking lip (which intrudes into the cavity near the top of the wall,
    // especially around the corner radius) is also notched out of the slot path.
    // Without that, the lip blocks the dovetail tab from fully sliding in.
    difference(){
      union(){
        // Cup body
        gridfinity_cup(
          width=width, depth=depth, height=height,
          cupBase_settings=cupBase_settings,
          wall_thickness=wall_thickness,
          lip_settings=lip_settings,
          label_settings=LabelSettings(labelStyle="disabled"));

        // Pillar SOLIDS (without slot cuts). Each pillar is tilted around its
        // base; the floor-clip intersection() keeps it from poking below z=0.
        color(env_colour(color_divider))
        for(i = [0 : dividerCount-1]){
          yCenter = dividerYCenter(i);

          // Left pillar (slot will open toward +X)
          translate([cavityLeftX, yCenter, floorHeight])
            intersection(){
              rotate([dividerAngle, 0, 0])
                dovetail_pillar_body(
                  pillar_x = pillarThickness,
                  pillar_y = pillarWidth,
                  pillar_z = pillarHeight,
                  mirrored = false);
              translate([-bigClip, -bigClip, 0])
                cube([2*bigClip, 2*bigClip, 2*bigClip]);
            }

          // Right pillar (slot will open toward -X)
          translate([cavityRightX, yCenter, floorHeight])
            intersection(){
              rotate([dividerAngle, 0, 0])
                dovetail_pillar_body(
                  pillar_x = pillarThickness,
                  pillar_y = pillarWidth,
                  pillar_z = pillarHeight,
                  mirrored = true);
              translate([-bigClip, -bigClip, 0])
                cube([2*bigClip, 2*bigClip, 2*bigClip]);
            }
        }
      }

      // GLOBAL slot cuts punched through cup + pillars together so the lip /
      // wall / pillar all get the same dovetail notch along the tilted slide
      // path. Each cut is also floor-clipped so we never punch the cup floor.
      for(i = [0 : dividerCount-1]){
        yCenter = dividerYCenter(i);

        translate([cavityLeftX, yCenter, floorHeight])
          intersection(){
            rotate([dividerAngle, 0, 0])
              dovetail_pillar_slot(
                pillar_x = pillarThickness,
                pillar_z = pillarHeight,
                depth    = dtDepth,
                narrow   = dtNarrow,
                wide     = dtWide,
                tolerance = dtTolerance,
                stop_height = stopHeight,
                slot_extend_top = gf_Lip_Height + 2,
                mirrored = false);
            translate([-bigClip, -bigClip, 0])
              cube([2*bigClip, 2*bigClip, 2*bigClip]);
          }

        translate([cavityRightX, yCenter, floorHeight])
          intersection(){
            rotate([dividerAngle, 0, 0])
              dovetail_pillar_slot(
                pillar_x = pillarThickness,
                pillar_z = pillarHeight,
                depth    = dtDepth,
                narrow   = dtNarrow,
                wide     = dtWide,
                tolerance = dtTolerance,
                stop_height = stopHeight,
                slot_extend_top = gf_Lip_Height + 2,
                mirrored = true);
            translate([-bigClip, -bigClip, 0])
              cube([2*bigClip, 2*bigClip, 2*bigClip]);
          }
      }
    }
  }

  // ============ DIVIDERS ============
  if(renderMode == "all"){
    // Show them installed (tilted to match the slots).
    color(env_colour(color_divider))
    for(i = [0 : dividerCount-1]){
      yCenter = dividerYCenter(i);
      // Divider body is centered on yCenter; it extends ± dividerWidth/2 in Y.
      // The dovetail_divider_piece is built in installed orientation, so we
      // anchor at (cavityLeftX + pillarThickness, yCenter, floorHeight) and
      // apply the same tilt + floor-clip used for the pillars.
      translate([cavityLeftX + pillarThickness, yCenter, floorHeight])
      intersection(){
        rotate([dividerAngle, 0, 0])
          dovetail_divider_piece_installed(
            dividerlength_body = dividerBodyLength,
            dividerheight = dividerHeight,
            dividerwidth  = dividerWidth,
            baseHeight    = baseHeight,
            radius        = radius,
            frontTopInset = frontTopInset,
            frontTopAngle = frontTopAngle,
            backTopInset  = backTopInset,
            backTopAngle  = backTopAngle,
            tab_depth  = dtDepth,
            tab_narrow = dtNarrow,
            tab_wide   = dtWide,
            tab_height = tabHeight,
            stop_height = stopHeight,
            wallpatternEnabled = wallpatternEnabled,
            pattern_settings = pattern_settings);
        translate([-bigClip, -bigClip, 0])
          cube([2*bigClip, 2*bigClip, 2*bigClip]);
      }
    }
  } else if(renderMode == "dividers"){
    // Lay them out flat on the build plate, spaced along Y.
    color(env_colour(color_divider))
    for(i = [0 : dividerCount-1]){
      translate([0, i * (dividerHeight + baseHeight + layoutGap), 0])
        rotate([-90,0,0])
        dovetail_divider_piece_installed(
          dividerlength_body = dividerBodyLength,
          dividerheight = dividerHeight,
          dividerwidth  = dividerWidth,
          baseHeight    = baseHeight,
          radius        = radius,
          frontTopInset = frontTopInset,
          frontTopAngle = frontTopAngle,
          backTopInset  = backTopInset,
          backTopAngle  = backTopAngle,
          tab_depth  = dtDepth,
          tab_narrow = dtNarrow,
          tab_wide   = dtWide,
          tab_height = tabHeight,
          stop_height = stopHeight,
          wallpatternEnabled = wallpatternEnabled,
          pattern_settings = pattern_settings);
    }
  } else if(renderMode == "single_divider"){
    color(env_colour(color_divider))
    rotate([-90,0,0])
    dovetail_divider_piece_installed(
      dividerlength_body = dividerBodyLength,
      dividerheight = dividerHeight,
      dividerwidth  = dividerWidth,
      baseHeight    = baseHeight,
      radius        = radius,
      frontTopInset = frontTopInset,
      frontTopAngle = frontTopAngle,
      backTopInset  = backTopInset,
      backTopAngle  = backTopAngle,
      tab_depth  = dtDepth,
      tab_narrow = dtNarrow,
      tab_wide   = dtWide,
      tab_height = tabHeight,
      stop_height = stopHeight,
      wallpatternEnabled = wallpatternEnabled,
      pattern_settings = pattern_settings);
  }
}

// =========================================================================
// Dovetail geometry helpers
// =========================================================================

// 2D dovetail profile (trapezoid) in the XY plane.
// Origin = center of opening; opening faces +X.
//   x =  0     (opening, narrow face): width in Y = narrow
//   x = -depth (deep end, wide face):  width in Y = wide
module dovetail_profile_2d(depth, narrow, wide) {
  half_n = narrow/2;
  half_w = wide/2;
  polygon(points = [
    [ 0,       -half_n ],
    [ 0,        half_n ],
    [-depth,    half_w ],
    [-depth,   -half_w ],
  ]);
}

// Solid pillar block (no slot cut). Anchored at the inner wall face so it
// extends +X into the cavity by pillar_x, ± pillar_y/2 in Y, and 0..pillar_z in Z.
// `mirrored = true` flips it across X so it can be attached to the right wall.
module dovetail_pillar_body(pillar_x, pillar_y, pillar_z, mirrored=false){
  mirror(mirrored ? [1,0,0] : [0,0,0])
    translate([0, -pillar_y/2, 0])
      cube([pillar_x, pillar_y, pillar_z]);
}

// Slot-cut volume only. Extruded tall enough (slot_extend_top) to punch
// through any cup material above the pillar (e.g. the stacking lip) when
// subtracted globally from the cup+pillars assembly.
module dovetail_pillar_slot(
  pillar_x,
  pillar_z,
  depth,
  narrow,
  wide,
  tolerance,
  stop_height,
  slot_extend_top = 10,
  mirrored = false
){
  slot_depth  = depth   + tolerance;
  slot_narrow = narrow  + 2*tolerance;
  slot_wide   = wide    + 2*tolerance;
  mirror(mirrored ? [1,0,0] : [0,0,0])
    translate([pillar_x, 0, stop_height - fudgeFactor])
      linear_extrude(height = pillar_z - stop_height + fudgeFactor + slot_extend_top)
      dovetail_profile_2d(slot_depth, slot_narrow, slot_wide);
}

// One divider piece in INSTALLED orientation (i.e. standing up):
//   X = divider length (left-right, between the two pillars)
//   Z = divider installed-height (vertical)
//   Y = divider thickness, centered around y=0 (-dividerwidth/2 .. +dividerwidth/2)
// Tabs extend in -X (left end) and +X (right end) from the divider body.
// Caller can wrap with rotate([-90,0,0]) to lay the piece flat on the build plate.
module dovetail_divider_piece_installed(
  dividerlength_body,
  dividerheight,
  dividerwidth,
  baseHeight,
  radius,
  frontTopInset,
  frontTopAngle,
  backTopInset,
  backTopAngle,
  tab_depth,
  tab_narrow,
  tab_wide,
  tab_height,
  stop_height,
  wallpatternEnabled,
  pattern_settings
){
  union(){
    // Divider body (with optional wall pattern). The 2D Divider profile has
    // X=length, Y=installed-height. We extrude it in Z to get the thickness,
    // then rotate it up into the XZ plane and translate so the thickness is
    // centered on Y=0.
    translate([0, dividerwidth/2, 0])
    rotate([90,0,0])
    difference(){
      linear_extrude(height = dividerwidth)
        Divider(
          height = dividerheight,
          length = dividerlength_body,
          baseHeight = baseHeight,
          radius = radius,
          frontTopInset = frontTopInset,
          frontTopAngle = frontTopAngle,
          backTopInset  = backTopInset,
          backTopAngle  = backTopAngle);

      if(wallpatternEnabled){
        canvis_y = max(dividerheight, baseHeight);
        translate([0, 0, -fudgeFactor])
        intersection(){
          linear_extrude(height = dividerwidth + fudgeFactor*2)
            offset(delta = -dividerwidth)
            Divider(
              height = dividerheight,
              length = dividerlength_body,
              baseHeight = baseHeight,
              radius = radius,
              frontTopInset = frontTopInset,
              frontTopAngle = frontTopAngle,
              backTopInset  = backTopInset,
              backTopAngle  = backTopAngle);

          translate([dividerlength_body/2, canvis_y/2])
          cutout_pattern(
            patternStyle = pattern_settings[iPatternStyle],
            canvasSize = [dividerlength_body, canvis_y],
            border = (pattern_settings[iPatternBorder] == 0 ? dividerwidth : pattern_settings[iPatternBorder])*2,
            customShape = false,
            circleFn = pattern_settings[iPatternHoleSides],
            cellSize = pattern_settings[iPatternCellSize],
            strength = pattern_settings[iPatternStrength],
            holeHeight = dividerwidth*2,
            center = true,
            fill = pattern_settings[iPatternFill],
            patternGridChamfer = pattern_settings[iPatternGridChamfer],
            patternVoronoiNoise = pattern_settings[iPatternVoronoiNoise],
            patternBrickWeight = pattern_settings[iPatternBrickWeight],
            partialDepth = pattern_settings[iPatternDepth] != 0,
            holeRadius = pattern_settings[iPatternHoleRadius],
            source = "Gridfinity Divider Dovetail",
            rotateGrid = pattern_settings[iPatternRotate],
            patternFs = pattern_settings[iPatternFs]);
        }
      }
    }

    // Left-end tab: extends in -X (narrow face at x=0, wide face at x=-tab_depth).
    translate([0, 0, stop_height])
      linear_extrude(height = tab_height)
      dovetail_profile_2d(tab_depth, tab_narrow, tab_wide);

    // Right-end tab: extends in +X (mirror of left tab).
    translate([dividerlength_body, 0, stop_height])
      linear_extrude(height = tab_height)
      mirror([1,0,0])
      dovetail_profile_2d(tab_depth, tab_narrow, tab_wide);
  }
}