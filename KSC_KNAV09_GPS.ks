FUNCTION knav_draw_gui {

  SET knav_gui_frameleft to VECDRAW(
	SHIP:FACING:STARVECTOR*-20,
	SHIP:FACING:UPVECTOR*10,
  	white,
  	"",
  	1.0,
  	TRUE).
  SET knav_gui_frameright to VECDRAW(
	SHIP:FACING:STARVECTOR*-10,
	SHIP:FACING:UPVECTOR*10,
  	white,
  	"",
  	1.0,
  	TRUE).
  SET knav_gui_frametop to VECDRAW(
	SHIP:FACING:STARVECTOR*-20+SHIP:FACING:UPVECTOR*10,
	SHIP:FACING:STARVECTOR*10,
  	white,
  	"",
  	1.0,
  	TRUE).
  SET knav_gui_framebottom to VECDRAW(
	SHIP:FACING:STARVECTOR*-20,
	SHIP:FACING:STARVECTOR*10,
  	white,
  	"",
  	1.0,
  	TRUE).
  SET knav_gui_centerloc to VECDRAW(
	SHIP:FACING:STARVECTOR*-15+SHIP:FACING:UPVECTOR*10,
	SHIP:FACING:UPVECTOR*-10,
  	white,
  	"",
  	1.0,
  	TRUE).
  SET knav_gui_centergs to VECDRAW(
	SHIP:FACING:STARVECTOR*-20+SHIP:FACING:UPVECTOR*5,
	SHIP:FACING:STARVECTOR*10,
  	white,
  	"",
  	1.0,
  	TRUE).

}

// Configuration
SET color_ok to green.
SET color_inop to red.
// Antenna Configuration
SET knav_localizer_heading TO 90.
SET knav_gs_angle TO 14.
SET knav_antenna_geo TO LATLNG(-0.0485779672119711, -74.7224089183126).
// Fullscale is from max error one way to max error the other way
SET gs_fullscale TO 1.4.
SET loc_fullscale TO 5.
// Configures how far the maximum needle deflection is, from
// one side to the center
SET gs_maxdeflect TO 45.0.
SET loc_maxdeflect TO 45.0.
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
	SET loc_angle TO loc_angle * loc_scalefactor.

	SET loc_x TO SIN(loc_angle)*10.
	SET loc_y to COS(loc_angle)*-10.

	SET vec_x TO SHIP:FACING:STARVECTOR.
	SET vec_y TO SHIP:FACING:UPVECTOR.
	
	SET knav_gui_locneedle to VECDRAW(
		SHIP:FACING:STARVECTOR*-15+SHIP:FACING:UPVECTOR*10,
		loc_x*vec_x+loc_y*vec_y,
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
	SET gs_angle TO gs_angle * gs_scalefactor.

	SET gs_x TO COS(gs_angle)*10.
	SET gs_y to SIN(gs_angle)*-10.

	SET vec_x TO SHIP:FACING:STARVECTOR.
	SET vec_y TO SHIP:FACING:UPVECTOR.
	
	SET knav_gui_gsneedle to VECDRAW(
		SHIP:FACING:STARVECTOR*-20+SHIP:FACING:UPVECTOR*5,
		gs_x*vec_x+gs_y*vec_y,
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
	SET actual_angle TO ARCSIN(altitude_agl/slant_distance).
	SET knav_glideslope_error TO actual_angle - knav_gs_angle.
}


UNTIL 2<1 {
	knav_draw_gui.
	knav_update_loc_error.
	knav_draw_loc_needle(knav_localizer_error).
	knav_update_gs_error.
	knav_draw_gs_needle(knav_glideslope_error).
	WAIT 0.01.
}

