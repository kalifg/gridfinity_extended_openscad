include <modules/gridfinity_constants.scad>
include <modules/functions_general.scad>
include <modules/module_gridfinity_cup_base.scad>
use <modules/module_gridfinity_block.scad>
include <modules/module_patterns.scad>

/* [Shelves] */
// Number of horizontal shelves
shelf_count = 6;
// Vertical gap between shelves (top surface of one shelf to bottom surface of the next, in mm)
shelf_spacing = 15;
// Thickness of each shelf (Z, mm)
shelf_thickness = 2;
// How far each shelf extends forward (−Y) from the back support, in mm. Use -1 to extend to the front edge of the gridfinity footprint.
shelf_depth = -1;
// Rounded corner radius of the shelf's free (front + side) edges, in mm.
shelf_front_radius = 3;
// How much narrower (mm, per side) the front edge of each shelf is compared to the back edge.
// 0 = parallel sides (rectangle). Positive values produce a trapezoidal plan view that tapers toward the front.
shelf_front_inset = 30;
// Angle (deg) at which each shelf tilts up from the back support wall.
// 0 = horizontal. Positive = front edge lifts above the back edge (rear-rake, items held against the back wall).
// The shelf pivots around the bottom-back edge where it meets the back support.
shelf_front_angle = 15;
// Amount (mm) to lower every shelf below its computed Z position. Useful when shelves are tilted:
// the front edge rises by depth * sin(angle), so dropping the stack lets the lifted front edges sit
// closer to the base. All shelves shift together so the spacing between them stays equal.
shelves_drop = 10;

/* [Back Support] */
// Thickness of the back support wall (Y, mm)
back_wall_thickness = 4;
// Extra height of the back support above the top of the topmost shelf, in mm. The wall always extends down to the top of the base.
back_wall_overhang = 2;

/* [Print Pieces] */
// Which piece to render.
//   all   - the whole assembled model as a single solid (no slots, no tabs visible)
//   base  - just the gridfinity base + back support, with slots cut for shelf tabs (printable)
//   shelf - a single shelf laid flat for printing (back tab extends past the shelf body)
// All shelves are identical, so the "shelf" piece is printed `shelf_count` times.
part = "all"; // [all, base, shelf]
// Clearance (mm) added around each tab when cutting the matching slot in the back wall.
// Larger values = looser fit. Typical FDM tolerance is 0.15 - 0.3 mm.
slot_tolerance = 0.2;

/* [Wall Pattern (cut through shelves)] */
// Cut a pattern of holes through each shelf
wallpattern_enabled=true;
// Style of the pattern
wallpattern_style = "hexgrid"; //[hexgrid, grid, voronoi, voronoigrid, voronoihexgrid, brick, brickoffset]
// Spacing between pattern
wallpattern_strength = 2; //0.1
// rotate the grid
wallpattern_rotate_grid=false;
//Size of the hole
wallpattern_cell_size = [10,10]; //0.1
//Number of sides of the hole
wallpattern_hole_sides = 6; //[4:square, 6:hex, 8:octo, 64:circle]
//Radius of corners
wallpattern_hole_radius = 0.5;
// pattern fill mode
wallpattern_fill = "none"; //[none, space, crop, crophorizontal, cropvertical, crophorizontal_spacevertical, cropvertical_spacehorizontal, spacevertical, spacehorizontal]
// border around the pattern on each shelf (mm). 0 = shelf_front_radius
wallpattern_border = 0;
// depth of imprint (0 = full through shelf)
wallpattern_depth = 0; // 0.1
//grid pattern hole taper
wallpattern_pattern_grid_chamfer = 0; //0.1
//voronoi pattern noise
wallpattern_pattern_voronoi_noise = 0.75; //0.01
//brick pattern center weight
wallpattern_pattern_brick_weight = 5;
//$fs for floor pattern
wallpattern_pattern_quality = 0.4;//0.1:0.1:2

/* [General] */
// X dimension. grid units (multiples of 42mm) or mm.
width = [3, 0]; //0.5
// Y dimension. grid units (multiples of 42mm) or mm.
depth = [2, 0]; //0.5
position = "center"; //[default,center,zero]

/* [Base] */
// Number of grid units (Z, 7mm each) that the gridfinity base occupies. The base is fully solid.
base_height_units = 1;
//size of magnet, diameter and height. Zack's original used 6.5 and 2.4
magnet_size = [6.5, 2.4];  // .1
//create relief for magnet removal
magnet_easy_release = "auto";//["off","auto","inner","outer"]
//size of screw, diameter and height. Zack's original used 3 and 6
screw_size = [3, 6]; // .1
//size of center magnet, diameter and height.
center_magnet_size = [0,0];
// Sequential Bridging hole overhang remedy
hole_overhang_remedy = 2;
//Only add attachments (magnets and screw) to box corners (prints faster).
box_corner_attachments_only = "enabled"; //["disabled","enabled","aligned"]
// AKA half pitch. Enable to subdivide bottom pads
sub_pitch = 1; //[1:"disabled",2:"half pitch",3:"third pitch",4:"quarter pitch"]
// Removes the internal grid from base
flat_base = "off";

/* [debug] */
//Slice along the x axis
cutx = 0; //0.1
//Slice along the y axis
cuty = 0; //0.1
// enable logging of help messages during render.
enable_help = "disabled"; //[info,debug,trace]

/* [Model detail] */
//assign colours to the bin
set_colour = "enable"; //[disabled, enable, preview, lip]
//where to render the model
render_position = "center"; //[default,center,zero]
fa = 6;
fs = 0.1;
fn = 0;
random_seed = 0; //0.0001

/* [Hidden] */
module end_of_customizer_opts() {}

$fa = fa;
$fs = fs;
$fn = fn;

// Total Z height: enough to contain the base + first_offset + all shelves + spacing + back wall overhang.
// We don't rely on a user "height" param; the model defines its own bounding height.
set_environment(
  width = width,
  depth = depth,
  height = [base_height_units, 0],     // only the base portion uses the gridfinity Z grid
  render_position = render_position,
  help = enable_help,
  cut = [cutx, cuty, [base_height_units, 0]])
Gridfinity_HorizontalShelves();

// 2D rounded rectangle with optional separate corner radii
module RoundedRect2D(size, radius){
  _r = min(radius, min(size.x, size.y)/2);
  if(_r <= 0){
    square(size);
  } else {
    hull(){
      for(x = [_r, size.x - _r])
        for(y = [_r, size.y - _r])
          translate([x, y]) circle(r = _r);
    }
  }
}

// 2D shape used as the shelf footprint in plan view (X = width, Y = depth, +Y is back).
// The back edge (Y = size.y) is square and full-width so it meets the back wall flush.
// `frontInset` narrows each side at the front, producing a trapezoidal shape with straight
// sides running from the back corners to the (rounded) front corners.
module ShelfFootprint2D(size, frontRadius, frontInset = 0){
  _inset = max(0, min(frontInset, size.x/2 - fudgeFactor));
  _r = min(frontRadius, min(size.x - 2*_inset, size.y)/2);

  hull(){
    // Back-edge thin strip (full width)
    translate([0, size.y - fudgeFactor]) square([size.x, fudgeFactor]);

    // Front corners (rounded or square)
    if(_r > 0){
      translate([_inset + _r, _r]) circle(r=_r);
      translate([size.x - _inset - _r, _r]) circle(r=_r);
    } else {
      translate([_inset, 0]) square([fudgeFactor, fudgeFactor]);
      translate([size.x - _inset - fudgeFactor, 0]) square([fudgeFactor, fudgeFactor]);
    }
  }
}

// 2D shape for the back support: square on the front edge, rounded on the back two corners
module BackWallFootprint2D(size, backRadius){
  _r = min(backRadius, min(size.x, size.y)/2);
  hull(){
    // Square front edge (y = 0)
    translate([0, 0]) square([size.x, fudgeFactor]);
    // Rounded back corners
    if(_r > 0){
      translate([_r, size.y - _r]) circle(r=_r);
      translate([size.x - _r, size.y - _r]) circle(r=_r);
    } else {
      translate([0, size.y - fudgeFactor]) square([size.x, fudgeFactor]);
    }
  }
}

module Gridfinity_HorizontalShelves(
  width=width, depth=depth,
  position=position,
  cupBase_settings = CupBaseSettings(
    magnetSize = magnet_size,
    magnetEasyRelease = magnet_easy_release,
    centerMagnetSize = center_magnet_size,
    screwSize = screw_size,
    holeOverhangRemedy = hole_overhang_remedy,
    cornerAttachmentsOnly = box_corner_attachments_only,
    subPitch=sub_pitch,
    flatBase=flat_base),
  shelfCount = shelf_count,
  shelfSpacing = shelf_spacing,
  shelfThickness = shelf_thickness,
  shelfDepth = shelf_depth,
  shelfFrontRadius = shelf_front_radius,
  shelfFrontInset = shelf_front_inset,
  shelfFrontAngle = shelf_front_angle,
  shelvesDrop = shelves_drop,
  backWallThickness = back_wall_thickness,
  backWallOverhang = back_wall_overhang,
  baseHeightUnits = base_height_units,
  partToRender = part,
  slotTolerance = slot_tolerance,
  wallpatternEnabled = wallpattern_enabled,
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
){
  assert(shelfCount >= 1, "shelf_count must be >= 1");
  assert(shelfSpacing >= 0, "shelf_spacing must be >= 0");
  assert(shelfThickness > 0, "shelf_thickness must be > 0");
  assert(backWallThickness > 0, "back_wall_thickness must be > 0");

  num_x = calcDimensionWidth(width);
  num_y = calcDimensionDepth(depth);

  // Outer footprint of the gridfinity unit (minus clearance) in plan
  outerSize = [
    num_x*env_pitch().x - env_clearance().x,
    num_y*env_pitch().y - env_clearance().y
  ];
  outerOrigin = [env_clearance().x/2, env_clearance().y/2];
  outerRadius = env_corner_radius();

  topOfBase = baseHeightUnits * env_pitch().z;

  // Compute shelf Z positions (Z of the bottom face of each shelf).
  // The top of the gridfinity base is treated as the "zeroth shelf surface",
  // so the bottom of shelf i sits (i+1) * shelfSpacing above the base
  // plus the thickness of all shelves below it. The entire stack can be
  // optionally lowered by `shelvesDrop` (helpful when shelves are tilted
  // so the lifted front edges do not sit too high above the base). All
  // shelves shift together, so inter-shelf spacing remains equal.
  shelfBottoms = [
    for(i = [0 : shelfCount-1])
      topOfBase + (i+1) * shelfSpacing + i * shelfThickness - shelvesDrop
  ];
  topShelfTop = shelfBottoms[shelfCount-1] + shelfThickness;
  totalHeight = topShelfTop + backWallOverhang;

  assert(shelfBottoms[0] >= topOfBase,
    "shelves_drop is larger than shelf_spacing; the bottom shelf would dip into the gridfinity base.");

  // Back support: spans full X across the back of the footprint.
  // It occupies the +Y back portion with thickness `backWallThickness`.
  backWallY0 = outerOrigin.y + outerSize.y - backWallThickness;
  backWallY1 = outerOrigin.y + outerSize.y;

  // Shelf Y extent: from the front face of the back wall forward
  _shelfDepth = shelfDepth < 0
    ? (backWallY0 - outerOrigin.y)            // extend forward to the front of the footprint
    : min(shelfDepth, backWallY0 - outerOrigin.y);
  shelfY0 = backWallY0 - _shelfDepth;
  // Each shelf extends all the way through the back wall (Y up to backWallY1) so that,
  // when tilted, its back edge stays embedded inside the back wall instead of gapping out.
  // We then clip with an intersection at Y = backWallY1 so it never pokes out the back.
  shelfY1 = backWallY1;

  if(env_help_enabled("debug"))
    echo("Gridfinity_HorizontalShelves",
      outerSize=outerSize, outerOrigin=outerOrigin,
      topOfBase=topOfBase, totalHeight=totalHeight,
      shelfBottoms=shelfBottoms,
      backWallY=[backWallY0, backWallY1],
      shelfY=[shelfY0, shelfY1],
      shelfDepth=_shelfDepth);

  // --- Shelf geometry shared by every "part" mode ---
  shelfPlanSize = [outerSize.x, shelfY1 - shelfY0];
  _border = wallpattern_border == 0 ? shelfFrontRadius : wallpattern_border;
  // Distance in Y from the shelf's local origin (front edge) to its pivot at the front face of the back wall
  pivotOffsetY = backWallY0 - shelfY0;

  // The shelf body in its own local frame (Y=0 is the front edge, Y=shelfPlanSize.y is the back of the tab).
  // `padding` inflates X and Z (used to build the slot cutter slightly larger than the tab).
  module unrotatedShelfBody(padding = 0){
    translate([-padding, 0, -padding])
    linear_extrude(height = shelfThickness + padding*2)
      ShelfFootprint2D(
        size = [shelfPlanSize.x + padding*2, shelfPlanSize.y],
        frontRadius = shelfFrontRadius,
        frontInset = shelfFrontInset);
  }

  // Pattern cutout for a shelf in its own local frame.
  module unrotatedShelfPatternCut(){
    translate([0, 0, -fudgeFactor])
    intersection(){
      linear_extrude(height = shelfThickness + fudgeFactor*2)
        offset(delta = -_border)
          ShelfFootprint2D(
            size = shelfPlanSize,
            frontRadius = shelfFrontRadius,
            frontInset = shelfFrontInset);

      translate([shelfPlanSize.x/2, shelfPlanSize.y/2])
      cutout_pattern(
        patternStyle = pattern_settings[iPatternStyle],
        canvasSize = shelfPlanSize,
        border = _border*2,
        customShape = false,
        circleFn = pattern_settings[iPatternHoleSides],
        cellSize = pattern_settings[iPatternCellSize],
        strength = pattern_settings[iPatternStrength],
        holeHeight = shelfThickness*2,
        center = true,
        fill = pattern_settings[iPatternFill],
        patternGridChamfer = pattern_settings[iPatternGridChamfer],
        patternVoronoiNoise = pattern_settings[iPatternVoronoiNoise],
        patternBrickWeight = pattern_settings[iPatternBrickWeight],
        partialDepth = pattern_settings[iPatternDepth] != 0,
        holeRadius = pattern_settings[iPatternHoleRadius],
        source = "Gridfinity Horizontal Shelves",
        rotateGrid = pattern_settings[iPatternRotate],
        patternFs = pattern_settings[iPatternFs]);
    }
  }

  // Position+tilt children to shelf `i`'s assembled location. Children should be authored in the
  // shelf's local frame (origin at front-left-bottom of the shelf body).
  module positionShelf(i){
    z = shelfBottoms[i];
    translate([outerOrigin.x, backWallY0, z])
    rotate([-shelfFrontAngle, 0, 0])
    translate([0, -pivotOffsetY, 0])
    children();
  }

  // Clip box for the assembled view: keeps each rotated shelf from poking through the back of the back wall.
  clipExtent = 1000;
  module shelfAssembledClip(){
    translate([outerOrigin.x - clipExtent, shelfY0 - clipExtent, -clipExtent])
      cube([outerSize.x + clipExtent*2,
            (backWallY1 - shelfY0) + clipExtent,
            clipExtent*3]);
  }

  // Clip box used when cutting slots: limits the slot volume to the back wall's Y range.
  module backWallSliceClip(){
    translate([outerOrigin.x - clipExtent, backWallY0, -clipExtent])
      cube([outerSize.x + clipExtent*2,
            backWallThickness,
            clipExtent*3]);
  }

  module gridfinityBase(){
    grid_block(
      num_x = num_x,
      num_y = num_y,
      num_z = baseHeightUnits,
      position = "zero",
      filledin = "enabled",
      wall_thickness = 1.2,
      cupBase_settings = cupBase_settings,
      lip_settings = LipSettings(lipStyle = "none"));
  }

  module backWallSolid(){
    // BackWallFootprint2D is laid out with its square front edge at local y=0 and rounded back at local y=size.y.
    color(env_colour(color_cup))
    translate([outerOrigin.x, backWallY0, topOfBase])
    linear_extrude(height = totalHeight - topOfBase)
      BackWallFootprint2D(
        size = [outerSize.x, backWallThickness],
        backRadius = outerRadius);
  }

  // The assembled shelf at index `i`, with its pattern cutouts and clipped at the back wall back face.
  module assembledShelf(i){
    color(env_colour(color_cup))
    intersection(){
      positionShelf(i)
        difference(){
          unrotatedShelfBody();
          if(wallpatternEnabled) unrotatedShelfPatternCut();
        }

      shelfAssembledClip();
    }
  }

  // Inflated rotated tab volume for shelf `i`, clipped to the back wall Y range, used as a slot cutter.
  module shelfSlotCutter(i){
    intersection(){
      positionShelf(i) unrotatedShelfBody(padding = slotTolerance);
      backWallSliceClip();
    }
  }

  // A single shelf laid flat (untilted, at z=0) for printing. Includes the tab so it slots into the slot.
  module printableShelf(){
    color(env_colour(color_cup))
    difference(){
      unrotatedShelfBody();
      if(wallpatternEnabled) unrotatedShelfPatternCut();
    }
  }

  // --- Dispatch on which part to render ---
  if(partToRender == "all"){
    gridfinityBase();
    backWallSolid();
    for(i = [0 : shelfCount-1]) assembledShelf(i);
  } else if(partToRender == "base"){
    gridfinityBase();
    difference(){
      backWallSolid();
      union(){
        for(i = [0 : shelfCount-1]) shelfSlotCutter(i);
      }
    }
  } else if(partToRender == "shelf"){
    printableShelf();
  } else {
    assert(false, str("Unknown part: '", partToRender, "'. Expected 'all', 'base', or 'shelf'."));
  }
}
