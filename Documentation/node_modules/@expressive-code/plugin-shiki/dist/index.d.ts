import { ExpressiveCodeTheme, ExpressiveCodePlugin } from '@expressive-code/core';
import { MaybeGetter, MaybeArray, LanguageRegistration as LanguageRegistration$1, bundledThemes } from 'shiki';

type Optional<T, K extends keyof T> = Omit<T, K> & Pick<Partial<T>, K>;
type IRawRepository = Optional<LanguageRegistration$1['repository'], '$self' | '$base'>;
interface LanguageRegistration extends Omit<LanguageRegistration$1, 'repository'> {
    repository?: IRawRepository | undefined;
}
type LanguageInput = MaybeGetter<MaybeArray<LanguageRegistration>>;

interface PluginShikiOptions {
    /**
     * A list of additional languages that should be available for syntax highlighting.
     *
     * You can pass any of the language input types supported by Shiki, e.g.:
     * - `import('./some-exported-grammar.mjs')`
     * - `async () => JSON.parse(await fs.readFile('some-json-grammar.json', 'utf-8'))`
     *
     * See the [Shiki documentation](https://shiki.style/guide/load-lang) for more information.
     */
    langs?: LanguageInput[] | undefined;
}
/**
 * A list of all themes bundled with Shiki.
 */
type BundledShikiTheme = Exclude<keyof typeof bundledThemes, 'css-variables'>;
/**
 * Loads a theme bundled with Shiki for use with Expressive Code.
 */
declare function loadShikiTheme(bundledThemeName: BundledShikiTheme): Promise<ExpressiveCodeTheme>;
declare function pluginShiki(options?: PluginShikiOptions): ExpressiveCodePlugin;

export { BundledShikiTheme, PluginShikiOptions, loadShikiTheme, pluginShiki };
