'use client';

import { useState, useEffect, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { Calendar } from 'lucide-react';
import { format } from 'date-fns';
import { DateRangePicker } from '@/components/ui/date-range-picker';

export type DatePreset = 'this-month' | 'last-month' | 'this-quarter' | 'this-year' | 'all-time' | 'custom';

interface DateFilterProps {
  onDateChange: (startDate: string | undefined, endDate: string | undefined) => void;
  defaultPreset?: DatePreset;
  className?: string;
  // Controlled props to sync with parent state
  value?: { startDate?: string; endDate?: string };
}

export function DateFilter({ onDateChange, defaultPreset = 'all-time', className, value }: DateFilterProps) {
  const [activePreset, setActivePreset] = useState<DatePreset>(defaultPreset);
  const [startDate, setStartDate] = useState<string>(value?.startDate || '');
  const [endDate, setEndDate] = useState<string>(value?.endDate || '');
  const presetRef = useRef<DatePreset>(defaultPreset); // Keep track of preset to prevent reset
  const isInitialized = useRef(false); // Track if component has been initialized

  // Calculate date ranges for presets
  const getDateRange = (preset: DatePreset): { start: string | undefined; end: string | undefined } => {
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth();

    switch (preset) {
      case 'this-month': {
        const start = new Date(year, month, 1);
        return {
          start: format(start, 'yyyy-MM-dd'),
          end: format(today, 'yyyy-MM-dd'),
        };
      }
      case 'last-month': {
        const lastMonth = month === 0 ? 11 : month - 1;
        const lastMonthYear = month === 0 ? year - 1 : year;
        const start = new Date(lastMonthYear, lastMonth, 1);
        const end = new Date(year, month, 0); // Last day of previous month
        return {
          start: format(start, 'yyyy-MM-dd'),
          end: format(end, 'yyyy-MM-dd'),
        };
      }
      case 'this-quarter': {
        const quarter = Math.floor(month / 3);
        const start = new Date(year, quarter * 3, 1);
        return {
          start: format(start, 'yyyy-MM-dd'),
          end: format(today, 'yyyy-MM-dd'),
        };
      }
      case 'this-year': {
        const start = new Date(year, 0, 1);
        return {
          start: format(start, 'yyyy-MM-dd'),
          end: format(today, 'yyyy-MM-dd'),
        };
      }
      case 'all-time':
        return { start: undefined, end: undefined };
      case 'custom':
        return { start: startDate || undefined, end: endDate || undefined };
      default:
        return { start: undefined, end: undefined };
    }
  };

  // Helper function to detect preset from dates
  const detectPresetFromDates = (start: string, end: string): DatePreset => {
    if (!start && !end) {
      return 'all-time';
    }
    
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth();
    const todayStr = format(today, 'yyyy-MM-dd');
    
    // Check this-month
    const thisMonthStart = format(new Date(year, month, 1), 'yyyy-MM-dd');
    if (start === thisMonthStart && end === todayStr) {
      return 'this-month';
    }
    
    // Check last-month
    const lastMonth = month === 0 ? 11 : month - 1;
    const lastMonthYear = month === 0 ? year - 1 : year;
    const lastMonthStart = format(new Date(lastMonthYear, lastMonth, 1), 'yyyy-MM-dd');
    const lastMonthEnd = format(new Date(year, month, 0), 'yyyy-MM-dd');
    if (start === lastMonthStart && end === lastMonthEnd) {
      return 'last-month';
    }
    
    // Check this-quarter
    const quarter = Math.floor(month / 3);
    const quarterStart = format(new Date(year, quarter * 3, 1), 'yyyy-MM-dd');
    if (start === quarterStart && end === todayStr) {
      return 'this-quarter';
    }
    
    // Check this-year
    const yearStart = format(new Date(year, 0, 1), 'yyyy-MM-dd');
    if (start === yearStart && end === todayStr) {
      return 'this-year';
    }
    
    // Doesn't match any preset, it's custom
    return 'custom';
  };

  // Handle preset selection
  const handlePresetClick = (preset: DatePreset) => {
    presetRef.current = preset; // Store preset in ref to prevent reset
    setActivePreset(preset);
    if (preset === 'custom') {
      // Don't change dates when clicking custom - let user pick
    } else {
      const { start, end } = getDateRange(preset);
      setStartDate(start || '');
      setEndDate(end || '');
      onDateChange(start, end);
    }
  };

  // Handle custom date changes from date range picker
  // Only update when both dates are provided (complete range)
  const handleCustomDateChange = (newStartDate?: string, newEndDate?: string) => {
    // Only proceed if we have both dates OR if we're clearing (both undefined)
    if ((newStartDate && newEndDate) || (!newStartDate && !newEndDate)) {
      const start = newStartDate || '';
      const end = newEndDate || '';
      setStartDate(start);
      setEndDate(end);
      
      // Detect which preset matches these dates
      const detectedPreset = detectPresetFromDates(start, end);
      setActivePreset(detectedPreset);
      presetRef.current = detectedPreset;
      
      onDateChange(newStartDate || undefined, newEndDate || undefined);
    }
    // If only one date is provided, don't update yet - wait for complete range
  };

  // Sync with parent value prop (for controlled usage)
  // Only sync when value changes from parent, not on initial mount if we already have state
  useEffect(() => {
    // Skip if value is undefined and we haven't initialized yet (prevents reset on first fetch)
    if (!value && !isInitialized.current) {
      return;
    }
    
    if (value) {
      const newStartDate = value.startDate || '';
      const newEndDate = value.endDate || '';
      
      // Only update if dates actually changed to avoid unnecessary re-renders
      // Also check if the change is meaningful (not just empty to empty)
      const currentHasDates = startDate || endDate;
      const newHasDates = newStartDate || newEndDate;
      
      if (newStartDate !== startDate || newEndDate !== endDate) {
        // Only update if we're going from empty to something, or something to something else
        // Don't reset if we have dates and new value is empty (unless explicitly clearing)
        if (currentHasDates && !newHasDates && isInitialized.current) {
          // This is a clear action, allow it
          setStartDate(newStartDate);
          setEndDate(newEndDate);
        } else if (newHasDates || !currentHasDates) {
          // Update if new value has dates, or if current is also empty
          setStartDate(newStartDate);
          setEndDate(newEndDate);
        }
        
        // Detect which preset matches the current dates using helper function
        const detectedPreset = detectPresetFromDates(newStartDate, newEndDate);
        if (activePreset !== detectedPreset) {
          setActivePreset(detectedPreset);
          presetRef.current = detectedPreset;
        }
      }
    }
  }, [value, startDate, endDate, activePreset]);

  // Initialize with default preset or value prop (only once on mount)
  useEffect(() => {
    if (!isInitialized.current) {
      isInitialized.current = true;
      // If value prop is provided (e.g., from URL params), use it
      if (value) {
        const valStartDate = value.startDate || '';
        const valEndDate = value.endDate || '';
        setStartDate(valStartDate);
        setEndDate(valEndDate);
        
        // Detect preset from dates immediately
        const detectedPreset = detectPresetFromDates(valStartDate, valEndDate);
        setActivePreset(detectedPreset);
        presetRef.current = detectedPreset;
      } else if (defaultPreset !== 'custom') {
        // No value prop, use default preset
        const { start, end } = getDateRange(defaultPreset);
        setStartDate(start || '');
        setEndDate(end || '');
        presetRef.current = defaultPreset;
        onDateChange(start, end);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Only run once on mount

  // Format date range for display
  const getDateRangeDisplay = (): string => {
    if (activePreset === 'all-time') return 'All Time';
    if (activePreset === 'custom' && startDate && endDate) {
      return `${format(new Date(startDate), 'MMM d')} - ${format(new Date(endDate), 'MMM d, yyyy')}`;
    }
    if (activePreset === 'custom' && (startDate || endDate)) {
      return startDate ? `From ${format(new Date(startDate), 'MMM d, yyyy')}` : `Until ${format(new Date(endDate), 'MMM d, yyyy')}`;
    }
    const { start, end } = getDateRange(activePreset);
    if (start && end) {
      return `${format(new Date(start), 'MMM d')} - ${format(new Date(end), 'MMM d, yyyy')}`;
    }
    return 'All Time';
  };

  return (
    <div className={`space-y-3 ${className}`}>
      {/* Preset Buttons */}
      <div className="flex flex-wrap gap-2">
        <Button
          type="button"
          variant={activePreset === 'this-month' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handlePresetClick('this-month')}
        >
          This Month
        </Button>
        <Button
          type="button"
          variant={activePreset === 'last-month' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handlePresetClick('last-month')}
        >
          Last Month
        </Button>
        <Button
          type="button"
          variant={activePreset === 'this-quarter' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handlePresetClick('this-quarter')}
        >
          This Quarter
        </Button>
        <Button
          type="button"
          variant={activePreset === 'this-year' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handlePresetClick('this-year')}
        >
          This Year
        </Button>
        <Button
          type="button"
          variant={activePreset === 'all-time' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handlePresetClick('all-time')}
        >
          All Time
        </Button>
        <Button
          type="button"
          variant={activePreset === 'custom' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handlePresetClick('custom')}
        >
          <Calendar className="h-4 w-4 mr-1" />
          Custom Range
        </Button>
      </div>

      {/* Custom Date Range Picker */}
      {activePreset === 'custom' && (
        <div className="space-y-2">
          <DateRangePicker
            startDate={startDate}
            endDate={endDate}
            onDateChange={handleCustomDateChange}
          />
        </div>
      )}

      {/* Selected Range Display */}
      {activePreset !== 'all-time' && (
        <div className="text-sm text-muted-foreground">
          Showing: {getDateRangeDisplay()}
        </div>
      )}
    </div>
  );
}

