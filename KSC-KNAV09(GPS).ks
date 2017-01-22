SET knav_gui_frameleft to VECDRAW(
	V(0,20,0),
	V(-10,0,0),
	white,
	"",
	1.0,
	TRUE).
SET knav_gui_frameright to VECDRAW(
	V(0,10,0),
	V(-10,0,0),
	white,
	"",
	1.0,
	TRUE).
SET knav_gui_frametop to VECDRAW(
	V(-10,20,0),
	V(0,-10,0),
	white,
	"",
	1.0,
	TRUE).
SET knav_gui_framebottom to VECDRAW(
	V(0,20,0),
	V(0,-10,0),
	white,
	"",
	1.0,
	TRUE).
SET knav_gui_centerloc to VECDRAW(
	V(-10,15,0),
	V(10,0,0),
	white,
	"",
	1.0,
	TRUE).
SET knav_gui_centergs to VECDRAW(
	V(20,-5,0),
	V(0,-10,0),
	white,
	"",
	1.0,
	TRUE).

// Configuration
SET color_ok to green.
SET color_inop to red.
// Antenna Configuration
SET knav_localizer_heading TO 90.
SET knav_gs_angle TO 3.
SET knav_antenna_geo TO LATLNG(-0.0485779672119711, -74.7224089183126).
// Fullscale is from max error one way to max error the other way
SET gs_fullscale TO 1.4.
SET loc_fullscale TO 5.
// Configures how far the maximum needle deflection is, from
// one side to the center
SET gs_maxdeflect TO 22.5.
SET loc_maxdeflect TO 22.5.
// Calculated constants from config
SET loc_minerror TO -0.5 * loc_fullscale.
SET loc_maxerror TO  0.5 * loc_fullscale.
SET  gs_minerror TO -0.5 *  gs_fullscale.
SET  gs_maxerror TO  0.5 *  gs_fullscale.
SET loc_scalefactor TO loc_maxdeflect/loc_fullscale.
SET  gs_scalefactor TO  gs_maxdeflect/gs_fullscale.


FUNCTION knav_draw_loc_needle {
	PARAMETER locerror.

	SET loc_color to color_ok.
	SET loc_angle to locerror.
	IF loc_angle > loc_maxerror { SET loc_angle TO loc_maxerror. SET loc_color TO color_inop. }
	IF loc_angle < loc_minerror { SET loc_angle TO loc_minerror. SET loc_color TO color_inop. }
	loc_angle = loc_angle * loc_scalefactor.

	SET loc_y TO SIN(loc_angle)*-10.
	SET loc_x to COS(loc_angle)*10.
	
	SET knav_gui_locneedle to VECDRAW(
		V(-10,15,0),
		V(loc_x,loc_y,0),
		loc_color,
		"",
		1.0,
		TRUE).
}

FUNCTION knav_draw_gs_needle {
	PARAMETER gserror.

	SET gs_color TO color_ok.
	SET gs_angle TO gserror.
	IF gs_angle > gs_maxerror { SET gs_angle TO gs_maxerror. SET gs_color TO color_inop. }
	IF gs_angle < gs_minerror { SET gs_angle TO gs_minerror. SET gs_color TO color_inop. }
	gs_angle = gs_angle * gs_scalefactor.

	SET gs_y TO SIN(gs_angle)*-10.
	SET gs_x to COS(gs_angle)*10.
	
	SET knav_gui_gsneedle to VECDRAW(
		V(20,-5,0),
		V(gs_x,gs_y,0),
		gs_color,
		"",
		1.0,
		TRUE).
}

SET knav_localizer_error TO 0.
SET knav_glideslope_error TO 0.

FUNCTION knav_update_loc_error {
	SET knav_ship_heading TO knav_antenna_geo:heading.
	SET knav_localizer_error TO knav_ship_heading-knav_localizer_heading.
}

FUNCTION knav_update_gs_error {
	SET slant_distance TO knav_antenna_geo:distance.
	SET antenna_altitude TO knav_antenna_geo:terrainheight.
	SET altitude_agl TO ship:altitude - antenna_altitude.
	SET gs_angle TO ARCSIN(altitude_agl/slant_distance).
	SET knav_glideslope_error TO gs_angle - knav_gs_angle.
}


UNTIL 2<1 {
	knav_update_loc_error.
	knav_draw_loc_needle(knav_localizer_error).
	knav_update_gs_error.
	knav_draw_gs_needle(knav_glideslope_error).
	WAIT 0.2.
}

