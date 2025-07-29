import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.yourname.focuskey',
  appName: 'FocusKey',
  webDir: 'dist',
  bundledWebRuntime: false,
  ios: {
    contentInset: 'automatic',
    scrollEnabled: false,
  },
  plugins: {
    NFC: {
      // NFC configuration
    }
  }
};

export default config;