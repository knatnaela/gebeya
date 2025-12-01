'use client';

import { useState, useEffect, useContext } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/contexts/auth-context';
import { PermissionsContext } from '@/contexts/permissions-context';
import { cn } from '@/lib/utils';
import apiClient from '@/lib/api';
import {
  LayoutDashboard,
  Package,
  ShoppingCart,
  TrendingUp,
  Settings,
  LogOut,
  Users,
  BarChart3,
  CreditCard,
  ChevronDown,
  ChevronRight,
  Clock,
  Shield,
  MapPin,
  AlertTriangle,
  Receipt,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { LucideIcon } from 'lucide-react';

type NavItem = {
  name: string;
  href: string;
  icon: LucideIcon;
  children?: NavItem[];
  requiredFeature?: string; // Feature slug required to access this item
  badge?: number | string; // Badge count or text to show
};

const merchantNavItems: NavItem[] = [
  { name: 'Dashboard', href: '/merchant', icon: LayoutDashboard },
  { name: 'Products', href: '/merchant/products', icon: Package, requiredFeature: 'products.view' },
  {
    name: 'Inventory',
    href: '/merchant/inventory',
    icon: TrendingUp,
    requiredFeature: 'inventory.view',
    children: [
      { name: 'Overview', href: '/merchant/inventory', icon: TrendingUp, requiredFeature: 'inventory.view' },
      { name: 'Stock Management', href: '/merchant/inventory/stock', icon: Package, requiredFeature: 'inventory.view' },
      { name: 'Debt & Credit', href: '/merchant/inventory/debt', icon: CreditCard, requiredFeature: 'inventory.view' },
      { name: 'Low Stock', href: '/merchant/inventory/low-stock', icon: AlertTriangle, requiredFeature: 'inventory.view' },
    ],
  },
  { name: 'Locations', href: '/merchant/locations', icon: MapPin, requiredFeature: 'inventory.view' },
  { name: 'Sales', href: '/merchant/sales', icon: ShoppingCart, requiredFeature: 'sales.view' },
  { name: 'Expenses', href: '/merchant/expenses', icon: Receipt, requiredFeature: 'sales.view' },
  { name: 'Analytics', href: '/merchant/analytics', icon: BarChart3, requiredFeature: 'analytics.view' },
  { name: 'Users', href: '/merchant/users', icon: Users, requiredFeature: 'users.view' },
  { name: 'Settings', href: '/merchant/settings', icon: Settings, requiredFeature: 'settings.view' },
];

const companyNavItems: NavItem[] = [
  { name: 'Dashboard', href: '/company', icon: LayoutDashboard },
  {
    name: 'Merchants',
    href: '/company/merchants',
    icon: Users,
    requiredFeature: 'merchants.view',
    children: [
      { name: 'All Merchants', href: '/company/merchants', icon: Users, requiredFeature: 'merchants.view' },
      { name: 'Pending Approvals', href: '/company/merchants/pending', icon: Clock, requiredFeature: 'merchants.view' },
    ]
  },
  { name: 'Subscriptions', href: '/company/subscriptions', icon: CreditCard, requiredFeature: 'subscriptions.view' },
  { name: 'Analytics', href: '/company/analytics', icon: BarChart3, requiredFeature: 'analytics.view' },
  { name: 'Roles', href: '/company/roles', icon: Shield, requiredFeature: 'roles.view' },
  { name: 'Features', href: '/company/features', icon: Settings, requiredFeature: 'features.view' },
  { name: 'Users', href: '/company/users', icon: Users, requiredFeature: 'users.view' },
  { name: 'Settings', href: '/company/settings', icon: Settings, requiredFeature: 'settings.view' },
];

export function Sidebar() {
  const pathname = usePathname();
  const { user, logout, isPlatformOwner } = useAuth();
  const permissionsContext = useContext(PermissionsContext);

  // Fetch low stock count for indicator
  const { data: inventorySummary } = useQuery({
    queryKey: ['inventory-summary'],
    queryFn: async () => {
      const res = await apiClient.get('/inventory/summary');
      return res.data.data;
    },
    enabled: !isPlatformOwner, // Only fetch for merchants
  });

  const lowStockCount = inventorySummary?.lowStockCount || 0;

  // Filter nav items based on permissions and add badges
  const filterNavItems = (items: NavItem[]): NavItem[] => {
    return items.filter((item) => {
      // If no required feature, show item
      if (!item.requiredFeature) return true;

      // Check if user has permission
      if (!permissionsContext) return false;
      if (!permissionsContext.hasFeature(item.requiredFeature)) return false;

      return true;
    }).map((item) => {
      // Filter children if they exist
      if (item.children) {
        const filteredChildren = item.children
          .filter((child) => {
            if (!child.requiredFeature) return true;
            return permissionsContext?.hasFeature(child.requiredFeature) || false;
          })
          .map((child) => {
            // Add badge to Low Stock if there are low stock products
            if (child.href === '/merchant/inventory/low-stock' && lowStockCount > 0) {
              return {
                ...child,
                badge: lowStockCount > 99 ? '99+' : lowStockCount,
              };
            }
            return child;
          });

        return {
          ...item,
          children: filteredChildren,
        };
      }
      return item;
    });
  };

  const allNavItems = isPlatformOwner ? companyNavItems : merchantNavItems;
  const navItems = filterNavItems(allNavItems);

  // Auto-expand sections if on related pages
  const shouldExpandMerchants = pathname.startsWith('/company/merchants');
  const shouldExpandInventory = pathname.startsWith('/merchant/inventory');
  const [expandedItems, setExpandedItems] = useState<string[]>(() => {
    const items: string[] = [];
    if (shouldExpandMerchants) items.push('Merchants');
    if (shouldExpandInventory) items.push('Inventory');
    return items;
  });

  // Update expanded state when pathname changes
  useEffect(() => {
    if (shouldExpandMerchants) {
      setExpandedItems((prev) =>
        prev.includes('Merchants') ? prev : [...prev, 'Merchants']
      );
    }
    if (shouldExpandInventory) {
      setExpandedItems((prev) =>
        prev.includes('Inventory') ? prev : [...prev, 'Inventory']
      );
    }
  }, [pathname, shouldExpandMerchants, shouldExpandInventory]);

  const toggleExpand = (itemName: string) => {
    setExpandedItems((prev) =>
      prev.includes(itemName)
        ? prev.filter((name) => name !== itemName)
        : [...prev, itemName]
    );
  };

  const isItemExpanded = (itemName: string) => expandedItems.includes(itemName);

  const isItemActive = (item: NavItem) => {
    const isDashboard = item.href === '/merchant' || item.href === '/company';
    if (isDashboard) {
      return pathname === item.href;
    }

    // If item has children, only mark parent as active if we're exactly on the parent path
    // and no child is more specific
    if (item.children) {
      // Check if any child is more specifically active
      const hasActiveChild = item.children.some((child) => {
        // For exact matches
        if (pathname === child.href) return true;
        // For child paths that start with child href (but not parent)
        if (child.href !== item.href && pathname.startsWith(child.href + '/')) return true;
        return false;
      });

      // Parent is only active if we're exactly on its path and no child matches
      if (!hasActiveChild && pathname === item.href) {
        return true;
      }
      return false;
    }

    // For items without children, use normal matching
    return pathname === item.href || pathname.startsWith(item.href + '/');
  };

  return (
    <div className="flex h-full w-64 flex-col border-r bg-gradient-to-b from-white to-slate-50 shadow-lg">
      <div className="flex h-16 items-center border-b px-6 bg-gradient-to-r from-purple-600 to-blue-600">
        <div className="flex items-center gap-2">
          <div className="h-8 w-8 rounded-lg bg-white/20 flex items-center justify-center backdrop-blur-sm">
            <span className="text-white font-bold text-lg">G</span>
          </div>
          <h1 className="text-xl font-bold text-white">Gebeya</h1>
        </div>
      </div>
      <nav className="flex-1 space-y-1 p-4 overflow-y-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          const hasChildren = item.children && item.children.length > 0;
          const isExpanded = hasChildren && isItemExpanded(item.name);
          const isActive = isItemActive(item);

          if (hasChildren) {
            return (
              <div key={item.href}>
                <Button
                  variant={isActive ? 'secondary' : 'ghost'}
                  className={cn(
                    'w-full justify-between',
                    isActive && 'bg-purple-50 text-purple-700 dark:bg-purple-950 dark:text-purple-300'
                  )}
                  onClick={() => toggleExpand(item.name)}
                >
                  <div className="flex items-center">
                    <Icon className="mr-2 h-4 w-4" />
                    {item.name}
                  </div>
                  {isExpanded ? (
                    <ChevronDown className="h-4 w-4" />
                  ) : (
                    <ChevronRight className="h-4 w-4" />
                  )}
                </Button>
                {isExpanded && (
                  <div className="ml-4 mt-1 space-y-1">
                    {item.children?.map((child) => {
                      const ChildIcon = child.icon;
                      // More precise child active check:
                      // - Exact match always works
                      // - For "All Merchants" (same href as parent), only active if exactly on parent path
                      // - For other children, check if pathname starts with child href
                      let isChildActive = false;

                      if (child.href === item.href) {
                        // "All Merchants" case - same href as parent
                        // Only active if exactly on parent path (not on sub-paths)
                        isChildActive = pathname === item.href;
                      } else {
                        // Other children - exact match or sub-path match
                        isChildActive = pathname === child.href || pathname.startsWith(child.href + '/');
                      }

                      return (
                        <Link key={child.href} href={child.href}>
                          <Button
                            variant={isChildActive ? 'secondary' : 'ghost'}
                            className={cn(
                              'w-full justify-start text-sm relative',
                              isChildActive && 'bg-purple-50 text-purple-700 dark:bg-purple-950 dark:text-purple-300'
                            )}
                          >
                            <ChildIcon className="mr-2 h-3.5 w-3.5" />
                            {child.name}
                            {child.badge && (
                              <span className="ml-auto bg-orange-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
                                {child.badge}
                              </span>
                            )}
                          </Button>
                        </Link>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          }

          return (
            <Link key={item.href} href={item.href}>
              <Button
                variant={isActive ? 'secondary' : 'ghost'}
                className={cn(
                  'w-full justify-start',
                  isActive && 'bg-purple-50 text-purple-700 dark:bg-purple-950 dark:text-purple-300'
                )}
              >
                <Icon className="mr-2 h-4 w-4" />
                {item.name}
              </Button>
            </Link>
          );
        })}
      </nav>
      <div className="border-t p-4">
        <div className="mb-2 px-2 text-sm text-muted-foreground">
          <p className="font-medium">{user?.firstName} {user?.lastName}</p>
          <p className="text-xs">{user?.email}</p>
        </div>
        <Button variant="ghost" className="w-full justify-start" onClick={logout}>
          <LogOut className="mr-2 h-4 w-4" />
          Sign Out
        </Button>
      </div>
    </div>
  );
}

