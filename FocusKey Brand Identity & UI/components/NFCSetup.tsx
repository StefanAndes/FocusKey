import React, { useState } from 'react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { StatusIndicator } from './StatusIndicator';
import { Key, Waves, CheckCircle } from 'lucide-react';

interface KeySetupProps {
  isConnected: boolean;
  onConnect: () => void;
  onDisconnect: () => void;
}

export function NFCSetup({ isConnected, onConnect, onDisconnect }: KeySetupProps) {
  const [isScanning, setIsScanning] = useState(false);

  const handleScan = async () => {
    setIsScanning(true);
    // Simulate Key scanning
    setTimeout(() => {
      setIsScanning(false);
      onConnect();
    }, 3000);
  };

  return (
    <Card className="p-6">
      <div className="text-center space-y-6">
        <div className="mx-auto w-20 h-20 bg-focuskey-gradient rounded-full flex items-center justify-center">
          <Key className="w-10 h-10 text-white" />
        </div>

        <div className="space-y-2">
          <h3>Focus Key Setup</h3>
          <p className="text-muted-foreground">
            {isConnected 
              ? 'Your Focus Key is connected and ready to use.'
              : 'Connect an NFC tag or device to use as your Focus Key.'
            }
          </p>
        </div>

        <StatusIndicator 
          type={isConnected ? 'key-connected' : 'key-disconnected'} 
          className="mx-auto"
        />

        {isConnected ? (
          <div className="space-y-4">
            <div className="flex items-center justify-center gap-2 text-[var(--focuskey-success)]">
              <CheckCircle className="w-5 h-5" />
              <span className="font-medium">Focus Key Active</span>
            </div>
            <Button 
              variant="outline" 
              onClick={onDisconnect}
              className="w-full"
            >
              Disconnect Key
            </Button>
          </div>
        ) : (
          <div className="space-y-4">
            {isScanning ? (
              <div className="space-y-4">
                <div className="mx-auto w-16 h-16 flex items-center justify-center">
                  <Waves className="w-8 h-8 text-primary animate-pulse" />
                </div>
                <p className="text-sm text-muted-foreground">
                  Scanning for Focus Key...
                </p>
              </div>
            ) : (
              <Button 
                onClick={handleScan}
                className="w-full bg-focuskey-gradient hover:opacity-90"
              >
                Set Up Focus Key
              </Button>
            )}
          </div>
        )}

        <div className="text-xs text-muted-foreground space-y-1">
          <p>• Hold your NFC tag near your device</p>
          <p>• Once connected, tap the tag to toggle app locks</p>
          <p>• Works with NFC stickers, cards, and keychains</p>
        </div>
      </div>
    </Card>
  );
}