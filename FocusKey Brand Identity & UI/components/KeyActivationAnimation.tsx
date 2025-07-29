import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Lock, Unlock, CheckCircle, Sparkles } from 'lucide-react';

interface KeyActivationAnimationProps {
  isVisible: boolean;
  action: 'lock' | 'unlock';
  onComplete: () => void;
}

export function KeyActivationAnimation({ isVisible, action, onComplete }: KeyActivationAnimationProps) {
  const [particles, setParticles] = useState<Array<{ id: number; x: number; y: number; delay: number }>>([]);

  useEffect(() => {
    if (isVisible) {
      // Generate random particles
      const newParticles = Array.from({ length: 12 }, (_, i) => ({
        id: i,
        x: Math.random() * 100,
        y: Math.random() * 100,
        delay: Math.random() * 0.5,
      }));
      setParticles(newParticles);

      // Auto-complete after animation
      const timer = setTimeout(() => {
        onComplete();
      }, 2500);

      return () => clearTimeout(timer);
    }
  }, [isVisible, onComplete]);

  const ActionIcon = action === 'lock' ? Lock : Unlock;
  const actionColor = action === 'lock' ? 'var(--focuskey-success)' : 'var(--focuskey-warning)';
  const actionText = action === 'lock' ? 'Apps Protected' : 'Apps Unlocked';

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          className="fixed inset-0 z-50 flex items-center justify-center"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
        >
          {/* Background overlay with gradient */}
          <motion.div
            className="absolute inset-0 bg-gradient-to-br from-background/95 via-background/90 to-primary/5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          />

          {/* Main expanding ripple */}
          <motion.div
            className="absolute"
            initial={{ scale: 0, opacity: 0.8 }}
            animate={{ 
              scale: [0, 1.5, 2.5],
              opacity: [0.8, 0.3, 0]
            }}
            transition={{ duration: 1.5, ease: "easeOut" }}
          >
            <div 
              className="w-96 h-96 rounded-full border-4"
              style={{ borderColor: actionColor + '30' }}
            />
          </motion.div>

          {/* Secondary ripple */}
          <motion.div
            className="absolute"
            initial={{ scale: 0, opacity: 0.6 }}
            animate={{ 
              scale: [0, 1, 2],
              opacity: [0.6, 0.2, 0]
            }}
            transition={{ duration: 1.2, delay: 0.1, ease: "easeOut" }}
          >
            <div 
              className="w-64 h-64 rounded-full border-2"
              style={{ borderColor: actionColor + '40' }}
            />
          </motion.div>

          {/* Floating particles */}
          {particles.map((particle) => (
            <motion.div
              key={particle.id}
              className="absolute w-2 h-2 rounded-full"
              style={{
                backgroundColor: actionColor,
                left: `${particle.x}%`,
                top: `${particle.y}%`,
              }}
              initial={{ 
                scale: 0,
                opacity: 0,
                y: 0
              }}
              animate={{ 
                scale: [0, 1, 0],
                opacity: [0, 1, 0],
                y: [-20, -60, -100],
                x: [0, Math.random() * 40 - 20, Math.random() * 80 - 40]
              }}
              transition={{ 
                duration: 1.5,
                delay: particle.delay,
                ease: "easeOut"
              }}
            />
          ))}

          {/* Central icon animation */}
          <motion.div className="relative z-10 flex flex-col items-center">
            {/* Icon container with pulsing background */}
            <motion.div
              className="relative mb-6"
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ 
                type: "spring",
                stiffness: 200,
                damping: 10,
                delay: 0.2
              }}
            >
              {/* Pulsing background */}
              <motion.div
                className="absolute inset-0 rounded-full"
                style={{ backgroundColor: actionColor + '20' }}
                animate={{ 
                  scale: [1, 1.2, 1],
                  opacity: [0.3, 0.6, 0.3]
                }}
                transition={{ 
                  duration: 1,
                  repeat: Infinity,
                  ease: "easeInOut"
                }}
              />
              
              {/* Main icon */}
              <div 
                className="relative w-24 h-24 rounded-full flex items-center justify-center"
                style={{ backgroundColor: actionColor }}
              >
                <motion.div
                  initial={{ scale: 0, rotate: action === 'lock' ? -90 : 90 }}
                  animate={{ scale: 1, rotate: 0 }}
                  transition={{ 
                    type: "spring",
                    stiffness: 300,
                    damping: 15,
                    delay: 0.4
                  }}
                >
                  <ActionIcon className="w-12 h-12 text-white" />
                </motion.div>
              </div>

              {/* Sparkle effects around icon */}
              {[...Array(6)].map((_, i) => (
                <motion.div
                  key={i}
                  className="absolute w-3 h-3"
                  style={{
                    top: '50%',
                    left: '50%',
                    transformOrigin: '50% 50%',
                  }}
                  initial={{ 
                    scale: 0,
                    rotate: i * 60,
                    x: 0,
                    y: 0
                  }}
                  animate={{ 
                    scale: [0, 1, 0],
                    x: Math.cos((i * 60) * Math.PI / 180) * 60,
                    y: Math.sin((i * 60) * Math.PI / 180) * 60,
                  }}
                  transition={{ 
                    duration: 1,
                    delay: 0.6 + i * 0.05,
                    ease: "easeOut"
                  }}
                >
                  <Sparkles 
                    className="w-3 h-3"
                    style={{ color: actionColor }}
                  />
                </motion.div>
              ))}
            </motion.div>

            {/* Success text */}
            <motion.div
              className="text-center"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8, duration: 0.5 }}
            >
              <motion.h2 
                className="text-2xl font-semibold mb-2"
                style={{ color: actionColor }}
                animate={{ 
                  scale: [1, 1.05, 1],
                }}
                transition={{ 
                  duration: 0.5,
                  delay: 1,
                  ease: "easeInOut"
                }}
              >
                {actionText}
              </motion.h2>
              <motion.p 
                className="text-muted-foreground"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 1.2 }}
              >
                {action === 'lock' 
                  ? 'Your social apps are now protected'
                  : 'Your apps are now accessible'
                }
              </motion.p>
            </motion.div>

            {/* Progress indicator */}
            <motion.div
              className="mt-8 w-16 h-1 bg-muted rounded-full overflow-hidden"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1.5 }}
            >
              <motion.div
                className="h-full rounded-full"
                style={{ backgroundColor: actionColor }}
                initial={{ width: '0%' }}
                animate={{ width: '100%' }}
                transition={{ duration: 0.8, delay: 1.5 }}
              />
            </motion.div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}