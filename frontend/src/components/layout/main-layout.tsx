'use client';

import { useState } from 'react';
import { Sidebar } from './sidebar';
import { Button } from '@/components/ui/button';
import { Menu, X } from 'lucide-react';
import { SubscriptionBanner } from '@/components/subscription/subscription-banner';

export function MainLayout({ children }: { children: React.ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex min-h-dvh overflow-hidden">
      {/* Mobile sidebar toggle — offset for notches / safe areas */}
      <div
        className="lg:hidden fixed z-50"
        style={{
          top: 'max(0.75rem, env(safe-area-inset-top, 0px))',
          left: 'max(0.75rem, env(safe-area-inset-left, 0px))',
        }}
      >
        <Button
          variant="outline"
          size="icon"
          onClick={() => setSidebarOpen(!sidebarOpen)}
          aria-expanded={sidebarOpen}
          aria-label={sidebarOpen ? 'Close navigation menu' : 'Open navigation menu'}
          className="bg-background/95 shadow-md backdrop-blur-sm"
        >
          {sidebarOpen ? <X className="h-4 w-4" /> : <Menu className="h-4 w-4" />}
        </Button>
      </div>

      {/* Sidebar */}
      <div
        className={`
          fixed lg:static inset-y-0 left-0 z-40 min-h-0
          transform transition-transform duration-300 ease-in-out
          ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}
      >
        <Sidebar onNavigate={() => setSidebarOpen(false)} />
      </div>

      {/* Overlay for mobile */}
      {sidebarOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black/50 z-30"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Main content — left padding clears fixed menu; bottom safe area for home indicator */}
      <main className="flex-1 overflow-y-auto bg-gradient-to-br from-slate-50 to-blue-50/30 pb-[env(safe-area-inset-bottom,0px)]">
        <div className="container mx-auto max-w-7xl px-4 pb-4 pt-[max(1rem,env(safe-area-inset-top,0px))] pl-[calc(0.75rem+2.5rem+0.75rem+env(safe-area-inset-left,0px))] lg:px-6 lg:pb-6 lg:pt-6 lg:pl-6">
          <SubscriptionBanner />
          {children}
        </div>
      </main>
    </div>
  );
}

