import React, { useState } from "react";
import { motion } from "motion/react";
import { FocusKeyLogo } from "./components/FocusKeyLogo";
import { Navigation } from "./components/Navigation";
import { StatsOverview } from "./components/StatsOverview";
import { AppCard } from "./components/AppCard";
import { NFCSetup } from "./components/NFCSetup";
import { StatusIndicator } from "./components/StatusIndicator";
import { AnimatedNFCTrigger } from "./components/AnimatedNFCTrigger";
import { KeyActivationAnimation } from "./components/KeyActivationAnimation";
import { Card } from "./components/ui/card";
import { Button } from "./components/ui/button";
import { Input } from "./components/ui/input";
import { Switch } from "./components/ui/switch";
import {
  Bell,
  Search,
  Moon,
  Sun,
  Info,
  Clock,
} from "lucide-react";

// Mock Capacitor functionality for web environment
const mockCapacitor = {
  isNativePlatform: () => false,
  getPlatform: () => "web",
};

const mockNFC = {
  isAvailable: () => Promise.resolve({ available: false }),
  addListener: () => Promise.resolve(),
  startScan: () => Promise.resolve(),
  stopScan: () => Promise.resolve(),
};

export default function App() {
  const [activeTab, setActiveTab] = useState("home");
  const [isDark, setIsDark] = useState(false);
  const [keyConnected, setKeyConnected] = useState(false);
  const [keyActivating, setKeyActivating] = useState(false);
  const [showSuccessAnimation, setShowSuccessAnimation] =
    useState(false);
  const [lastAction, setLastAction] = useState<
    "lock" | "unlock"
  >("lock");
  const [searchQuery, setSearchQuery] = useState("");
  const [currentTime, setCurrentTime] = useState(new Date());

  const [apps, setApps] = useState([
    {
      id: "1",
      name: "Instagram",
      icon: "📷",
      isLocked: true,
      usage: "2h 34m",
      category: "Social",
    },
    {
      id: "2",
      name: "TikTok",
      icon: "🎵",
      isLocked: true,
      usage: "1h 45m",
      category: "Social",
    },
    {
      id: "3",
      name: "YouTube",
      icon: "📺",
      isLocked: false,
      usage: "45m",
      category: "Entertainment",
    },
    {
      id: "4",
      name: "Twitter",
      icon: "🐦",
      isLocked: true,
      usage: "1h 12m",
      category: "Social",
    },
    {
      id: "5",
      name: "Reddit",
      icon: "🔴",
      isLocked: false,
      usage: "32m",
      category: "Social",
    },
    {
      id: "6",
      name: "Netflix",
      icon: "🎬",
      isLocked: false,
      usage: "1h 20m",
      category: "Entertainment",
    },
    {
      id: "7",
      name: "Spotify",
      icon: "🎧",
      isLocked: false,
      usage: "3h 15m",
      category: "Music",
    },
    {
      id: "8",
      name: "Discord",
      icon: "💬",
      isLocked: true,
      usage: "45m",
      category: "Communication",
    },
  ]);

  // Initialize mock NFC on mount
  React.useEffect(() => {
    if (mockCapacitor.isNativePlatform()) {
      initializeNFC();
    }

    const timer = setInterval(
      () => setCurrentTime(new Date()),
      60000,
    );
    return () => clearInterval(timer);
  }, []);

  const initializeNFC = async () => {
    try {
      const isAvailable = await mockNFC.isAvailable();
      if (isAvailable.available) {
        console.log("NFC is available");
        // Set up NFC listeners
        setupNFCListeners();
      }
    } catch (error) {
      console.error("NFC initialization error:", error);
    }
  };

  const setupNFCListeners = async () => {
    try {
      await mockNFC.addListener(
        "nfcTagScanned",
        (data: any) => {
          console.log("NFC tag scanned:", data);
          handleNFCTrigger();
        },
      );
    } catch (error) {
      console.error("NFC listener error:", error);
    }
  };

  const startNFCScanning = async () => {
    try {
      await mockNFC.startScan();
      setKeyConnected(true);
    } catch (error) {
      console.error("NFC scan error:", error);
    }
  };

  const stopNFCScanning = async () => {
    try {
      await mockNFC.stopScan();
      setKeyConnected(false);
    } catch (error) {
      console.error("NFC stop error:", error);
    }
  };

  const handleNFCTrigger = () => {
    if (!keyConnected) return;

    setKeyActivating(true);

    // Determine action based on current state
    const socialApps = apps.filter(
      (app) => app.category === "Social",
    );
    const lockedSocialApps = socialApps.filter(
      (app) => app.isLocked,
    );
    const shouldLock =
      lockedSocialApps.length < socialApps.length / 2;
    const action = shouldLock ? "lock" : "unlock";

    setLastAction(action);

    // Add haptic feedback simulation
    if (
      mockCapacitor.isNativePlatform() &&
      (window as any).Haptics
    ) {
      (window as any).Haptics.impact({ style: "medium" });
    }

    setTimeout(() => {
      setApps((prevApps) =>
        prevApps.map((app) =>
          app.category === "Social"
            ? { ...app, isLocked: shouldLock }
            : app,
        ),
      );

      setKeyActivating(false);
      setShowSuccessAnimation(true);
    }, 800);
  };

  const getGreeting = () => {
    const hour = currentTime.getHours();
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  };

  const handleKeyTrigger = async () => {
    if (!keyConnected) {
      setActiveTab("key");
      return;
    }

    // Use native NFC if available, otherwise simulate
    if (mockCapacitor.isNativePlatform()) {
      handleNFCTrigger();
    } else {
      // Web fallback - simulate key activation
      setKeyActivating(true);

      const socialApps = apps.filter(
        (app) => app.category === "Social",
      );
      const lockedSocialApps = socialApps.filter(
        (app) => app.isLocked,
      );
      const shouldLock =
        lockedSocialApps.length < socialApps.length / 2;
      const action = shouldLock ? "lock" : "unlock";

      setLastAction(action);

      setTimeout(() => {
        setApps((prevApps) =>
          prevApps.map((app) =>
            app.category === "Social"
              ? { ...app, isLocked: shouldLock }
              : app,
          ),
        );

        setKeyActivating(false);
        setShowSuccessAnimation(true);
      }, 800);
    }
  };

  const handleAnimationComplete = () => {
    setShowSuccessAnimation(false);
  };

  const toggleAppLock = (appId: string, locked: boolean) => {
    setApps(
      apps.map((app) =>
        app.id === appId ? { ...app, isLocked: locked } : app,
      ),
    );
  };

  const lockedApps = apps.filter((app) => app.isLocked).length;
  const filteredApps = apps.filter(
    (app) =>
      app.name
        .toLowerCase()
        .includes(searchQuery.toLowerCase()) ||
      app.category
        .toLowerCase()
        .includes(searchQuery.toLowerCase()),
  );

  const toggleTheme = () => {
    setIsDark(!isDark);
    document.documentElement.classList.toggle("dark");
  };

  const renderHomeTab = () => (
    <div className="min-h-[calc(100vh-140px)] flex flex-col">
      {/* Minimal header */}
      <motion.div
        className="text-center py-8 flex-shrink-0"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
      >
        <p className="text-muted-foreground mb-2">
          {getGreeting()} 👋
        </p>
        <h1 className="text-2xl font-semibold">Stay Focused</h1>
      </motion.div>

      {/* Main Key Trigger - with proper spacing */}
      <div className="flex-1 flex flex-col justify-center min-h-0">
        <AnimatedNFCTrigger
          isConnected={keyConnected}
          isActivating={keyActivating}
          onTrigger={handleKeyTrigger}
        />
      </div>

      {/* Platform indicator (for testing) */}
      {!mockCapacitor.isNativePlatform() && (
        <div className="text-center text-xs text-muted-foreground py-2">
          Web Mode - Tap trigger to simulate
        </div>
      )}

      {/* Minimal status footer - with enough space above */}
      <motion.div
        className="text-center pb-8 pt-4 flex-shrink-0 relative z-30"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.8 }}
      >
        <div className="flex items-center justify-center gap-4 text-sm text-muted-foreground">
          <div className="flex items-center gap-2">
            <motion.div
              className={`w-2 h-2 rounded-full ${keyConnected ? "bg-[var(--focuskey-success)]" : "bg-[var(--focuskey-warning)]"}`}
              animate={
                keyConnected
                  ? {
                      scale: [1, 1.2, 1],
                      opacity: [1, 0.7, 1],
                    }
                  : {}
              }
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            />
            <span>
              {keyConnected ? "Key ready" : "Key setup needed"}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <motion.div
              className="w-2 h-2 rounded-full bg-primary"
              animate={{
                scale: [1, 1.1, 1],
                opacity: [1, 0.8, 1],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 0.5,
              }}
            />
            <span>{lockedApps} apps protected</span>
          </div>
        </div>
      </motion.div>

      {/* Success Animation Overlay */}
      <KeyActivationAnimation
        isVisible={showSuccessAnimation}
        action={lastAction}
        onComplete={handleAnimationComplete}
      />
    </div>
  );

  const renderDashboardTab = () => (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Dashboard</h1>
          <p className="text-muted-foreground mt-1">
            Your focus insights
          </p>
        </div>
        <StatusIndicator
          type={
            keyConnected ? "key-connected" : "key-disconnected"
          }
        />
      </div>

      <StatsOverview
        lockedApps={lockedApps}
        totalApps={apps.length}
        focusTime="4h 32m"
        keyTaps={12}
      />

      <Card className="p-4">
        <h3 className="mb-4">Quick Actions</h3>
        <div className="grid grid-cols-2 gap-3">
          <Button
            variant="outline"
            className="h-auto p-4 flex flex-col gap-2"
            onClick={() => setActiveTab("apps")}
          >
            <span className="text-2xl">🔒</span>
            <span className="text-sm">Manage Apps</span>
          </Button>
          <Button
            variant="outline"
            className="h-auto p-4 flex flex-col gap-2"
            onClick={() => setActiveTab("key")}
          >
            <span className="text-2xl">🗝️</span>
            <span className="text-sm">Setup Key</span>
          </Button>
        </div>
      </Card>

      <Card className="p-4">
        <div className="flex items-center gap-3 mb-4">
          <Clock className="w-5 h-5 text-primary" />
          <h3>Today's Focus</h3>
        </div>
        <div className="space-y-3">
          <div className="flex justify-between items-center">
            <span className="text-sm text-muted-foreground">
              Total focused time
            </span>
            <span className="font-medium">4h 32m</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-sm text-muted-foreground">
              Apps avoided
            </span>
            <span className="font-medium">23 attempts</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-sm text-muted-foreground">
              Key activations
            </span>
            <span className="font-medium">12 taps</span>
          </div>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4">Recently Modified</h3>
        <div className="space-y-3">
          {apps.slice(0, 3).map((app) => (
            <motion.div
              key={app.id}
              className="flex items-center gap-3 p-2 rounded-lg bg-muted/50"
              whileHover={{ scale: 1.02 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              <span className="text-2xl">{app.icon}</span>
              <div className="flex-1">
                <p className="font-medium">{app.name}</p>
                <p className="text-sm text-muted-foreground">
                  {app.usage} today
                </p>
              </div>
              <StatusIndicator
                type={app.isLocked ? "locked" : "unlocked"}
              />
            </motion.div>
          ))}
        </div>
      </Card>
    </div>
  );

  const renderAppsTab = () => (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1>App Management</h1>
        <Button
          variant="outline"
          size="sm"
          onClick={() => {
            const allLocked = apps.every((app) => app.isLocked);
            setApps(
              apps.map((app) => ({
                ...app,
                isLocked: !allLocked,
              })),
            );
          }}
        >
          {apps.every((app) => app.isLocked)
            ? "Unlock All"
            : "Lock All"}
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          placeholder="Search apps..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pl-10"
        />
      </div>

      <div className="space-y-3">
        {filteredApps.map((app) => (
          <AppCard
            key={app.id}
            name={app.name}
            icon={app.icon}
            isLocked={app.isLocked}
            onToggle={(locked) => toggleAppLock(app.id, locked)}
            usage={app.usage}
            category={app.category}
          />
        ))}
      </div>
    </div>
  );

  const renderKeyTab = () => (
    <div className="space-y-6">
      <div>
        <h1>Key Setup</h1>
        <p className="text-muted-foreground mt-1">
          Configure your physical focus key
        </p>
      </div>

      <NFCSetup
        isConnected={keyConnected}
        onConnect={startNFCScanning}
        onDisconnect={stopNFCScanning}
      />

      {keyConnected && (
        <Card className="p-4">
          <h3 className="mb-4">Key Behavior</h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">Lock on Key tap</p>
                <p className="text-sm text-muted-foreground">
                  Automatically lock configured apps
                </p>
              </div>
              <Switch defaultChecked />
            </div>
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">
                  Unlock on second tap
                </p>
                <p className="text-sm text-muted-foreground">
                  Double-tap to unlock all apps
                </p>
              </div>
              <Switch defaultChecked />
            </div>
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">
                  Vibration feedback
                </p>
                <p className="text-sm text-muted-foreground">
                  Haptic response on activation
                </p>
              </div>
              <Switch defaultChecked />
            </div>
          </div>
        </Card>
      )}
    </div>
  );

  const renderSettingsTab = () => (
    <div className="space-y-6">
      <h1>Settings</h1>

      <Card className="p-4">
        <h3 className="mb-4">Appearance</h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              {isDark ? (
                <Moon className="w-5 h-5" />
              ) : (
                <Sun className="w-5 h-5" />
              )}
              <div>
                <p className="font-medium">Dark Mode</p>
                <p className="text-sm text-muted-foreground">
                  Toggle dark theme
                </p>
              </div>
            </div>
            <Switch
              checked={isDark}
              onCheckedChange={toggleTheme}
            />
          </div>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4">Notifications</h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Bell className="w-5 h-5" />
              <div>
                <p className="font-medium">Focus Reminders</p>
                <p className="text-sm text-muted-foreground">
                  Get reminded to stay focused
                </p>
              </div>
            </div>
            <Switch defaultChecked />
          </div>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4">About</h3>
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <Info className="w-5 h-5" />
            <div>
              <p className="font-medium">FocusKey v1.0.0</p>
              <p className="text-sm text-muted-foreground">
                Physical app control via Key
              </p>
            </div>
          </div>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4">Platform Info</h3>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-muted-foreground">
              Platform:
            </span>
            <span>{mockCapacitor.getPlatform()}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">
              Native:
            </span>
            <span>
              {mockCapacitor.isNativePlatform() ? "Yes" : "No"}
            </span>
          </div>
        </div>
      </Card>
    </div>
  );

  const renderContent = () => {
    switch (activeTab) {
      case "home":
        return renderHomeTab();
      case "dashboard":
        return renderDashboardTab();
      case "apps":
        return renderAppsTab();
      case "key":
        return renderKeyTab();
      case "settings":
        return renderSettingsTab();
      default:
        return renderHomeTab();
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header - only show on non-home tabs */}
      {activeTab !== "home" && (
        <header className="sticky top-0 z-10 bg-background/80 backdrop-blur-sm border-b border-border">
          <div className="flex items-center justify-between p-4 max-w-md mx-auto">
            <FocusKeyLogo variant="blue" size="md" />
            <Button
              variant="ghost"
              size="sm"
              className="rounded-full"
            >
              <Bell className="w-5 h-5" />
            </Button>
          </div>
        </header>
      )}

      {/* Content */}
      <main
        className={`max-w-md mx-auto ${activeTab === "home" ? "" : "p-4 pb-20"}`}
      >
        {renderContent()}
      </main>

      {/* Navigation */}
      <Navigation
        activeTab={activeTab}
        onTabChange={setActiveTab}
      />
    </div>
  );
}