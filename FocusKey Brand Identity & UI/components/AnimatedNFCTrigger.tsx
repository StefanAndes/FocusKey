import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Waves, CheckCircle, Key, KeyRound } from 'lucide-react';

interface AnimatedKeyTriggerProps {
  isConnected: boolean;
  isActivating: boolean;
  onTrigger: () => void;
}

export function AnimatedNFCTrigger({ isConnected, isActivating, onTrigger }: AnimatedKeyTriggerProps) {
  const [ripples, setRipples] = useState<number[]>([]);
  const [isPressed, setIsPressed] = useState(false);

  useEffect(() => {
    if (isActivating) {
      // Create multiple ripple animations
      const newRipples = [1, 2, 3];
      setRipples(newRipples);
      
      // Clear ripples after animation
      const timer = setTimeout(() => setRipples([]), 2000);
      return () => clearTimeout(timer);
    }
  }, [isActivating]);

  const handlePress = () => {
    setIsPressed(true);
    onTrigger();
    // Reset press state
    setTimeout(() => setIsPressed(false), 200);
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-[50vh] relative">
      {/* Animated ripples during activation */}
      {ripples.map((ripple, index) => (
        <motion.div
          key={`${isActivating}-${ripple}`}
          className="absolute w-32 h-32 border-2 border-primary/30 rounded-full"
          initial={{ scale: 0.5, opacity: 0.8 }}
          animate={{ scale: 3, opacity: 0 }}
          transition={{ 
            duration: 1.5, 
            delay: index * 0.2,
            ease: "easeOut"
          }}
        />
      ))}

      {/* Subtle pulsing ring when connected and ready */}
      {isConnected && !isActivating && (
        <motion.div
          className="absolute w-40 h-40 border border-primary/20 rounded-full"
          animate={{ 
            scale: [1, 1.1, 1],
            opacity: [0.3, 0.6, 0.3]
          }}
          transition={{ 
            duration: 3,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
      )}

      {/* Main Key Trigger Circle */}
      <motion.div
        className="relative z-10 cursor-pointer"
        whileHover={isConnected ? { scale: 1.05 } : {}}
        whileTap={isConnected ? { scale: 0.95 } : {}}
        animate={isActivating ? { 
          scale: [1, 1.1, 1],
          rotate: [0, 360],
        } : isPressed ? {
          scale: [1, 0.9, 1.05, 1]
        } : {}}
        transition={{ 
          duration: isActivating ? 0.8 : 0.3,
          type: "spring",
          stiffness: 300
        }}
        onTap={handlePress}
      >
        <div className={`
          w-32 h-32 rounded-full flex items-center justify-center shadow-xl transition-all duration-300
          ${isConnected 
            ? 'bg-focuskey-gradient shadow-[var(--focuskey-blue-end)]/20 hover:shadow-[var(--focuskey-blue-end)]/30' 
            : 'bg-muted border-2 border-dashed border-muted-foreground/30 hover:border-muted-foreground/50'
          }
        `}>
          {isActivating ? (
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
            >
              <Waves className="w-12 h-12 text-white" />
            </motion.div>
          ) : isConnected ? (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ duration: 0.3, delay: 0.1 }}
              whileHover={{ rotate: 15 }}
            >
              <KeyRound className="w-12 h-12 text-white drop-shadow-sm" />
            </motion.div>
          ) : (
            <motion.div
              animate={{ 
                y: [0, -4, 0],
                opacity: [0.5, 1, 0.5]
              }}
              transition={{ 
                duration: 2, 
                repeat: Infinity, 
                ease: "easeInOut" 
              }}
            >
              <Key className="w-12 h-12 text-muted-foreground" />
            </motion.div>
          )}
        </div>
      </motion.div>

      {/* Status Text */}
      <motion.div 
        className="mt-8 text-center"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
      >
        {isActivating ? (
          <div className="space-y-2">
            <motion.p 
              className="text-lg font-medium text-foreground"
              animate={{ opacity: [1, 0.7, 1] }}
              transition={{ duration: 1, repeat: Infinity }}
            >
              Activating...
            </motion.p>
            <motion.div className="flex justify-center space-x-1">
              {[0, 1, 2].map((i) => (
                <motion.div
                  key={i}
                  className="w-2 h-2 bg-primary rounded-full"
                  animate={{ y: [0, -8, 0] }}
                  transition={{ duration: 0.6, repeat: Infinity, delay: i * 0.1 }}
                />
              ))}
            </motion.div>
          </div>
        ) : isConnected ? (
          <div className="space-y-2">
            <motion.p 
              className="text-lg font-medium text-foreground"
              animate={{ scale: [1, 1.02, 1] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            >
              Ready to Focus
            </motion.p>
            <p className="text-sm text-muted-foreground">Tap your Key to trigger apps</p>
          </div>
        ) : (
          <div className="space-y-2">
            <p className="text-lg font-medium text-foreground">Set Up Your Key</p>
            <p className="text-sm text-muted-foreground">Connect your focus Key</p>
          </div>
        )}
      </motion.div>

      {/* Floating particles animation when connected */}
      {isConnected && !isActivating && (
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          {[...Array(8)].map((_, i) => (
            <motion.div
              key={i}
              className="absolute w-1 h-1 bg-primary/20 rounded-full"
              style={{
                left: `${20 + i * 8}%`,
                top: `${30 + (i % 3) * 15}%`,
              }}
              animate={{
                y: [0, -30, 0],
                opacity: [0.1, 0.6, 0.1],
                scale: [0.5, 1, 0.5],
              }}
              transition={{
                duration: 4 + i * 0.3,
                repeat: Infinity,
                delay: i * 0.4,
                ease: "easeInOut",
              }}
            />
          ))}
        </div>
      )}

      {/* Tap instruction hint - positioned within the component bounds */}
      {isConnected && !isActivating && (
        <motion.div
          className="mt-12 relative"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 2, duration: 0.5 }}
        >
          <motion.div
            className="px-3 py-1 bg-primary/10 rounded-full border border-primary/20 relative z-20"
            animate={{ 
              y: [0, -2, 0],
              opacity: [0.7, 1, 0.7]
            }}
            transition={{ 
              duration: 1.5, 
              repeat: Infinity,
              ease: "easeInOut"
            }}
          >
            <span className="text-xs text-primary font-medium">Tap to activate</span>
          </motion.div>
        </motion.div>
      )}
    </div>
  );
}