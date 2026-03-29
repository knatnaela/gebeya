'use client';

import PhoneInput, { type Country } from 'react-phone-number-input';
import 'react-phone-number-input/style.css';
import { cn } from '@/lib/utils';

type Props = {
  value: string | undefined;
  onChange: (value: string | undefined) => void;
  id?: string;
  disabled?: boolean;
  className?: string;
  /** ISO 3166-1 alpha-2 (e.g. ET). Defaults to ET. */
  defaultCountry?: Country;
};

export function MerchantPhoneInput({
  value,
  onChange,
  id,
  disabled,
  className,
  defaultCountry = 'ET',
}: Props) {
  return (
    <div className={cn('rounded-md border border-input bg-background', className)}>
      <PhoneInput
        id={id}
        international
        defaultCountry={defaultCountry}
        value={value}
        onChange={onChange}
        disabled={disabled}
        numberInputProps={{ className: 'flex h-10 w-full bg-transparent px-3 py-2 text-sm outline-none' }}
        className="flex items-center gap-2 px-1"
      />
    </div>
  );
}
