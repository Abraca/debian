/**
 * Abraca, an XMMS2 client.
 * Copyright (C) 2008-2014 Abraca Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

public class Abraca.Equalizer : Gtk.Box {
	private EqualizerBands bands = new EqualizerBands();
	private EqualizerModel model;

	private Client client;
	private Gtk.ComboBoxText combobox;


	public Equalizer(Client c)
	{
		Object(orientation: Gtk.Orientation.VERTICAL, margin_left: 10, margin_right: 10);

		client = c;
		model = new EqualizerModel(client);

		var header = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);

		combobox = new Gtk.ComboBoxText();
		combobox.changed.connect(on_combobox_changed);
		combobox.append("disabled", "Disabled");
		combobox.append("legacy", "10 (legacy)");
		combobox.append("10", "10");
		combobox.append("15", "15");
		combobox.append("25", "25");
		combobox.append("31", "31");

		header.pack_start(combobox, false, true);

		var reset = new Gtk.Button.with_label("Reset");
		reset.relief = Gtk.ReliefStyle.NONE;
		reset.clicked.connect(() => {
			model.reset();
		});

		header.pack_end(reset, false, true);

		var body = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		body.pack_start(bands, true, true);

		pack_start(header, false, true);
		pack_start(body, true, true, 10);

		bands.band_changed.connect(on_band_changed);
		model.band_count_changed.connect(on_band_count_changed);
		model.band_list_changed.connect(bands.set_bands);
		model.band_changed.connect(bands.set_band);
	}

	private void on_band_count_changed(EqualizerModel model)
	{
		model.reset();

		if (!model.enabled) {
			bands.sensitive = false;
			combobox.set_active(0);
		} else {
			bands.sensitive = true;
			if (model.use_legacy) {
				combobox.set_active(1);
			} else if (model.band_count == 10) {
				combobox.set_active(2);
			} else if (model.band_count == 15) {
				combobox.set_active(3);
			} else if (model.band_count == 25) {
				combobox.set_active(4);
			} else {
				combobox.set_active(5);
			}
		}
	}

	private bool enable_equalizer(Xmms.Value value)
	{
		unowned Xmms.DictIter iter;
		var free_idx = 0;
		var found = false;

		value.get_dict_iter(out iter);

		for (iter.first(); iter.valid(); iter.next()) {
			unowned Xmms.Value cfg_value;
			unowned string key, str_value;
			var position = -1;

			if (!iter.pair(out key, out cfg_value))
				continue;

			if (!cfg_value.get_string(out str_value))
				continue;

			if (str_value.length == 0)
				continue;

			if (!key.has_prefix("effect.order."))
				continue;

			if (str_value == "equalizer") {
				found = true;
				break;
			}

			key.scanf("effect.order.%d", out position);
			if (position != -1 && position < free_idx) {
				free_idx = position;
			}

			iter.next();
		}

		if (!found) {
			GLib.warning("free index: %d", free_idx);
			/* enable equalizer at free_idx */
		}

		return true;
	}

	private void on_combobox_changed(Gtk.ComboBox combobox)
	{
		var text = (combobox as Gtk.ComboBoxText).get_active_text();
		if (text == "Disabled") {
			client.xmms.config_set_value("equalizer.enabled", "0");
		} else {
			client.xmms.config_list_values().notifier_set(enable_equalizer);
			client.xmms.config_set_value("equalizer.enabled", "1");
			if (text == "10 (legacy)") {
				client.xmms.config_set_value("equalizer.use_legacy", "1");
			} else {
				client.xmms.config_set_value("equalizer.use_legacy", "0");
				client.xmms.config_set_value("equalizer.bands", text);
			}
		}
	}

	private void on_band_changed(EqualizerBands obj, int band, double gain)
	{
		model.set_gain(band, gain);
	}
}
