import React from 'react';
import { Shield, ShieldCheck, ShieldX, Key, KeyRound } from 'lucide-react';

interface StatusIndicatorProps {
  type: 'locked' | 'unlocked' | 'key-connected' | 'key-disconnected';
  className?: string;
}

export function StatusIndicator({ type, className = '' }: StatusIndicatorProps) {
  const configs = {
    locked: {
      icon: ShieldCheck,
      color: 'text-[var(--focuskey-success)]',
      bg: 'bg-[var(--focuskey-success)]/10',
      label: 'Protected'
    },
    unlocked: {
      icon: ShieldX,
      color: 'text-[var(--focuskey-danger)]',
      bg: 'bg-[var(--focuskey-danger)]/10',
      label: 'Unprotected'
    },
    'key-connected': {
      icon: KeyRound,
      color: 'text-[var(--focuskey-success)]',
      bg: 'bg-[var(--focuskey-success)]/10',
      label: 'Key Connected'
    },
    'key-disconnected': {
      icon: Key,
      color: 'text-[var(--focuskey-warning)]',
      bg: 'bg-[var(--focuskey-warning)]/10',
      label: 'Key Disconnected'
    }
  };

  const config = configs[type];
  const Icon = config.icon;

  return (
    <div className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full ${config.bg} ${className}`}>
      <Icon className={`w-4 h-4 ${config.color}`} />
      <span className={`text-sm font-medium ${config.color}`}>
        {config.label}
      </span>
    </div>
  );
}