import React from 'react';
import { Switch } from './ui/switch';
import { StatusIndicator } from './StatusIndicator';

interface AppCardProps {
  name: string;
  icon: string;
  isLocked: boolean;
  onToggle: (locked: boolean) => void;
  usage?: string;
  category?: string;
}

export function AppCard({ name, icon, isLocked, onToggle, usage, category }: AppCardProps) {
  return (
    <div className="bg-card rounded-2xl p-4 border border-border shadow-sm hover:shadow-md transition-shadow">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-2xl bg-muted flex items-center justify-center text-2xl">
            {icon}
          </div>
          <div className="flex-1">
            <h4 className="font-medium text-card-foreground">{name}</h4>
            <div className="flex items-center gap-2 mt-1">
              {category && (
                <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                  {category}
                </span>
              )}
              {usage && (
                <span className="text-xs text-muted-foreground">
                  {usage}
                </span>
              )}
            </div>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <StatusIndicator type={isLocked ? 'locked' : 'unlocked'} />
          <Switch
            checked={isLocked}
            onCheckedChange={onToggle}
          />
        </div>
      </div>
    </div>
  );
}