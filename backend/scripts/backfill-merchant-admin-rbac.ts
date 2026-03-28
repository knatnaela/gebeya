/// <reference types="node" />
/**
 * One-time backfill: assign system RBAC role "Merchant Admin" to users who have
 * users.role = MERCHANT_ADMIN but no user_role_assignments row (e.g. approved before
 * approveMerchant assigned RBAC).
 *
 * assignedBy: first PLATFORM_OWNER user in the database (oldest by createdAt).
 *
 * Usage (from backend/): npx ts-node scripts/backfill-merchant-admin-rbac.ts
 */
import 'dotenv/config';
import { RoleType, UserRole } from '@prisma/client';
import { prisma } from '../src/lib/db';

function generateId(): string {
  const timestamp = Date.now().toString(36);
  const randomStr = Math.random().toString(36).substring(2, 15);
  return `cl${timestamp}${randomStr}`;
}

async function main() {
  const merchantAdminRole = await prisma.roles.findFirst({
    where: {
      name: 'Merchant Admin',
      type: RoleType.MERCHANT,
      isSystemRole: true,
    },
  });

  if (!merchantAdminRole) {
    throw new Error(
      'System role "Merchant Admin" not found. Run: npm run prisma:seed'
    );
  }

  const assigner = await prisma.users.findFirst({
    where: { role: UserRole.PLATFORM_OWNER },
    orderBy: { createdAt: 'asc' },
  });

  if (!assigner) {
    throw new Error('No PLATFORM_OWNER user found to use as assignedBy.');
  }

  const merchantAdminRoleId = merchantAdminRole.id;
  const assignerId = assigner.id;

  const merchantAdmins = await prisma.users.findMany({
    where: {
      role: UserRole.MERCHANT_ADMIN,
      merchantId: { not: null },
    },
    select: { id: true, email: true },
  });

  let created = 0;
  let updated = 0;

  for (const u of merchantAdmins) {
    const existing = await prisma.user_role_assignments.findUnique({
      where: {
        userId_roleId: {
          userId: u.id,
          roleId: merchantAdminRoleId,
        },
      },
    });

    if (existing) {
      if (!existing.isActive) {
        await prisma.user_role_assignments.update({
          where: { id: existing.id },
          data: {
            isActive: true,
            assignedBy: assignerId,
            assignedAt: new Date(),
          },
        });
        updated += 1;
        console.log(`Reactivated assignment for ${u.email}`);
      }
      continue;
    }

    await prisma.user_role_assignments.create({
      data: {
        id: generateId(),
        userId: u.id,
        roleId: merchantAdminRoleId,
        assignedBy: assignerId,
        isActive: true,
      },
    });
    created += 1;
    console.log(`Created assignment for ${u.email}`);
  }

  console.log(
    `Done. Created: ${created}, reactivated: ${updated}, merchant admins scanned: ${merchantAdmins.length}`
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
