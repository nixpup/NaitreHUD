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
			resize(c, c->geom, 0);
		}
	}

	suppress_setfloating_arrange = prev_suppress;
}
