import { errorBannerStyle } from '../styles/theme'

export default function ErrorBanner({ message, style }) {
  if (!message) return null
  return <div style={{ ...errorBannerStyle, ...style }}>{message}</div>
}
