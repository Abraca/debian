/*
 * vim:noexpandtab:sw=4:sts=0:ts=4:syn=cs
 */
using GLib;
using Gtk;

namespace Abraca {
	public class Main {
		public static int main(string[] args) {
			Gtk.init(out args);
			MainWindow.instance().show_all();
			Gtk.main();

			return 0;
		}
	}
}
