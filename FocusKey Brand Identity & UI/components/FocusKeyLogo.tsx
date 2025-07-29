import React from 'react';

interface FocusKeyLogoProps {
  variant?: 'cream' | 'blue';
  size?: 'sm' | 'md' | 'lg';
  showText?: boolean;
  className?: string;
}

export function FocusKeyLogo({ 
  variant = 'blue', 
  size = 'md', 
  showText = true,
  className = '' 
}: FocusKeyLogoProps) {
  const sizeClasses = {
    sm: 'w-8 h-8',
    md: 'w-12 h-12', 
    lg: 'w-16 h-16'
  };

  const textSizeClasses = {
    sm: 'text-lg',
    md: 'text-xl',
    lg: 'text-2xl'
  };

  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <div className={`${sizeClasses[size]} rounded-2xl flex items-center justify-center`}>
        {variant === 'cream' ? (
          <div className="w-full h-full rounded-2xl bg-[#f5f1e8] flex items-center justify-center">
            <div className="w-7/12 h-7/12 rounded-full border-4 border-[#e8dcc6]"></div>
          </div>
        ) : (
          <div className="w-full h-full rounded-2xl bg-focuskey-gradient flex items-center justify-center">
            <div className="w-7/12 h-7/12 rounded-full border-4 border-white/80"></div>
          </div>
        )}
      </div>
      {showText && (
        <span className={`font-semibold tracking-tight ${textSizeClasses[size]} text-foreground`}>
          FocusKey
        </span>
      )}
    </div>
  );
}