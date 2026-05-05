import St from 'gi://St';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

export default class MatchaTheme extends Extension {
    enable() {
        this._stylesheet = this.dir.get_child('stylesheet.css');

        const context = St.ThemeContext.get_for_stage(global.stage);
        const theme = context.get_theme();

        if (this._stylesheet.query_exists(null)) {
            theme.load_stylesheet(this._stylesheet);
        }
    }

    disable() {
        if (this._stylesheet) {
            const context = St.ThemeContext.get_for_stage(global.stage);
            const theme = context.get_theme();

            theme.unload_stylesheet(this._stylesheet);
            this._stylesheet = null;

            const newTheme = new St.Theme({
                application_stylesheet: theme.application_stylesheet,
                default_stylesheet: theme.default_stylesheet,
            });

            context.set_theme(newTheme);
        }
    }
}
