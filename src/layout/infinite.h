void infinite_layout(Monitor *m) {
	Client *c = NULL;
	bool prev_suppress = suppress_setfloating_arrange;

	if (!m)
		return;

	wl_list_for_each(c, &clients, link) {
		if (!VISIBLEON(c, m) || client_is_unmanaged(c))
			continue;

		if (!c->isfloating && !c->isfullscreen && !c->ismaximizescreen) {
			suppress_setfloating_arrange = true;
			c->iscustompos = 1;
			c->iscustomsize = 1;
			c->float_geom = c->geom;
			setfloating(c, 1);
			suppress_setfloating_arrange = prev_suppress;
		} else {
			// For already floating windows, use float_geom if valid to preserve
			// position across workspace switches. This ensures windows moved
			// outside the view remain at their correct positions.
			if (c->isfloating && c->float_geom.width > 0 && c->float_geom.height > 0) {
				// Keep geom and float_geom in sync, and update pending for animation system
				c->geom = c->float_geom;
				c->pending = c->float_geom;
				c->animation.current = c->float_geom;
				resize(c, c->float_geom, 0);
			} else {
				// For fullscreen/maximized windows or if float_geom is invalid, use geom
				resize(c, c->geom, 0);
			}
		}
	}

	suppress_setfloating_arrange = prev_suppress;
}
