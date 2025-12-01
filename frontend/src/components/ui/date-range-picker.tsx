'use client';

import * as React from 'react';
import { format } from 'date-fns';
import { Calendar as CalendarIcon } from 'lucide-react';
import { DayPicker, DateRange } from 'react-day-picker';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';

interface DateRangePickerProps {
  startDate?: string;
  endDate?: string;
  onDateChange: (startDate: string | undefined, endDate: string | undefined) => void;
  className?: string;
}

export function DateRangePicker({
  startDate,
  endDate,
  onDateChange,
  className,
}: DateRangePickerProps) {
  const [open, setOpen] = React.useState(false);
  const [range, setRange] = React.useState<DateRange | undefined>(() => {
    if (startDate && endDate) {
      return {
        from: new Date(startDate),
        to: new Date(endDate),
      };
    }
    return undefined;
  });
  const [tempRange, setTempRange] = React.useState<DateRange | undefined>(undefined); // Temporary range while selecting

  // Update range when props change (but not when dialog is open to allow fresh selection)
  React.useEffect(() => {
    if (!open) {
      if (startDate && endDate) {
        setRange({
          from: new Date(startDate),
          to: new Date(endDate),
        });
        setTempRange(undefined);
      } else if (!startDate && !endDate) {
        setRange(undefined);
        setTempRange(undefined);
      }
    }
  }, [startDate, endDate, open]);
  
  // Reset temp range when dialog opens to allow fresh selection
  React.useEffect(() => {
    if (open) {
      // When dialog opens, start with existing range or empty
      if (startDate && endDate) {
        setTempRange({
          from: new Date(startDate),
          to: new Date(endDate),
        });
      } else {
        setTempRange(undefined);
      }
    }
  }, [open, startDate, endDate]);

  const handleSelect = (selectedRange: DateRange | undefined) => {
    // Use tempRange while dialog is open to allow fresh selection
    if (selectedRange?.from && selectedRange?.to) {
      // Check if dates are the same (same day)
      const startDateStr = format(selectedRange.from, 'yyyy-MM-dd');
      const endDateStr = format(selectedRange.to, 'yyyy-MM-dd');
      
      // Only proceed if dates are different
      if (startDateStr !== endDateStr) {
        // Both dates selected and different - just update UI state, don't close or fetch yet
        // Show Apply button instead
        setTempRange(selectedRange);
        // Do NOT call onDateChange or close dialog - wait for Apply button click
      } else {
        // Same date selected for both - treat as incomplete, just update UI
        // User needs to select a different end date
        setTempRange({
          from: selectedRange.from,
          to: undefined, // Clear the end date so user must select a different one
        });
        // Do NOT call onDateChange - wait for a different end date
      }
    } else if (selectedRange?.from) {
      // Only start date selected - clear any previous end date and update UI
      // This allows user to start fresh when selecting a new start date
      setTempRange({
        from: selectedRange.from,
        to: undefined, // Clear end date when selecting a new start date
      });
      // Explicitly do NOT call onDateChange here - wait for end date
    } else {
      // Range cleared
      setTempRange(undefined);
      // Only clear if there was a previous complete range
      if (range?.from && range?.to) {
        setRange(undefined);
        onDateChange(undefined, undefined);
      }
    }
  };

  // Use tempRange if dialog is open, otherwise use range
  const displayRange = open ? tempRange : range;
  
  // Check if we should show Apply button
  // Show when dialog is open and we have at least a start date (with or without end date)
  const shouldShowApplyButton = open && !!displayRange?.from;
  
  const displayText = React.useMemo(() => {
    if (displayRange?.from && displayRange?.to) {
      return `${format(displayRange.from, 'MMM d')} - ${format(displayRange.to, 'MMM d, yyyy')}`;
    }
    if (range?.from && range?.to) {
      return `${format(range.from, 'MMM d')} - ${format(range.to, 'MMM d, yyyy')}`;
    }
    return 'Pick a date range';
  }, [displayRange, range]);
  
  // Handle Apply button click
  const handleApply = () => {
    if (displayRange?.from) {
      const startDateStr = format(displayRange.from, 'yyyy-MM-dd');
      
      if (displayRange?.to) {
        // Both dates selected - use the range
        const endDateStr = format(displayRange.to, 'yyyy-MM-dd');
        setRange({
          from: displayRange.from,
          to: displayRange.to,
        });
        onDateChange(startDateStr, endDateStr);
      } else {
        // Only start date selected - use same date for both
        setRange({
          from: displayRange.from,
          to: displayRange.from,
        });
        onDateChange(startDateStr, startDateStr);
      }
      setOpen(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button
          variant="outline"
          className={cn(
            'w-full justify-start text-left font-normal',
            !range && 'text-muted-foreground',
            className
          )}
        >
          <CalendarIcon className="mr-2 h-4 w-4" />
          {displayText}
        </Button>
      </DialogTrigger>
      <DialogContent className="w-auto p-0">
        <DialogHeader className="px-4 pt-4">
          <DialogTitle>Select Date Range</DialogTitle>
          <DialogDescription>
            Choose a start and end date for your filter
          </DialogDescription>
        </DialogHeader>
        <div className="p-4">
          <DayPicker
            mode="range"
            defaultMonth={displayRange?.from || range?.from}
            selected={displayRange || range}
            onSelect={handleSelect}
            numberOfMonths={2}
            className="rounded-md"
            classNames={{
              months: 'flex flex-col sm:flex-row space-y-4 sm:space-x-4 sm:space-y-0',
              month: 'space-y-4',
              caption: 'flex justify-center pt-1 relative items-center',
              caption_label: 'text-sm font-medium',
              nav: 'space-x-1 flex items-center',
              nav_button: cn(
                'h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100'
              ),
              nav_button_previous: 'absolute left-1',
              nav_button_next: 'absolute right-1',
              table: 'w-full border-collapse space-y-1',
              head_row: 'flex',
              head_cell: 'text-muted-foreground rounded-md w-9 font-normal text-[0.8rem]',
              row: 'flex w-full mt-2',
              cell: 'text-center text-sm p-0 relative first:[&:has([aria-selected])]:rounded-l-md last:[&:has([aria-selected])]:rounded-r-md focus-within:relative focus-within:z-20',
              day: cn(
                'h-9 w-9 p-0 font-normal aria-selected:opacity-100 rounded-md'
              ),
              day_range_start: 'rdp-day_range_start',
              day_range_end: 'rdp-day_range_end',
              day_selected: 'rdp-day_selected',
              day_today: 'bg-accent text-accent-foreground font-semibold',
              day_outside: 'text-muted-foreground opacity-50',
              day_disabled: 'text-muted-foreground opacity-50',
              day_range_middle: 'rdp-day_range_middle',
              day_hidden: 'invisible',
            }}
            modifiersClassNames={{
              selected: 'rdp-day_selected',
              range_start: 'rdp-day_range_start',
              range_end: 'rdp-day_range_end',
              range_middle: 'rdp-day_range_middle',
            }}
            modifiersStyles={{
              range_start: {
                backgroundColor: 'var(--primary)',
                color: 'var(--primary-foreground)',
                fontWeight: 600,
              },
              range_end: {
                backgroundColor: 'var(--primary)',
                color: 'var(--primary-foreground)',
                fontWeight: 600,
              },
              range_middle: {
                backgroundColor: 'oklch(from var(--primary) l c h / 0.2)',
                color: 'var(--primary-foreground)',
              },
              selected: {
                backgroundColor: 'oklch(from var(--primary) l c h / 0.2)',
                color: 'var(--primary-foreground)',
              },
            }}
          />
        </div>
        {shouldShowApplyButton && (
          <div className="px-4 pb-4 pt-4 border-t">
            <Button onClick={handleApply} className="w-full" size="lg">
              Apply Filter
            </Button>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}

