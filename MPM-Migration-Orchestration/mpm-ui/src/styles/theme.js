// ─── Section 9: UI Style Guide ───────────────────────────────────────────────
// All color, typography, and layout constants derived directly from specs.md §9.
// Import this in any component rather than hardcoding values.

export const colors = {
  // Brand
  primaryGreen:          '#5a9e32',   // tabs, separator, links, title

  // Page backgrounds
  pageBackground:        '#e0e0e0',   // edit form body
  topBarBackground:      '#ffffff',   // top bar & toolbar
  navTabBackground:      '#e8e8e8',   // inactive nav tab
  activeTabBackground:   '#ffffff',   // active nav tab

  // Admin-only locked fields
  adminFieldBackground:  '#f5f5f5',
  adminFieldText:        '#888888',
  adminLabelNote:        '#e08000',   // "(Admin only)" label text

  // Feedback
  errorBackground:       '#fdecea',
  errorText:             '#721c24',

  // Info icon (ⓘ)
  infoIconBackground:    '#5b9bd5',
  infoIconText:          '#ffffff',

  // Borders & separators
  separatorLine:         '#bbbbbb',   // vertical separator between toolbar groups
  buttonBorder:          '#aaaaaa',
  inputBorderNormal:     '#aaaaaa',
  inputBorderFocused:    '#5a9e32',

  // Buttons
  buttonBackground:      '#e8e8e8',
}

export const typography = {
  fontFamily:    'Arial, Helvetica, sans-serif',
  baseFontSize:  '12px',
  pageTitleSize: '13px',
}

// ─── Reusable inline style objects ───────────────────────────────────────────

export const activeTabBorder = `2px solid ${colors.primaryGreen}`

/** Standard text input */
export const inputStyle = {
  border:      `1px solid ${colors.inputBorderNormal}`,
  fontFamily:  typography.fontFamily,
  fontSize:    typography.baseFontSize,
  padding:     '2px 4px',
  outline:     'none',
}

/** Standard button */
export const buttonStyle = {
  background:  colors.buttonBackground,
  border:      `1px solid ${colors.buttonBorder}`,
  fontFamily:  typography.fontFamily,
  fontSize:    typography.baseFontSize,
  padding:     '3px 10px',
  cursor:      'pointer',
}

/** Error banner */
export const errorBannerStyle = {
  background:    colors.errorBackground,
  color:         colors.errorText,
  padding:       '6px 10px',
  marginBottom:  '8px',
  border:        `1px solid ${colors.errorText}`,
  fontSize:      typography.baseFontSize,
}

/** Full-page container (all pages) */
export const pageStyle = {
  minHeight: '100vh',
  display: 'flex',
  flexDirection: 'column',
  fontFamily: typography.fontFamily,
  fontSize: typography.baseFontSize,
  background: '#ffffff',
}
