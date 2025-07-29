import React from 'react';
import { Card } from './ui/card';
import { Shield, Clock, Key, TrendingUp } from 'lucide-react';

interface StatsOverviewProps {
  lockedApps: number;
  totalApps: number;
  focusTime: string;
  keyTaps: number;
}

export function StatsOverview({ lockedApps, totalApps, focusTime, keyTaps }: StatsOverviewProps) {
  const stats = [
    {
      label: 'Protected Apps',
      value: `${lockedApps}/${totalApps}`,
      icon: Shield,
      color: 'text-[var(--focuskey-success)]',
      bg: 'bg-[var(--focuskey-success)]/10'
    },
    {
      label: 'Focus Time Today',
      value: focusTime,
      icon: Clock,
      color: 'text-[var(--focuskey-blue-end)]',
      bg: 'bg-[var(--focuskey-blue-end)]/10'
    },
    {
      label: 'Key Activations',
      value: keyTaps.toString(),
      icon: Key,
      color: 'text-[var(--focuskey-warning)]',
      bg: 'bg-[var(--focuskey-warning)]/10'
    }
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
      {stats.map((stat, index) => {
        const Icon = stat.icon;
        return (
          <Card key={index} className="p-4">
            <div className="flex items-center gap-3">
              <div className={`w-10 h-10 rounded-lg ${stat.bg} flex items-center justify-center`}>
                <Icon className={`w-5 h-5 ${stat.color}`} />
              </div>
              <div>
                <p className="text-2xl font-semibold">{stat.value}</p>
                <p className="text-sm text-muted-foreground">{stat.label}</p>
              </div>
            </div>
          </Card>
        );
      })}
    </div>
  );
}