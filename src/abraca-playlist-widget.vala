public class Abraca.PlaylistWidget : Gtk.ScrolledWindow {
	public PlaylistWidget (Client client, MetadataResolver resolver, Config config, Medialib medialib, Searchable search)
	{
		hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

		shadow_type = Gtk.ShadowType.IN;

		var model = new PlaylistModel(client, resolver);

		add(new PlaylistView(model, client, medialib, config, search));

		show_all ();
	}
}