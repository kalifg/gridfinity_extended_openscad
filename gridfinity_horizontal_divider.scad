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
shelf_thickness = 3;
// How far each shelf extends forward (−Y) from the back support, in mm. Use -1 to extend to the front edge of the gridfinity footprint.
shelf_depth = -1;
// Rounded corner radius of the shelf's front corners, in mm.
shelf_front_radius = 3;
// Hexagonal plan view: length (mm) of the STRAIGHT side portion measured from the back edge.
// The shelf's sides run straight (full width) for this distance, then angle inward toward the front.
// Combined with `shelf_front_inset`, this produces a 6-sided plan (back, two straight sides, two
// angled sides, front). The straight portion provides solid material to support the row of back tabs.
// 0 = no straight portion (the sides start tapering immediately = trapezoidal).
shelf_back_straight = 15;
// How much narrower (per side, mm) the front edge is compared to the back. 0 = no taper.
shelf_front_inset = 25;
// Angle (deg) at which each shelf tilts up from the back support wall. 0 = horizontal.
shelf_front_angle = 15;
// Amount (mm) to lower the entire shelf stack. Useful when shelves are tilted so the lifted front
// edges sit closer to the base. All shelves shift together; inter-shelf spacing is preserved.
shelves_drop = 10;

/* [Back Support] */
// Thickness of the back support wall (Y, mm)
back_wall_thickness = 6;
// Extra height of the back support above the top of the topmost shelf, in mm.
back_wall_overhang = 2;

/* [Shelf Tabs] */
// Number of tabs distributed evenly across the back edge of each shelf. The back wall gets a
// matching slot at each tab's X position at every shelf height. So shelf_count x tab_count slots
// total, arranged in `tab_count` vertical "columns" on the back wall.
tab_count = 4;
// X width of each tab (mm). Must fit within (back-wall-width / tab_count).
tab_width = 10;
// Y depth of each tab into the back wall (mm). Must be < back_wall_thickness.
tab_depth = 5;
// Inward taper (mm per side) at the front of each tab's plan view. 0 = rectangular tab (default,
// easiest to print, no overhang in either the shelf or the slot). > 0 = dovetail tab in the XY
// plane that locks the shelf against being pulled forward; the tab/slot then has an XY overhang.
tab_dovetail = 0;

/* [Print Pieces] */
// Which piece to render.
//   all   - assembled preview: base + back wall (with all slots cut) + all tilted shelves seated
//   base  - printable main piece: base + back wall with all slots cut
//   shelf - one shelf, flat, with all tabs. Print this `shelf_count` times — all shelves are identical.
part = "all"; // [all, base, shelf]
// Clearance (mm) added around the tab when cutting the matching slot. Typical FDM 0.15 - 0.3 mm.
slot_tolerance = 0.2;
// Extra distance (mm) the slot extends out the front face of the wall, giving the tab a lead-in
// when sliding in. Visible as a small bevel at the front edge of each slot.
slot_lead_in = 0.5;

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

set_environment(
  width = width,
  depth = depth,
  height = [base_height_units, 0],
  render_position = render_position,
  help = enable_help,
  cut = [cutx, cuty, [base_height_units, 0]])
Gridfinity_HorizontalShelves();

// Hexagonal shelf footprint in plan view (X = width, Y = depth, +Y is back).
//   - Back edge: full width straight
//   - Two STRAIGHT side portions for `backStraight` mm forward from the back
//   - Two ANGLED sides going forward and inward by `frontInset` per side
//   - Front edge: full-width-minus-2*frontInset, with rounded corners
// Setting backStraight = 0 reduces to a plain trapezoid (the previous shape).
// Setting frontInset = 0 reduces to a rectangle (full width all around).
module ShelfFootprint2D(size, frontRadius, frontInset = 0, backStraight = 0){
  _inset    = max(0, min(frontInset, size.x/2 - fudgeFactor));
  _straight = max(0, min(backStraight, size.y - fudgeFactor));
  _r        = min(frontRadius, _inset > 0 ? _inset : size.x/2, size.y - _straight);
  hull(){
    // Back edge (full width)
    translate([0, size.y - fudgeFactor]) square([size.x, fudgeFactor]);

    // Where the side becomes straight back (only if we have a straight portion)
    if(_straight > 0){
      translate([0, size.y - _straight])
        square([fudgeFactor, fudgeFactor]);
      translate([size.x - fudgeFactor, size.y - _straight])
        square([fudgeFactor, fudgeFactor]);
    }

    // Front corners (rounded if frontRadius > 0)
    if(_r > 0){
      translate([_inset + _r, _r]) circle(r=_r);
      translate([size.x - _inset - _r, _r]) circle(r=_r);
    } else {
      translate([_inset, 0]) square([fudgeFactor, fudgeFactor]);
      translate([size.x - _inset - fudgeFactor, 0]) square([fudgeFactor, fudgeFactor]);
    }
  }
}

// 2D shelf back-tab profile in the XY plane (X = width direction, Y = depth into wall).
//   - Y=0 is the back edge of the shelf body (opening of the slot)
//   - Y=depth is the deep end of the slot
//   - Setting dovetail == 0 gives a plain rectangle (width = tabWidth)
//   - Setting dovetail > 0 narrows the front (opening) end by dovetail on each side,
//     producing a tab that's wider at the back than at the front (locks against -Y pull)
module ShelfTabProfile2D(tabWidth, depth, dovetail = 0){
  _dv = max(0, min(dovetail, tabWidth/2 - fudgeFactor));
  polygon(points = [
    [ -tabWidth/2 + _dv, 0],
    [  tabWidth/2 - _dv, 0],
    [  tabWidth/2,       depth],
    [ -tabWidth/2,       depth]
  ]);
}

// 2D back-wall footprint: square front edge, rounded back corners
module BackWallFootprint2D(size, backRadius){
  _r = min(backRadius, min(size.x, size.y)/2);
  hull(){
    translate([0, 0]) square([size.x, fudgeFactor]);
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
  shelfBackStraight = shelf_back_straight,
  shelfFrontInset = shelf_front_inset,
  shelfFrontAngle = shelf_front_angle,
  shelvesDrop = shelves_drop,
  backWallThickness = back_wall_thickness,
  backWallOverhang = back_wall_overhang,
  baseHeightUnits = base_height_units,
  tabCount = tab_count,
  tabWidth = tab_width,
  tabDepth = tab_depth,
  tabDovetail = tab_dovetail,
  partToRender = part,
  slotTolerance = slot_tolerance,
  slotLeadIn = slot_lead_in,
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
  assert(tabCount >= 1, "tab_count must be >= 1");
  assert(tabWidth > 0, "tab_width must be > 0");
  assert(tabDepth > 0 && tabDepth < backWallThickness,
    "tab_depth must be > 0 and < back_wall_thickness.");

  num_x = calcDimensionWidth(width);
  num_y = calcDimensionDepth(depth);

  outerSize = [
    num_x*env_pitch().x - env_clearance().x,
    num_y*env_pitch().y - env_clearance().y
  ];
  outerOrigin = [env_clearance().x/2, env_clearance().y/2];
  outerRadius = env_corner_radius();

  topOfBase = baseHeightUnits * env_pitch().z;

  // Shelf Z positions (bottom face) with `shelves_drop` applied.
  shelfBottoms = [
    for(i = [0 : shelfCount-1])
      topOfBase + (i+1) * shelfSpacing + i * shelfThickness - shelvesDrop
  ];
  topShelfTop = shelfBottoms[shelfCount-1] + shelfThickness;
  totalHeight = topShelfTop + backWallOverhang;

  assert(shelfBottoms[0] >= topOfBase,
    "shelves_drop is larger than shelf_spacing; the bottom shelf would dip into the gridfinity base.");

  // Back support Y range (spans full X across the back of the footprint).
  backWallY0 = outerOrigin.y + outerSize.y - backWallThickness;
  backWallY1 = outerOrigin.y + outerSize.y;

  // Shelf body Y range
  _shelfDepth = shelfDepth < 0
    ? (backWallY0 - outerOrigin.y)
    : min(shelfDepth, backWallY0 - outerOrigin.y);
  shelfY0 = backWallY0 - _shelfDepth;
  shelfY1 = backWallY0;

  assert(shelfBackStraight <= shelfY1 - shelfY0,
    "shelf_back_straight is larger than the shelf depth; reduce it or extend shelf_depth.");

  // Tab X centers (shared by every shelf; the back wall has one column at each X).
  tabXAllot = outerSize.x / tabCount;
  assert(tabWidth + 2 <= tabXAllot,
    "tab_width is too wide for tab_count; reduce tab_width or tab_count.");
  shelfTabXCenters = [
    for(j = [0 : tabCount-1])
      outerOrigin.x + (j + 0.5) * tabXAllot
  ];

  if(env_help_enabled("debug"))
    echo("Gridfinity_HorizontalShelves",
      outerSize=outerSize, topOfBase=topOfBase, totalHeight=totalHeight,
      shelfBottoms=shelfBottoms,
      backWallY=[backWallY0, backWallY1], shelfY=[shelfY0, shelfY1],
      shelfDepth=_shelfDepth, tabXCenters=shelfTabXCenters);

  shelfPlanSize = [outerSize.x, shelfY1 - shelfY0];
  _border = wallpattern_border == 0 ? shelfFrontRadius : wallpattern_border;

  // Shelf body (no tabs) in shelf-local frame. Front-left-bottom of body at local origin.
  module shelfBodyOnly(){
    linear_extrude(height = shelfThickness)
      ShelfFootprint2D(
        size = shelfPlanSize,
        frontRadius = shelfFrontRadius,
        frontInset = shelfFrontInset,
        backStraight = shelfBackStraight);
  }

  // Shelf pattern cutout in shelf-local frame.
  module shelfPatternCut(){
    translate([0, 0, -fudgeFactor])
    intersection(){
      linear_extrude(height = shelfThickness + fudgeFactor*2)
        offset(delta = -_border)
          ShelfFootprint2D(
            size = shelfPlanSize,
            frontRadius = shelfFrontRadius,
            frontInset = shelfFrontInset,
            backStraight = shelfBackStraight);

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

  // One back-edge tab in shelf-local frame, centered at the given X (local).
  // `padding` inflates the tab in X, Y and Z (used to build the slot cutter slightly larger
  // than the tab for fit clearance).
  module shelfTabAt(tabXLocal, padding = 0){
    _depth = tabDepth + padding;
    translate([tabXLocal, shelfPlanSize.y, -padding])
    linear_extrude(height = shelfThickness + 2*padding)
      ShelfTabProfile2D(tabWidth + 2*padding, _depth, tabDovetail);
  }

  // Full shelf piece in shelf-local frame: hex body + all tabs along the back edge.
  module unrotatedShelf(){
    difference(){
      union(){
        shelfBodyOnly();
        for(j = [0 : tabCount-1]){
          tabXLocal = shelfTabXCenters[j] - outerOrigin.x;
          shelfTabAt(tabXLocal);
        }
      }
      if(wallpatternEnabled) shelfPatternCut();
    }
  }

  // Position+tilt children into shelf `i`'s assembled world location. Pivot is at the back-bottom
  // edge of the shelf body where it meets the front face of the back wall.
  module positionShelf(i){
    z = shelfBottoms[i];
    translate([outerOrigin.x, backWallY0, z])
    rotate([-shelfFrontAngle, 0, 0])
    translate([0, -shelfPlanSize.y, 0])
      children();
  }

  // Slot cutter for shelf `i`, tab `j`. Inflated by slot_tolerance. Also extends slot_lead_in
  // forward of the wall's front face so the tab has a small lead-in.
  module shelfSlotCutter(i, j){
    tabXLocal = shelfTabXCenters[j] - outerOrigin.x;
    positionShelf(i)
      translate([0, -slotLeadIn, 0])  // shift in -Y in shelf-local frame so cutter pokes past front face
        shelfTabAt(tabXLocal, padding = slotTolerance);
  }

  // ============ MAIN-PIECE GEOMETRY ============

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
    color(env_colour(color_cup))
    translate([outerOrigin.x, backWallY0, topOfBase])
    linear_extrude(height = totalHeight - topOfBase)
      BackWallFootprint2D(
        size = [outerSize.x, backWallThickness],
        backRadius = outerRadius);
  }

  module backWallWithSlots(){
    difference(){
      backWallSolid();
      for(i = [0 : shelfCount-1])
        for(j = [0 : tabCount-1])
          shelfSlotCutter(i, j);
    }
  }

  // ============ ASSEMBLED PREVIEW ============

  module assembledShelf(i){
    color(env_colour(color_cup))
    positionShelf(i) unrotatedShelf();
  }

  // ============ PRINTABLE SHELF ============

  // Single shelf piece (all shelves are identical). Print this `shelf_count` times.
  module printableShelf(){
    color(env_colour(color_cup))
      unrotatedShelf();
  }

  // ============ DISPATCH ============
  if(partToRender == "all"){
    gridfinityBase();
    backWallWithSlots();
    for(i = [0 : shelfCount-1]) assembledShelf(i);
  } else if(partToRender == "base"){
    gridfinityBase();
    backWallWithSlots();
  } else if(partToRender == "shelf"){
    printableShelf();
  } else {
    assert(false, str("Unknown part: '", partToRender, "'. Expected 'all', 'base', or 'shelf'."));
  }
}
