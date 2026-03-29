/**
 * Populate structured phone columns from legacy `phone` / `customerPhone` strings.
 * Run: npx ts-node scripts/backfill-structured-phones.ts
 */
import { PrismaClient } from '@prisma/client';
import { parseLegacyPhoneString } from '../src/utils/phone';

const prisma = new PrismaClient();

async function main() {
  let merchantsOk = 0;
  let merchantsFail = 0;
  const merchants = await prisma.merchants.findMany({
    where: { phone: { not: null } },
    select: { id: true, phone: true, phoneCountryIso: true },
  });
  for (const m of merchants) {
    if (m.phoneCountryIso) continue;
    const n = parseLegacyPhoneString(m.phone);
    if (!n) {
      console.warn(`[merchants] skip parse id=${m.id} phone=${m.phone}`);
      merchantsFail++;
      continue;
    }
    await prisma.merchants.update({
      where: { id: m.id },
      data: {
        phoneCountryIso: n.countryIso,
        phoneDialCode: n.dialCode,
        phoneNationalNumber: n.nationalNumber,
        phone: n.e164,
      },
    });
    merchantsOk++;
  }

  let locOk = 0;
  let locFail = 0;
  const locs = await prisma.locations.findMany({
    where: { phone: { not: null } },
    select: { id: true, phone: true, phoneCountryIso: true },
  });
  for (const l of locs) {
    if (l.phoneCountryIso) continue;
    const n = parseLegacyPhoneString(l.phone);
    if (!n) {
      console.warn(`[locations] skip parse id=${l.id} phone=${l.phone}`);
      locFail++;
      continue;
    }
    await prisma.locations.update({
      where: { id: l.id },
      data: {
        phoneCountryIso: n.countryIso,
        phoneDialCode: n.dialCode,
        phoneNationalNumber: n.nationalNumber,
        phone: n.e164,
      },
    });
    locOk++;
  }

  let salesOk = 0;
  let salesFail = 0;
  const sales = await prisma.sales.findMany({
    where: { customerPhone: { not: null } },
    select: { id: true, customerPhone: true, customerPhoneCountryIso: true },
  });
  for (const s of sales) {
    if (s.customerPhoneCountryIso) continue;
    const n = parseLegacyPhoneString(s.customerPhone);
    if (!n) {
      console.warn(`[sales] skip parse id=${s.id} customerPhone=${s.customerPhone}`);
      salesFail++;
      continue;
    }
    await prisma.sales.update({
      where: { id: s.id },
      data: {
        customerPhoneCountryIso: n.countryIso,
        customerPhoneDialCode: n.dialCode,
        customerPhoneNationalNumber: n.nationalNumber,
        customerPhone: n.e164,
      },
    });
    salesOk++;
  }

  console.log(
    JSON.stringify(
      {
        merchants: { updated: merchantsOk, unparseable: merchantsFail },
        locations: { updated: locOk, unparseable: locFail },
        sales: { updated: salesOk, unparseable: salesFail },
      },
      null,
      2
    )
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
