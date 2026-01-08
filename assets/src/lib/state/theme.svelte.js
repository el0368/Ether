export const themeState = $state({
  current: 'dark-plus',
  available: ['dark-plus', 'light-plus'],
  tokens: {}
});

/**
 * Updates the CSS variables on the root element based on the theme payload.
 * @param {string} themeName 
 */
export async function updateTheme(themeName) {
  try {
    const response = await fetch(`/themes/${themeName}.json`);
    const themeData = await response.json();
    
    const root = document.documentElement;
    Object.entries(themeData.colors).forEach(([key, value]) => {
      // Map VS Code keys to CSS variable names
      const cssVar = `--vscode-${key.replace(/\./g, '-')}`;
      root.style.setProperty(cssVar, value);
    });
    
    themeState.current = themeName;
    themeState.tokens = themeData.colors;
  } catch (error) {
    console.error(`Failed to load theme: ${themeName}`, error);
  }
}
